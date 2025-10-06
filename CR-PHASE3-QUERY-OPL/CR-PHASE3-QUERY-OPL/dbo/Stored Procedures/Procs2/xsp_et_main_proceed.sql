CREATE PROCEDURE dbo.xsp_et_main_proceed	
(
	@p_code						nvarchar(50)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)	
	,@p_mod_ip_address			nvarchar(15)
)

as
begin
	declare @msg						  nvarchar(max)
			,@et_amount					  decimal(18, 2)
			,@process_code				  nvarchar(50)
			,@agreement_external_no		  nvarchar(50)
			,@branch_code				  nvarchar(50)
			,@branch_name				  nvarchar(250)
			,@interface_remarks			  nvarchar(4000)
			,@req_date					  datetime
			,@client_name				  nvarchar(250)
			,@reff_approval_category_code nvarchar(50)
			,@request_code				  nvarchar(50)
			,@reff_dimension_code		  nvarchar(50)
			,@dimension_code			  nvarchar(50)
			,@dim_value					  nvarchar(50)
			,@url_path					  nvarchar(250)
			,@path						  nvarchar(250)
			,@approval_path				  nvarchar(4000) 
			,@validasi_last_invoice_date	nvarchar(max)=null
			,@validasi_pending_invoice		nvarchar(max)=null
			,@validasi_bast_date			nvarchar(max)=null
			,@refund_amount					decimal(18,2)
			,@bank_code						nvarchar(50)
			,@bank_account_no				nvarchar(50)
			,@bank_account_name				nvarchar(250)
			,@total_amount					decimal(18,2)
			,@total_amount_dif				decimal(18,2)
				
	begin try 
		select	@process_code		= isnull(am.agreement_sub_status, '')
				,@refund_amount		= isnull(et.refund_amount,0)
				,@bank_code			= isnull(et.bank_code,'')
				,@bank_account_no	= isnull(et.bank_account_no,'')
				,@bank_account_name	= isnull(et.bank_account_name,'')
				,@total_amount		= isnull(et.et_amount,0)
		from	dbo.et_main et
				inner join agreement_main am on (am.agreement_no = et.agreement_no)
		where	code = @p_code ;

		if exists
		(
			select	1
			from	dbo.et_main
			where	code		  = @p_code
					and et_status <> 'HOLD'
		)
		begin
			set @msg = 'Error data already proceed' ;
			raiserror(@msg, 16, 1) ;
		end ;


		-- Alif 27/08/2025 ERR.2508.000679
		if exists (
			select 1
			from dbo.et_main
			where code = @p_code
				and (file_name is null or ltrim(rtrim(file_name)) = ''
					 or file_path is null or ltrim(rtrim(file_path)) = '')
		)
		begin
			set @msg = N'Please Upload File.';
			raiserror(@msg, 16, -1);
			return;
		end;

		exec dbo.xsp_et_main_update_amount @p_code = @p_code,                       -- nvarchar(50)
		                                   @p_mod_date = @p_mod_date, -- datetime
		                                   @p_mod_by = @p_mod_by,                     -- nvarchar(15)
		                                   @p_mod_ip_address = @p_mod_ip_address,             -- nvarchar(15)
		                                   @p_total_amount = @total_amount_dif OUTPUT -- decimal(18, 2)

		
		if(isnull(@total_amount,0) <> isnull(@total_amount_dif,0))
		begin
		    set @msg = N'Please Klik Save To Update Information Amount' ;
			raiserror(@msg, 16, 1) ;
		end

		if (@refund_amount > 0)
		begin
			if (
				   @bank_code = ''
				   and	@bank_account_no = ''
				   and	@bank_account_name = ''
			   )
			begin
				set @msg = N'Please Input Bank Name, Bank Account No, and Bank Account Name For Refund To Customer.' ;

				raiserror(@msg, 16, 1) ;
			end ;
		end ;
        
		begin-- (sepria 21/04/2025:2504000068 - validasi hanya per asset saja untuk cover juga case yg billing scheme)

			select	@validasi_bast_date = string_agg((ags.fa_reff_no_01 + ' - ' + convert(nvarchar(50), ags.handover_bast_date, 103)),', ')
			from	dbo.et_main etm
					inner join dbo.et_detail etd on etd.et_code = etm.code and etd.is_terminate = '1'
					inner join dbo.agreement_asset ags on ags.asset_no = etd.asset_no and ags.agreement_no = etm.agreement_no
			where	etm.code = @p_code
			and		cast(etm.et_date as date) < cast(ags.handover_bast_date as date)

			if (@validasi_bast_date is not null)
			BEGIN
				SELECT '@validasi_bast_date_proceed', @validasi_bast_date
				SET @msg = 'Date Mush Be Greater Than Bast Date From This Assets: ' + @validasi_bast_date ;
				raiserror(@msg, 16, -1) ;
			end

			select	@validasi_pending_invoice = string_agg((ags.fa_reff_no_01 + ' - ' + inv.invoice_external_no),', ')
			from	dbo.et_main etm
					inner join dbo.et_detail etd on etd.et_code = etm.code and etd.is_terminate = '1'
					inner join dbo.agreement_asset ags on ags.asset_no = etd.asset_no and ags.agreement_no = etm.agreement_no
					inner join dbo.agreement_asset_amortization aaa on aaa.agreement_no = ags.agreement_no and aaa.asset_no = ags.asset_no and aaa.invoice_no is not null
					inner join dbo.invoice_detail invd on invd.agreement_no = aaa.agreement_no and invd.asset_no = aaa.asset_no and invd.billing_no = aaa.billing_no
					inner join dbo.invoice inv on inv.invoice_no = invd.invoice_no and inv.invoice_status = 'new'
			where	etm.code = @p_code

			if (@validasi_pending_invoice is not null)
			begin
				set @msg = N'Assets Have a Pending Invoice, Please Complete Invoice Transaction Before ET For This Assets And Invoice No: ' + @validasi_pending_invoice;
				raiserror(@msg, 16, -1) ;
			end
		
			--select	@validasi_last_invoice_date = string_agg( (ags.fa_reff_no_01 + ' - '+ convert(nvarchar(50), ags.invoice_date, 103)),', ')
			--from	dbo.et_main etm
			--		inner join dbo.et_detail etd on etd.et_code = etm.code and etd.is_terminate = '1'
			--		outer apply (
			--						select	ags.fa_reff_no_01, max(inv.invoice_date) 'invoice_date'
			--						from	dbo.agreement_asset ags
			--								inner join dbo.agreement_asset_amortization aaa on aaa.agreement_no = ags.agreement_no and aaa.asset_no = ags.asset_no and aaa.invoice_no is not null
			--								inner join dbo.invoice_detail invd on invd.agreement_no = aaa.agreement_no and invd.asset_no = aaa.asset_no and invd.billing_no = aaa.billing_no
			--								inner join dbo.invoice inv on inv.invoice_no = invd.invoice_no and inv.invoice_status in ('new', 'post', 'paid')
			--						where	ags.asset_no = etd.asset_no and ags.agreement_no = etm.agreement_no
			--						group by	ags.fa_reff_no_01
			--					) ags
			--where	etm.code = @p_code
			--and		cast(etm.et_date as date) < cast(ags.invoice_date as date)
			
			--if(@validasi_last_invoice_date is not null)
			--begin
			--	set @msg = 'Date Mush Be Greater Or Equal Than Last Invoice Date From This Assets: ' + @validasi_last_invoice_date ;
			--	raiserror(@msg, 16, 1) ;    
			--end
		end
						 
		if exists
		(
			select	1
			from	dbo.master_approval
			where	code			 = 'EARLY TERMINATION'
					and is_active	 = '1'
		)
		begin
			select	@branch_code = em.branch_code
					,@branch_name = em.branch_name
					,@client_name = am.client_name
					,@et_amount = em.et_amount
					,@agreement_external_no = am.agreement_external_no 
			from	dbo.et_main em
					inner join dbo.agreement_main am on (am.agreement_no = em.agreement_no)
			where	em.code = @p_code ;

			update dbo.et_main
			set		et_status		= 'ON PROCESS'
					,mod_by			= @p_mod_by
					,mod_date		= @p_mod_date
					,mod_ip_address	= @p_mod_ip_address
			where   code			= @p_code

			set @interface_remarks = 'Approval Early Termination ' + @agreement_external_no + ' - ' + @client_name ;
			set @req_date = dbo.xfn_get_system_date() ;

			select	@reff_approval_category_code = reff_approval_category_code
			from	dbo.master_approval
			where	code						 = 'EARLY TERMINATION' ;
			
			--select path di global param
			select	@url_path = value
			from	dbo.sys_global_param
			where	code = 'URL_PATH' ;

			select	@path = @url_path + value
			from	dbo.sys_global_param
			where	code = 'APVET'

			--set approval path
			set	@approval_path = @path + @p_code

			exec dbo.xsp_opl_interface_approval_request_insert @p_code						= @request_code output -- nvarchar(50)
															   ,@p_branch_code				= @branch_code
															   ,@p_branch_name				= @branch_name
															   ,@p_request_status			= N'HOLD'
															   ,@p_request_date				= @req_date
															   ,@p_request_amount			= @et_amount
															   ,@p_request_remarks			= @interface_remarks
															   ,@p_reff_module_code			= N'IFINOPL'
															   ,@p_reff_no					= @p_code
															   ,@p_reff_name				= N'EARLY TERMINATION APPROVAL'
															   ,@p_paths					= @approval_path
															   ,@p_approval_category_code	= @reff_approval_category_code
															   ,@p_approval_status			= N'HOLD'
															   --
															   ,@p_cre_date					= @p_mod_date
															   ,@p_cre_by					= @p_mod_by
															   ,@p_cre_ip_address			= @p_mod_ip_address
															   ,@p_mod_date					= @p_mod_date
															   ,@p_mod_by					= @p_mod_by
															   ,@p_mod_ip_address			= @p_mod_ip_address ;
					
			declare master_approval_dimension cursor for
			select 	reff_dimension_code
					,dimension_code
			from	dbo.master_approval_dimension
			where	approval_code = 'EARLY TERMINATION'

			open master_approval_dimension		
			fetch next from master_approval_dimension
			into @reff_dimension_code
				,@dimension_code
						
			while @@fetch_status = 0

			begin 

			exec dbo.xsp_get_table_value_by_dimension @p_dim_code		= @dimension_code
														,@p_reff_code	= @p_code
														,@p_reff_table	= 'ET_MAIN'
														,@p_output		= @dim_value output ;
 
			exec dbo.xsp_opl_interface_approval_request_dimension_insert @p_id					= 0
																		 ,@p_request_code		= @request_code
																		 ,@p_dimension_code		= @reff_dimension_code
																		 ,@p_dimension_value	= @dim_value
																		 --
																		 ,@p_cre_date			= @p_mod_date
																		 ,@p_cre_by				= @p_mod_by
																		 ,@p_cre_ip_address		= @p_mod_ip_address
																		 ,@p_mod_date			= @p_mod_date
																		 ,@p_mod_by				= @p_mod_by
																		 ,@p_mod_ip_address		= @p_mod_ip_address ;
						

			fetch next from master_approval_dimension
			into @reff_dimension_code
				,@dimension_code
			end
						
			close master_approval_dimension
			deallocate master_approval_dimension 
		end
		else
		begin
			set @msg = 'Please setting Master Approval';
			raiserror(@msg, 16, 1) ;
		end ;

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



