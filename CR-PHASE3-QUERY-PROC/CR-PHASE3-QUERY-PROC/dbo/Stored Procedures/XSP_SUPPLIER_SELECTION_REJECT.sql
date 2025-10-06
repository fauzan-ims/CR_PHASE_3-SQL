CREATE PROCEDURE [dbo].[XSP_SUPPLIER_SELECTION_REJECT]
(
	@p_id			   bigint
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@asset_no						nvarchar(50)
			,@category_type					nvarchar(50)
			,@supplier_selection_detail_id	int
			,@procurement_code				nvarchar(50)
			,@procurement_request_code		nvarchar(50)
			,@unit_from						nvarchar(15)

	begin try
		select	@asset_no			= isnull(pr.asset_no, pr2.asset_no)
				,@category_type		= isnull(pri.category_type, pri2.category_type)
				,@unit_from			= ssd.unit_from
		from	dbo.supplier_selection_detail		   ssd
				left join dbo.quotation_review_detail  qrd on (qrd.id								 = ssd.quotation_detail_id)
				left join dbo.procurement			   prc on (prc.code collate Latin1_General_CI_AS = qrd.reff_no)
				left join dbo.procurement			   prc2 on (prc2.code							 = ssd.reff_no)
				left join dbo.procurement_request	   pr on (pr.code								 = prc.procurement_request_code)
				left join dbo.procurement_request	   pr2 on (pr2.code								 = prc2.procurement_request_code)
				left join dbo.procurement_request_item pri on (pr.code								 = pri.procurement_request_code)
				left join dbo.procurement_request_item pri2 on (pr2.code							 = pri2.procurement_request_code)
		where	ssd.id = @p_id ;
		
		if(@asset_no is not null)
		begin
			begin --validasi 1
				if(@category_type <> 'ASSET')
				begin
					set @msg = 'Cannot cancel this data, because this data did not main asset.' ;
					raiserror(@msg, 16, 1) ;
				end
			end
			begin --validasi 2
				if exists(select 1 from dbo.supplier_selection_detail ssd
				left join dbo.quotation_review_detail  qrd on (qrd.id								 = ssd.quotation_detail_id)
				left join dbo.procurement			   prc on (prc.code collate Latin1_General_CI_AS = qrd.reff_no)
				left join dbo.procurement			   prc2 on (prc2.code							 = ssd.reff_no)
				left join dbo.procurement_request	   pr on (pr.code								 = prc.procurement_request_code)
				left join dbo.procurement_request	   pr2 on (pr2.code								 = prc2.procurement_request_code)
				where isnull(pr.asset_no, pr2.asset_no) =  @asset_no
				and ssd.supplier_selection_detail_status = 'POST'
				and ssd.unit_from = @unit_from)
				begin
					set @msg = 'Cannot cancel this data, because others data already proceed.' ;
					raiserror(@msg, 16, 1) ;
				end
			end

			--update interface purchase request
			update	dbo.proc_interface_purchase_request
			set		result_date	= dbo.xfn_get_system_date()
					,request_status = 'CANCEL'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address	= @p_mod_ip_address
			where	asset_no		= @asset_no ;

			
			declare curr_ss_detail cursor fast_forward read_only for
			select ssd.id
					,isnull(prc.code, prc2.code)
			from dbo.supplier_selection_detail ssd
			left join dbo.quotation_review_detail  qrd on (qrd.id								 = ssd.quotation_detail_id)
			left join dbo.procurement			   prc on (prc.code collate Latin1_General_CI_AS = qrd.reff_no)
			left join dbo.procurement			   prc2 on (prc2.code							 = ssd.reff_no)
			left join dbo.procurement_request	   pr on (pr.code								 = prc.procurement_request_code)
			left join dbo.procurement_request	   pr2 on (pr2.code								 = prc2.procurement_request_code)
			where isnull(pr.asset_no, pr2.asset_no) = @asset_no
			
			open curr_ss_detail
			
			fetch next from curr_ss_detail 
			into @supplier_selection_detail_id
				,@procurement_code
			
			while @@fetch_status = 0
			begin
				--update order request
			    update	dbo.supplier_selection_detail
				set		supplier_selection_detail_status = 'REJECT'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	id	= @supplier_selection_detail_id ;

				--update procurement
				update dbo.procurement
				set		status		= 'REJECT'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code = @procurement_code
			
			    fetch next from curr_ss_detail 
				into @supplier_selection_detail_id
					,@procurement_code
			end
			
			close curr_ss_detail
			deallocate curr_ss_detail

			--update procurement request
			update dbo.procurement_request
			set		status		= 'REJECT'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	asset_no		= @asset_no

		end
		else
		begin
			if exists
			(
				select	1
				from	dbo.supplier_selection_detail
				where	id									 = @p_id
						and supplier_selection_detail_status = 'HOLD'
			)
			begin
				update	dbo.supplier_selection_detail
				set		supplier_selection_detail_status = 'REJECT'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	id	= @p_id ;
			end ;
			else
			begin
				set @msg = 'Data already process' ;
				raiserror(@msg, 16, 1) ;
			end ;
		end

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
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
end ;
