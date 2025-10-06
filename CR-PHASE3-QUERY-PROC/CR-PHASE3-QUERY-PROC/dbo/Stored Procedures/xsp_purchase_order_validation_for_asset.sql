CREATE PROCEDURE [dbo].[xsp_purchase_order_validation_for_asset]
(
	@p_code			nvarchar(50)
	,@p_reff_code	nvarchar(50)
)
as
begin
	declare @msg		nvarchar(max)
			,@fa_code	nvarchar(50)
			,@type		nvarchar(50)
			,@asset_no	nvarchar(50)

	begin try
		
		select	@type = type
		from	ifinams.dbo.handover_asset
		where	code = @p_code ;

		if(@type = 'DELIVERY')
		begin
			set @asset_no = @p_reff_code
		end
		else if(@type = 'REPLACE GTS OUT')
		begin
			select @asset_no = old_asset_no 
			from ifinopl.dbo.asset_replacement_detail
			where replacement_code = @p_reff_code
		end
		else
		begin
			set @asset_no = ''
		end

		declare curr_validate cursor fast_forward read_only for
        select fa_code 
		from ifinams.dbo.handover_asset 
		where code = @p_code
		
		open curr_validate
		
		fetch next from curr_validate 
		into @fa_code
		
		while @@fetch_status = 0
		begin
		    	if not exists (select 1 from ifinopl.dbo.application_asset where asset_no = @asset_no and replacement_fa_code = isnull(@fa_code,''))
				begin
					if exists(
					select 1 from dbo.procurement_request pr 
					left join dbo.procurement_request_item pri on (pr.code = pri.procurement_request_code)
					where asset_no = @asset_no
					and pri.category_type = 'MOBILISASI'
					and pr.status <> 'CANCEL'
					)
					begin
						
						if not exists
						(
							select	1
							from	dbo.purchase_order						po
									left join dbo.purchase_order_detail		pod on (pod.po_code							  = po.code)
									left join dbo.supplier_selection_detail ssd on (ssd.id								  = pod.supplier_selection_detail_id)
									left join dbo.quotation_review_detail	qrd on (qrd.id								  = ssd.quotation_detail_id)
									left join dbo.procurement				prc on (prc.code collate Latin1_General_CI_AS = qrd.reff_no)
									left join dbo.procurement				prc2 on (prc2.code							  = ssd.reff_no)
									left join dbo.procurement_request		pr on (pr.code								  = prc.procurement_request_code)
									left join dbo.procurement_request		pr2 on (pr2.code							  = prc2.procurement_request_code)
							where	po.status							  in ('APPROVE', 'CLOSED')
									and isnull(pr.asset_no, pr2.asset_no) = @asset_no
									and isnull(pr.procurement_type, pr2.procurement_type) = 'MOBILISASI'
						)
						begin
							set @msg = N'V;Cannot proceed, because this asset is in mobilization process.' ;
						end ;
					end
				end
		    FETCH NEXT FROM curr_validate 
			into @fa_code
		END
		
		CLOSE curr_validate
		DEALLOCATE curr_validate


		
		--if exists(
		--			select 1 from dbo.procurement_request pr 
		--			left join dbo.procurement_request_item pri on (pr.code = pri.procurement_request_code)
		--			--left join dbo.procurement prc on prc.procurement_request_code = pr.code
		--			where asset_no = @p_code
		--			and pri.category_type = 'MOBILISASI'
		--			AND pr.status <> 'CANCEL'
		--			--and prc.unit_from = 'BUY'
		--)
		--begin
		--	if not exists
		--	(
		--		select	1
		--		from	dbo.purchase_order						po
		--				left join dbo.purchase_order_detail		pod on (pod.po_code							  = po.code)
		--				left join dbo.supplier_selection_detail ssd on (ssd.id								  = pod.supplier_selection_detail_id)
		--				left join dbo.quotation_review_detail	qrd on (qrd.id								  = ssd.quotation_detail_id)
		--				left join dbo.procurement				prc on (prc.code collate Latin1_General_CI_AS = qrd.reff_no)
		--				left join dbo.procurement				prc2 on (prc2.code							  = ssd.reff_no)
		--				left join dbo.procurement_request		pr on (pr.code								  = prc.procurement_request_code)
		--				left join dbo.procurement_request		pr2 on (pr2.code							  = prc2.procurement_request_code)
		--		where	po.status							  in ('APPROVE', 'CLOSED')
		--				and isnull(pr.asset_no, pr2.asset_no) = @p_code
		--				and isnull(pr.procurement_type, pr2.procurement_type) = 'MOBILISASI'
		--	)
		--	begin
		--		set @msg = N'V;Cannot proceed, because this asset is in mobilization process.' ;
		--	end ;
		--end

		select	@msg 'status' ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
