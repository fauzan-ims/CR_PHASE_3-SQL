CREATE PROCEDURE dbo.xsp_insurance_policy_main_approve
(
	@p_code							nvarchar(50)
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
			,@remarks							nvarchar(4000)	
			,@interface_remarks					nvarchar(4000)			
			,@reff_approval_category_code		nvarchar(50)						
			,@approval_code						nvarchar(50)		
			,@reff_dimension_code				nvarchar(50)				
			,@reff_dimension_name				nvarchar(250)				
			,@dimension_code					nvarchar(50)			
			,@table_name						nvarchar(50)		
			,@primary_column					nvarchar(50)			
			,@dim_value							nvarchar(50)	
			,@process_code						nvarchar(50)		
			,@value_approval					nvarchar(250)			
			,@path								nvarchar(250)
			,@req_date							datetime	
			,@request_code						nvarchar(50)		
			,@payment_source					nvarchar(50)			
			,@payment_source_no					nvarchar(250)			
			,@url_path							nvarchar(250)	
			,@approval_path						nvarchar(4000)		
			,@payment_remark					nvarchar(4000)			
			,@requestor_code					nvarchar(50)			
			,@requestor_name					nvarchar(250)			
			,@payment_req_code					nvarchar(50)			
			,@invoice_no						nvarchar(50)		
			,@register_code						nvarchar(4000)		
			,@payment_request_code_for_validate	nvarchar(4000)							
			,@maintenance_code					nvarchar(50)			
			,@claim_type						nvarchar(50)		
			,@asset_code						nvarchar(50)		
			--								
			,@policy_payment_type			nvarchar(5)					
			,@insurance_code				nvarchar(50)				
			,@branch_code					nvarchar(50)			
			,@branch_name					nvarchar(250)			
			,@total_premi_buy_amount		decimal(18, 2)						
			,@bank_name						nvarchar(250)		
			,@bank_account_no				nvarchar(50)				
			,@bank_account_name				nvarchar(250)				
			,@payment_remarks				nvarchar(4000)				
			,@system_date					datetime	   = dbo.xfn_get_system_date()		
			,@payment_request_code			nvarchar(50)					
			,@fa_code						nvarchar(50)		
			,@fa_name						nvarchar(250)		
			,@sp_name						nvarchar(250)		
			,@debet_or_credit				nvarchar(10)				
			,@orig_amount					decimal(18, 2)			
			,@payment_amount				decimal(18, 2)				
			,@gl_link_code					nvarchar(50)			
			,@currency						nvarchar(3)		
			,@return_value					decimal(18, 2)			
			,@tax_file_type					nvarchar(10)			
			,@tax_file_no					nvarchar(50)			
			,@max_year						int		
			,@tax_file_name					nvarchar(250)			
			,@policy_eff_date				datetime				
			,@policy_exp_date				datetime				
			,@year_periode					int			
			,@period_eff_date				datetime				
			,@period_exp_date				datetime				
			,@sell_amount					decimal(18, 2)			
			,@initial_discount_amount		decimal(18, 2)						
			,@buy_amount					decimal(18, 2)			
			,@adjustment_discount_amount	decimal(18, 2)							
			,@adjustment_buy_amount			decimal(18, 2)					
			,@total_amount					decimal(18, 2)			
			,@ppn_amount					decimal(18, 2)			
			,@pph_amount					decimal(18, 2)			
			,@total_payment_amount			decimal(18, 2)					
			,@code_payment_request			nvarchar(50)					
			,@total_buy_amount				decimal(18,2)				
			,@payment_name					nvarchar(50)			
			,@prepaid_no					nvarchar(50)			
			,@total_net_premi_amount		decimal(18,2)						
			,@usefull						int		
			,@monthly_amount				decimal(18,2)				
			,@counter						int		
			,@sisa							decimal(18,2)	
			,@amount						decimal(18,2)		
			,@date_prepaid					datetime			
			,@invoice_code					nvarchar(50)			
			,@reff_remark					nvarchar(4000)			
			,@date							datetime	
			,@agreement_no					nvarchar(50)			
			,@client_name					nvarchar(250)			
			,@remarks_journal				nvarchar(4000)				
			,@transaction_name				nvarchar(250)				
			,@policy_no						nvarchar(50)		
			,@insured_name					nvarchar(250)			
			,@faktur_no						nvarchar(50)		
			,@vendor_npwp					nvarchar(20)			
			,@income_type					nvarchar(250)			
			,@income_bruto_amount			decimal(18,2)					
			,@tax_rate						decimal(5,2)		
			,@ppn_pph_amount				decimal(18,2)				
			,@transaction_code				nvarchar(50)				
			,@ppn_pct						decimal(9,6)		
			,@pph_pct						decimal(9,6)		
			,@pph_type						nvarchar(20)		
			,@vendor_code					nvarchar(50)			
			,@vendor_name					nvarchar(250)			
			,@adress						nvarchar(4000)		
			,@remarks_tax					nvarchar(4000)			
			,@branch_code_asset				nvarchar(50)				
			,@branch_name_asset				nvarchar(250)				
			,@agreement_external_no			nvarchar(50)					
			,@agreement_fa_code				nvarchar(50)				
			,@faktur_date					datetime			
			,@journal_code					nvarchar(50)			
			,@journal_date					datetime			
			,@source_name					nvarchar(250)			
			,@journal_remark				nvarchar(4000)				
			,@orig_amount_db				decimal(18,2)				
			,@orig_amount_cr				decimal(18,2)				
			,@value1						int		
			,@value2						int		
			,@invoice_date					datetime			
			,@cre_by						nvarchar(50)		
			,@ext_vendor_nitku				nvarchar(50)				
			,@ext_vendor_npwp_pusat			nvarchar(50)					


	begin try
		select	@requestor_code		= code
				,@requestor_name	= name
		from	ifinsys.dbo.sys_employee_main
		where	code = @p_mod_by ;

		select @branch_code					= ipm.branch_code
 			   ,@branch_name				= ipm.branch_name	
 			   ,@insurance_code				= ipm.insurance_code
 			   ,@payment_remarks			= 'Payment Policy insurance ' + isnull(ipm.policy_no, '') + ' To ' + mi.insurance_name  
 			   ,@currency					= ipm.currency_code 											
 			   ,@policy_payment_type		= ipm.policy_payment_type
 			   ,@policy_eff_date			= ipm.policy_eff_date
 			   ,@policy_exp_date			= ipm.policy_exp_date
 			   ,@policy_no					= ipm.policy_no
 			   ,@invoice_code				= ipm.invoice_no
 			   ,@insured_name				= ipm.insured_name
			   ,@faktur_date				= ipm.faktur_date
			   ,@invoice_date				= ipm.invoice_date
			   ,@cre_by						= ipm.cre_by
				,@status			= policy_payment_status
				,@payment_amount	= total_premi_buy_amount
 		from	dbo.insurance_policy_main ipm
 				inner join dbo.master_insurance mi on (mi.code = ipm.insurance_code)
 		where   ipm.code = @p_code

		select	@value1 = value
		from	dbo.sys_global_param
		where	CODE = 'INSINV' ;

		select	@value2 = value
		from	dbo.sys_global_param
		where	CODE = 'INSINV' ;
        
		if(@cre_by not like '%MIG%')
		begin
			if(@invoice_date < dateadd(month, -@value1, dbo.xfn_get_system_date()))
			begin
				if(@value1 <> 0)
				begin
					set @msg = N'Realization invoice date cannot be back dated for more than ' + convert(varchar(1), @value1) + ' months.' ;

					raiserror(@msg, 16, -1) ;
				end
				else if (@value1 = 0)
				begin
					set @msg = N'Realization invoice date must be equal than system date.' ;

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
		end
 
 		-- Hari - 19.Jul.2023 05:08 PM --	perubahan cara ambil amount by invoice no
 		select	@total_premi_buy_amount = isnull(sum(ipac.buy_amount),0)
 		from	dbo.insurance_policy_asset					   ipa
 				inner join dbo.insurance_policy_asset_coverage ipac on ipac.register_asset_code = ipa.code
 		where	policy_code		 = @p_code
 				and invoice_code = @invoice_code 
 				--and	ipac.coverage_type = 'NEW' -- (+) Ari 2024-01-03 ket : hanya yg New yg dibayar
 
 		IF(@total_premi_buy_amount = 0)
 		BEGIN
 			set @msg = 'Premi amount must be greater than 0';
 			raiserror(@msg, 16, -1) ;
         end
 
 	
 		select top 1  @payment_name		  = mis.insurance_name
 					 ,@bank_name           = mib.bank_name
 			         ,@bank_account_no     = mib.bank_account_no
 			         ,@bank_account_name   = mib.bank_account_name
 		from dbo.master_insurance_bank mib
 		inner join dbo.master_insurance mis on mis.code = mib.insurance_code
 		where mib.insurance_code = @insurance_code and mib.is_default = '1' 
 	
 		if (@bank_name is null)
 		begin
 			set @msg = 'Please setting default insurance bank' ;
 			raiserror(@msg, 16, -1) ;
 		end
          
 		select @faktur_no = faktur_no
 		from dbo.insurance_policy_main
 		where code = @p_code

		if exists
		(
			select	1
			from	dbo.insurance_policy_main					   a
					inner join dbo.insurance_policy_asset		   b on b.policy_code		  = a.code
					inner join dbo.insurance_policy_asset_coverage c on c.register_asset_code = b.code
			where	a.code							  = @p_code
					and isnull(c.master_tax_code, '') = ''
		)
		begin
			set @msg = N'Please input tax in coverage first.' ;

			raiserror(@msg, 16, -1) ;
		end ;
 		
 		--validasi untuk faktur number agar tidak bisa kosong jika pph amount ada nilainya 
 		if (ISNULL(@faktur_no,'') = '') AND (@pph_amount > 0)
 		begin
 			set @msg = 'Faktur Number cant be empty.';
 			raiserror(@msg ,16,-1);
 		end
 
 		-- (+) Ari 2024-01-03 ket : validasi invoice tidak boleh kosong
 		if(isnull(@invoice_code,'') = '')
 		begin
 			set @msg = 'Invoice Number cant be empty.';
 			raiserror(@msg ,16,-1);
 		end	

		if (@status = 'HOLD')
		begin
			select	@url_path = value
			from	dbo.sys_global_param
			where	code = 'URL_PATH' ;

			select @path = value 
			from sys_global_param
			WHERE code = 'PATHINS'

			set @interface_remarks = 'Approval insurance for ' + @policy_no + ', branch : ' + @branch_name + ' .';
			set @req_date = dbo.xfn_get_system_date() ;

			select	@reff_approval_category_code = reff_approval_category_code
			from	dbo.master_approval
			where	code						 = 'APVINS' ;

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
																,@p_reff_name				= N'INSURANCE APPROVAL'
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
			where	approval_code = 'APVINS'
			
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
															,@p_reff_code	= @p_code
															,@p_reff_table	= 'INSURANCE_POLICY_MAIN'
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

			update	dbo.insurance_policy_main
			set		policy_payment_status	= 'ON PROCESS'
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code = @p_code ;
		end ;
		else
		begin
			set @msg = 'Data already proceed' ;
			raiserror(@msg, 16, -1) ;
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