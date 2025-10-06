CREATE PROCEDURE dbo.xsp_work_order_approve
(
	@p_code							nvarchar(50)
	--,@p_is_claim_approve			nvarchar(1) = ''
	--,@p_claim_approve_claim_date	datetime	= null
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max)			
			,@status							nvarchar(50)	
			,@code_interface_payment			nvarchar(50)					
			,@interface_remarks					nvarchar(4000)			
			,@reff_approval_category_code		nvarchar(50)						
			,@approval_code						nvarchar(50)		
			,@reff_dimension_code				nvarchar(50)				
			,@reff_dimension_name				nvarchar(250)				
			,@dimension_code					nvarchar(50)			
			,@table_name						nvarchar(50)		
			,@primary_column					nvarchar(50)			
			,@dim_value							nvarchar(50)	
			,@value_approval					nvarchar(250)			
			,@path								nvarchar(250)
			,@req_date							datetime	
			,@request_code						nvarchar(50)		
			,@payment_source					nvarchar(50)			
			,@payment_source_no					nvarchar(250)			
			,@url_path							nvarchar(250)	
			,@approval_path						nvarchar(4000)		
			,@requestor_code					nvarchar(50)			
			,@payment_req_code					nvarchar(50)			
			,@register_code						nvarchar(4000)		
			,@payment_request_code_for_validate	nvarchar(4000)							
			,@claim_type						nvarchar(50)		
			,@is_claim_approve					nvarchar(1)			
			,@claim_date						DATETIME		
			,@company_code					nvarchar(50)			
			,@maintenance_code				nvarchar(50)				
			,@remarks						nvarchar(4000)		
			,@asset_code					nvarchar(50)			
			,@branch_code					nvarchar(50)			
			,@branch_name					nvarchar(250)			
			,@code_interface				nvarchar(50)				
			,@payment_amount				decimal(18, 2)				
			,@sp_name						nvarchar(250)		
			,@debet_or_credit				nvarchar(10)				
			,@gl_link_code					nvarchar(50)			
			,@transaction_name				nvarchar(250)				
			,@orig_amount_cr				decimal(18, 2)				
			,@orig_amount_db				decimal(18, 2)				
			,@amount						decimal(18, 2)		
			,@return_value					decimal(18, 2)			
			,@year							nvarchar(4)	
			,@month							nvarchar(2)	
			,@code							nvarchar(50)	
			,@vendor_name					nvarchar(250)			
			,@requestor_name				nvarchar(250)				
			,@adress						nvarchar(4000)		
			,@phone_no						nvarchar(15)		
			,@service_code					nvarchar(50)			
			,@service_name					nvarchar(250)			
			,@actual_km						bigint		
			,@service_type					nvarchar(50)			
			,@date							datetime	
			,@reff_remark					nvarchar(4000)			
			,@item_name						nvarchar(250)		
			,@work_date						datetime		
			,@hour_meter					int			
			,@id_asset_maintenance_schedule bigint								
			,@trx_no						nvarchar(50)		
			,@is_maintenance				nvarchar(1)				
			,@code_payment_request			nvarchar(50)					
			,@pph_amount_payment			decimal(18, 2)					
			,@ppn_amount_payment			decimal(18, 2)					
			,@payment_amount_payment		decimal(18, 2)						
			,@total_amount_payment			decimal(18, 2)					
			,@payment_remark				nvarchar(4000)				
			,@base_amount					decimal(18, 2)			
			,@base_amount_db				decimal(18, 2)				
			,@base_amount_cr				decimal(18, 2)				
			,@reff_source_name				nvarchar(250)				
			,@gllink_trx_code				nvarchar(50)				
			,@debit_or_credit				nvarchar(50)				
			,@category_code					nvarchar(50)			
			,@purchase_price				decimal(18, 2)				
			,@is_valid						int		
			,@x_code						nvarchar(50)		
			,@exch_rate						decimal(18, 2) = 1		
			,@detail_remark					nvarchar(250)			
			,@id_detail						int		
			,@vendor_code					nvarchar(50)			
			,@vendor_bank_name				nvarchar(250)				
			,@vendor_bank_account_no		nvarchar(50)						
			,@vendor_bank_account_name		nvarchar(250)						
			,@is_reimburse					nvarchar(1)			
			,@ppn_amount					decimal(18, 2)			
			,@pph_amount					decimal(18, 2)			
			,@agreement_no					nvarchar(50)			
			,@asset_no						nvarchar(50)		
			,@client_no						nvarchar(50)		
			,@client_name					nvarchar(250)			
			,@description_request			nvarchar(250)					
			,@wod_id						bigint		
			,@quantity						int		
			,@remark						nvarchar(4000)		
			,@process_code					nvarchar(50)			
			,@maintenance_type				nvarchar(50)				
			,@plat_no						nvarchar(50)		
			,@invoice_no					nvarchar(50)			
			,@faktur_no						nvarchar(50)		
			,@vendor_npwp					nvarchar(20)			
			,@income_type					nvarchar(250)			
			,@income_bruto_amount			decimal(18, 2)					
			,@tax_rate						decimal(5, 2)		
			,@ppn_pph_amount				decimal(18, 2)				
			,@transaction_code				nvarchar(50)				
			,@ppn_pct						decimal(9, 6)		
			,@pph_pct						decimal(9, 6)		
			,@vendor_type					nvarchar(25)			
			,@pph_type						nvarchar(20)		
			,@total_amount					decimal(18, 2)			
			,@remarks_tax					nvarchar(4000)			
			,@spk_no						nvarchar(50)		
			,@bank_name						nvarchar(250)		
			,@bank_account_no				nvarchar(50)				
			,@bank_account_name				nvarchar(250)				
			,@maintenance_by				nvarchar(50)				
			,@branch_code_asset				nvarchar(50)				
			,@branch_name_asset				nvarchar(250)				
			,@agreement_external_no			nvarchar(50)					
			,@faktur_no_invoice				nvarchar(50)	-- (+) Ari 2023-12-18			
			,@faktur_date					datetime			
			,@faktur_date_source			datetime					
			,@invoice_name					nvarchar(250)			
			,@journal_code					nvarchar(50)			
			,@journal_date					datetime			
			,@journal_remark				nvarchar(4000)				
			,@source_name					nvarchar(250)			
			,@faktur_jurnal					nvarchar(50)			
			,@last_meter					int			
			,@service_date					datetime			
			,@last_km_service				int				
			,@payment_to					nvarchar(250)			
			,@invoice_date					datetime			
			,@value1						int		
			,@value2						int		
			,@date_journal					datetime = dbo.xfn_get_system_date()			
			,@vendor_nitku					NVARCHAR(50)			
			,@vendor_npwp_ho				NVARCHAR(50)				


	begin try
		--if @p_is_claim_approve = 'T'
		--	set @p_is_claim_approve = '1' ;
		--else
		--	set @p_is_claim_approve = '0' ;

		select	@status					   = wo.status
				,@company_code			   = wo.company_code
				,@maintenance_code		   = wo.maintenance_code
				,@asset_code			   = wo.asset_code
				,@branch_code			   = mnt.branch_code
				,@branch_name			   = mnt.branch_name
				,@vendor_code			   = mnt.vendor_code
				,@vendor_name			   = mnt.vendor_name
				,@requestor_name		   = ass.requestor_name
				,@adress				   = mnt.vendor_address
				,@phone_no				   = mnt.vendor_phone
				,@date					   = mnt.transaction_date
				,@item_name				   = ass.item_name
				,@hour_meter			   = mnt.hour_meter
				,@actual_km				   = wo.actual_km
				,@service_type			   = mnt.service_type
				,@work_date				   = wo.work_date
				,@vendor_bank_name		   = mnt.vendor_bank_name
				,@vendor_bank_account_no   = mnt.vendor_bank_account_no
				,@vendor_bank_account_name = mnt.vendor_bank_account_name
				,@vendor_npwp			   = mnt.vendor_npwp
				,@is_reimburse			   = mnt.is_reimburse
				,@payment_amount		   = wo.payment_amount
				,@ppn_amount			   = wo.total_ppn_amount
				,@pph_amount			   = wo.total_pph_amount
				,@agreement_no			   = ass.agreement_no
				,@asset_no				   = ass.asset_no
				,@client_no				   = ass.client_no
				,@client_name			   = ass.client_name
				,@remark				   = wo.remark
				,@maintenance_type		   = mnt.service_type
				,@plat_no				   = avh.plat_no
				,@invoice_no			   = wo.invoice_no
				,@vendor_type			   = mnt.vendor_type
				,@spk_no				   = mnt.spk_no
				,@bank_name				   = mnt.bank_name
				,@bank_account_no		   = mnt.bank_account_no
				,@bank_account_name		   = mnt.bank_account_name
				,@maintenance_by		   = wo.maintenance_by
				,@branch_code_asset		   = ass.branch_code
				,@branch_name_asset		   = ass.branch_name
				,@agreement_external_no	   = isnull(ass.agreement_external_no, ass.code)
				,@faktur_date_source	   = isnull(wo.faktur_date,'')
				,@last_meter			   = wo.actual_km
				,@last_km_service		   = wo.last_km_service
				,@service_date			   = wo.work_date
				,@payment_to			   = mv.name
				,@invoice_date			   = isnull(wo.invoice_date,'')
				--
				,@payment_amount			= wo.payment_amount
				,@claim_type				= mnt.service_type
				,@is_claim_approve			= wo.is_claim_approve
				,@claim_date				= wo.claim_approve_claim_date
		from	dbo.work_order						wo
				left join dbo.maintenance			mnt on (mnt.code	   = wo.maintenance_code)
				left join ifinbam.dbo.master_vendor mv on (mnt.vendor_code = mv.code)
				left join dbo.asset					ass on (ass.code	   = mnt.asset_code)
				left join dbo.asset_vehicle			avh on (avh.asset_code = ass.code)
		where	wo.code = @p_code ;

		--(+) sepria 28-05-2025: validasi jika di reimburse tp status asset tidak di rental
		if(@is_reimburse = '1' and isnull(@agreement_no,'') = '')
		begin
		    set @msg = N'Work Order Cannot Be Reimburse Because Asset Is Not Leased' ;
			raiserror(@msg, 16, -1) ;
		end
        
		select	@faktur_no			= faktur_no
				,@faktur_no_invoice = invoice_no	-- (+) Ari 2023-12-18 ket : get invoice
		from	dbo.work_order
		where	code = @p_code ;

		select	@value1 = value
		from	dbo.sys_global_param
		where	code = 'WOINV' ;

		select	@value2 = value
		from	dbo.sys_global_param
		where	code = 'WOFKT' ;

		if(@invoice_date < dateadd(month, -@value1, dbo.xfn_get_system_date()))
		begin
			if(@value1 <> 0)
			begin
				set @msg = N'Invoice date cannot be back dated for more than ' + convert(varchar(1), @value1) + ' months.' ;

				raiserror(@msg, 16, -1) ;
			end
			else if (@value1 = 0)
			begin
				set @msg = N'Invoice date must be equal than system date.' ;

				raiserror(@msg, 16, -1) ;
			end
		end

		if(@faktur_date < dateadd(month, -@value2, dbo.xfn_get_system_date()))
		begin
			if(@value2 <> 0)
			begin
				set @msg = N'Faktur date cannot be back dated for more than ' + convert(varchar(1), @value2) + ' months.' ;

				raiserror(@msg, 16, -1) ;
			end
			else if (@value2 = 0)
			begin
				set @msg = N'Faktur date must be equal than system date.' ;

				raiserror(@msg, 16, -1) ;
			end
		end

		if(@invoice_date = '')
		begin
			set @msg = N'Please input invoice date.' ;

			raiserror(@msg, 16, -1) ;
		end

		if(@faktur_date_source = '')
		begin
			set @msg = N'Please input faktur date.' ;

			raiserror(@msg, 16, -1) ;
		end

		--if(month(@invoice_date) < month(dbo.xfn_get_system_date()))
		--begin
		--	set @msg = N'Invoice month must be equal than system date.' ;

		--	raiserror(@msg, 16, -1) ;
		--end

		if(@invoice_date > dbo.xfn_get_system_date())
		begin
			set @msg = N'Invoice date must be equal or less than system date.' ;

			raiserror(@msg, 16, -1) ;
		end

		if(@faktur_date_source > dbo.xfn_get_system_date())
		begin
			set @msg = N'Faktur date must be equal or less than system date.' ;

			raiserror(@msg, 16, -1) ;
		end

		if (isnull(@faktur_no, '') = '')
		   and	(@pph_amount > 0)
		begin
			set @msg = N'Faktur Number cant be empty.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.work_order_detail
			where	work_order_code				 = @p_code
					and isnull(service_code, '') = ''
		)
		begin
			set @msg = N'Please add item service in work order detail.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		--sepria 18062024: jika nilai Payment belum di input, munculkan validasi jangan erorr sistem
		if (isnull(@payment_amount,0) = 0)
		begin
			set @msg = N'Please Input Service Amount in work order detail.' ;
			raiserror(@msg, 16, -1) ;
		end
        --

		if (@claim_type = 'CLAIM')
		begin
			if(@is_claim_approve = '0')
			begin
				set @msg = 'Please confirm the claim has been approved by insurance company.';
				raiserror(@msg ,16,-1);
			end
			
			if(@is_claim_approve = '1')
			begin
				if(@claim_date is null)
				begin
					set @msg = 'Please input insurance approve date.';
					raiserror(@msg ,16,-1);
				end
				else
				begin
					if(@claim_date > dbo.xfn_get_system_date())
					begin
						set @msg = 'Insurance Approve date must be lest or equal than system date.';
						raiserror(@msg ,16,-1);
					end
				end
			end
		end

		if exists
		(
			select	1
			from	dbo.work_order_detail
			where	work_order_code				 = @p_code
					and isnull(service_code, '') = ''
		)
		begin
			set @msg = N'Please add item service in work order detail.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		--sepria 18062024: jika nilai Payment belum di input, munculkan validasi jangan erorr sistem
		if (isnull(@payment_amount,0) = 0)
		begin
			set @msg = N'Please Input Service Amount in work order detail.' ;
			raiserror(@msg, 16, -1) ;
		end

		select	@requestor_code		= code
				,@requestor_name	= name
		from	ifinsys.dbo.sys_employee_main
		where	code = @p_mod_by ;

		--if (@status = 'ON CHECK')
		begin
			select	@url_path = value
			from	dbo.sys_global_param
			where	code = 'URL_PATH' ;

			select @path = value 
			from sys_global_param
			WHERE code = 'PATHWO'

			set @interface_remarks = 'Approval work order for ' + @p_code + ', branch : ' + @branch_name + ' .';
			set @req_date = dbo.xfn_get_system_date() ;

			select	@reff_approval_category_code = reff_approval_category_code
			from	dbo.master_approval
			where	code						 = 'APVWO' ;

			--set approval path
			set	@approval_path = @url_path + @path + @p_code

			exec dbo.xsp_ams_interface_approval_request_insert @p_code						= @request_code output
															   ,@p_branch_code				= @branch_code
																,@p_branch_name				= @branch_name
																,@p_request_status			= N'HOLD'
																,@p_request_date			= @req_date
																,@p_request_amount			= @payment_amount
																,@p_request_remarks			= @interface_remarks
																,@p_reff_module_code		= N'IFINAMS'
																,@p_reff_no					= @p_code
																,@p_reff_name				= N'WORK ORDER APPROVAL'
																,@p_paths					= @approval_path
																,@p_approval_category_code	= @reff_approval_category_code
																,@p_approval_status			= N'HOLD'
																,@p_requestor_code			= @requestor_code
																,@p_requestor_name			= @requestor_name
																,@p_expired_date			= @date
																,@p_cre_date				= @p_mod_date
																,@p_cre_by					= @p_mod_by
																,@p_cre_ip_address			= @p_mod_ip_address
																,@p_mod_date				= @p_mod_date
																,@p_mod_by					= @p_mod_by
																,@p_mod_ip_address			= @p_mod_ip_address


			declare curr_appv cursor fast_forward read_only for
			select 	approval_code
					,reff_dimension_code
					,reff_dimension_name
					,dimension_code
			from	dbo.master_approval_dimension
			where	approval_code = 'APVWO'
			
			open curr_appv
			
			fetch next from curr_appv 
			into @approval_code
				,@reff_dimension_code
				,@reff_dimension_name
				,@dimension_code
			
			while @@fetch_status = 0
			begin
				select	@table_name					 = table_name
						,@primary_column			 = primary_column
				from	dbo.sys_dimension
				where	code						 = @dimension_code

				exec dbo.xsp_get_table_value_by_dimension @p_dim_code		= @dimension_code
															,@p_reff_code	= @maintenance_code
															,@p_reff_table	= 'MAINTENANCE'
															,@p_output		= @dim_value output ;
				
				exec dbo.xsp_ams_interface_approval_request_dimension_insert @p_id					= 0
																			 ,@p_request_code		= @request_code
																			 ,@p_dimension_code		= @reff_dimension_code
																			 ,@p_dimension_value	= @dim_value
																			 ,@p_cre_date			= @p_mod_date
																			 ,@p_cre_by				= @p_mod_by
																			 ,@p_cre_ip_address		= @p_mod_ip_address
																			 ,@p_mod_date			= @p_mod_date
																			 ,@p_mod_by				= @p_mod_by
																			 ,@p_mod_ip_address		= @p_mod_ip_address ;
				
			
			    fetch next from curr_appv 
				into @approval_code
					,@reff_dimension_code
					,@reff_dimension_name
					,@dimension_code
			end
			
			close curr_appv
			deallocate curr_appv

			update	dbo.work_order
			set		status						= 'ON PROCESS'
					--
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address
			where	code						= @p_code ;

			update dbo.asset
			set		wo_no			= @maintenance_code
					,wo_status		= 'ON WORKSHOP'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @asset_code ;
		end ;
		--else
		--begin
		--	set @msg = 'Data already proceed' ;
		--	raiserror(@msg, 16, -1) ;
		--end ;

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
