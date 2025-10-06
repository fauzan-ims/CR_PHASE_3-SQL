CREATE PROCEDURE [dbo].[xsp_purchase_order_post]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@code					nvarchar(50)
			,@company_code			nvarchar(50)
			,@status				nvarchar(20)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@division_code			nvarchar(50)
			,@division_name			nvarchar(250)
			,@department_code		nvarchar(50)
			,@department_name		nvarchar(250)
			,@supplier_code			nvarchar(50)
			,@remark				nvarchar(4000)
			,@supplier_name			nvarchar(250)
			,@reff_no				nvarchar(50)
			,@id					bigint
			,@id_purchase			bigint
			,@eta_date				datetime
			,@unit_from				nvarchar(50)
			,@system_date			datetime
			,@item_name				nvarchar(250)
			,@asset_no				nvarchar(50)
			,@application_no		nvarchar(50)
			,@description_log		nvarchar(4000)
			,@date					datetime = dbo.xfn_get_system_date()

	begin try
		if exists(select 1 from dbo.purchase_order_detail where price_amount = 0 and order_quantity = 0 and po_code = @p_code)
		begin
			set @msg = 'Price amount and order quantitiy cannot be empty.'

			raiserror(@msg, 16, -1) ;
		end

		if exists(select 1 from dbo.purchase_order where is_termin = '1' and code = @p_code)
		begin
			if not exists(select 1 from dbo.term_of_payment where po_code = @p_code)
			begin
				set @msg = 'Term of payment cannot be empty.'
				raiserror(@msg, 16, -1) ;
			end
		end

		select	@status = po.status
		from	dbo.purchase_order po
		where	po.code = @p_code ;

		if (@status = 'ON PROCESS')
		begin
			update	dbo.purchase_order
			set		status			= 'APPROVE'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;


			--cursor purchase order
			declare c_purchase cursor for
			select	pod.id
			from	dbo.purchase_order po
					left join dbo.purchase_order_detail pod on (pod.po_code = po.code)
			where	po.code = @p_code 

			open	c_purchase

			fetch	c_purchase
			into	@id_purchase

			while	@@fetch_status = 0
			begin
				
				select	@reff_no			= isnull(pr.reff_no, pr2.reff_no)
						,@eta_date			= pod.eta_date
						,@supplier_code		= isnull(qrd.supplier_code, ssd.supplier_code)
						,@supplier_name		= isnull(qrd.supplier_name, ssd.supplier_name)
						,@unit_from			= isnull(prc.unit_from, prc2.unit_from)
				from	dbo.purchase_order_detail pod 
						left join dbo.supplier_selection_detail ssd on (ssd.id											 = pod.supplier_selection_detail_id)
						left join dbo.quotation_review_detail qrd on (qrd.id											 = ssd.quotation_detail_id)
						left join dbo.procurement prc on (prc.code collate Latin1_General_CI_AS							 = qrd.reff_no)
						left join dbo.procurement prc2 on (prc2.code													 = ssd.reff_no)
						left join dbo.procurement_request pr on (pr.code												 = prc.procurement_request_code)
						left join dbo.procurement_request pr2 on (pr2.code												 = prc2.procurement_request_code)
				where	pod.id = @id_purchase

				if (isnull(@reff_no, '') <> '')
				begin
					set	@system_date = dbo.xfn_get_system_date()

					exec dbo.xsp_proc_interface_purchase_order_update_insert @p_id				= @id output
																			,@p_purchase_code	= @reff_no
																			,@p_po_code			= @p_code
																			,@p_eta_po_date		= @eta_date
																			,@p_supplier_code	= @supplier_code
																			,@p_supplier_name	= @supplier_name
																			,@p_unit_from		= @unit_from
																			,@p_settle_date		= @system_date
																			,@p_job_status		= 'HOLD'
																			,@p_failed_remarks	= N''
																			,@p_cre_date		= @p_mod_date
																			,@p_cre_by			= @p_mod_by
																			,@p_cre_ip_address	= @p_mod_ip_address
																			,@p_mod_date		= @p_mod_date
																			,@p_mod_by			= @p_mod_by
																			,@p_mod_ip_address	= @p_mod_ip_address
					
				end

				fetch	c_purchase
				into	@id_purchase
			end
			
			close		c_purchase
			deallocate	c_purchase

		end ;
		else
		begin
			set @msg = 'Data already proceed' ;

			raiserror(@msg, 16, -1) ;
		end ;

		--begin
		--	select	@branch_code			= branch_code
		--			,@branch_name			= branch_name
		--			,@division_code			= division_code
		--			,@division_name			= division_name
		--			,@department_code		= department_code
		--			,@department_name		= department_name
		--			,@supplier_code			= supplier_code
		--			,@supplier_name			= supplier_name
		--			,@company_code			= company_code
		--			,@remark				= remark
		--	from	dbo.purchase_order
		--	where	code					= @p_code ;

		--	exec dbo.xsp_good_receipt_note_insert @p_code					= @code output
		--										  ,@p_company_code			= @company_code
		--										  ,@p_purchase_order_code	= @p_code
		--										  ,@p_receive_date			= @p_mod_date
		--										  ,@p_supplier_code			= @supplier_code
		--										  ,@p_supplier_name			= @supplier_name
		--										  ,@p_branch_code			= @branch_code
		--										  ,@p_branch_name			= @branch_name
		--										  ,@p_division_code			= @division_code
		--										  ,@p_division_name			= @division_name
		--										  ,@p_department_code		= @department_code
		--										  ,@p_department_name		= @department_name
		--										  ,@p_remark				= @remark
		--										  ,@p_status				= 'HOLD'
		--										  ,@p_cre_date				= @p_mod_date
		--										  ,@p_cre_by				= @p_mod_by
		--										  ,@p_cre_ip_address		= @p_mod_ip_address
		--										  ,@p_mod_date				= @p_mod_date
		--										  ,@p_mod_by				= @p_mod_by
		--										  ,@p_mod_ip_address		= @p_mod_ip_address ;
		--end ;
	
			
		declare curr_log cursor fast_forward read_only for
		select	b.reff_no
		from	dbo.purchase_order_detail				 a
				inner join dbo.supplier_selection_detail b on a.supplier_selection_detail_id = b.id
		where	a.po_code = @p_code ;

		open curr_log
		
		fetch next from curr_log 
		into @reff_no
		
		while @@fetch_status = 0
		begin
			select	distinct
					@asset_no	= d.asset_no
					,@item_name	= a.item_name
			from	dbo.supplier_selection_detail		  a
					left join dbo.quotation_review_detail b on a.reff_no = b.quotation_review_code collate Latin1_General_CI_AS
					left join dbo.procurement			  c on c.code	 = isnull(b.reff_no, a.reff_no)collate Latin1_General_CI_AS
					inner join dbo.procurement_request	  d on d.code	 = c.procurement_request_code
			where	a.reff_no = @reff_no ;

			select @application_no = isnull(application_no,'') 
			from ifinopl.dbo.application_asset 
			where asset_no = @asset_no

			if (@application_no <> '')
			begin
				set @description_log = 'Purchase order approve, Asset no : ' + @asset_no + ' - ' + @item_name
		
				exec ifinopl.dbo.xsp_application_log_insert @p_id					= 0
															,@p_application_no		= @application_no
															,@p_log_date			= @date
															,@p_log_description		= @description_log
															,@p_cre_date			= @p_mod_date
															,@p_cre_by				= @p_mod_by
															,@p_cre_ip_address		= @p_mod_ip_address
															,@p_mod_date			= @p_mod_date
															,@p_mod_by				= @p_mod_by
															,@p_mod_ip_address		= @p_mod_ip_address
			end
		    			
		    fetch next from curr_log 
			into @reff_no
		end
		
		close curr_log
		deallocate curr_log
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

