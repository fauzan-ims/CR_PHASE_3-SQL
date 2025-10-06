CREATE PROCEDURE dbo.xsp_insurance_policy_main_insert
(
	@p_code						 nvarchar(50) output
	,@p_sppa_code				 nvarchar(50)
	,@p_register_code			 nvarchar(50)
	,@p_branch_code				 nvarchar(50)
	,@p_branch_name				 nvarchar(250)
	,@p_source_type				 nvarchar(10)
	,@p_policy_status			 nvarchar(10)
	,@p_policy_payment_status	 nvarchar(10)
	,@p_insured_name			 nvarchar(250)
	,@p_insured_qq_name			 nvarchar(250)
	,@p_policy_payment_type		 nvarchar(5)
	,@p_object_name				 nvarchar(4000)
	--,@p_sum_insured				 decimal
	,@p_insurance_code			 nvarchar(50)
	,@p_insurance_type			 nvarchar(10)
	--,@p_collateral_type			 nvarchar(50) --(+)ucup 05-05-2020 *field ada di tabel, sp ini di panggil di sp xsp_insurance_register_existing_post
	--,@p_collateral_category_code nvarchar(50)
	--,@p_depreciation_code		 nvarchar(50)
	--,@p_occupation_code			 nvarchar(50)
	--,@p_region_code				 nvarchar(50) 
	,@p_currency_code			 nvarchar(3)
	,@p_cover_note_no			 nvarchar(50)
	,@p_cover_note_date			 datetime
	,@p_policy_no				 nvarchar(50)
	,@p_policy_eff_date			 datetime
	,@p_policy_exp_date			 datetime
	,@p_eff_rate				 decimal(9, 6)
	,@p_file_name				 nvarchar(250)
	,@p_paths					 nvarchar(250)
	,@p_invoice_no				 nvarchar(50)
	,@p_invoice_date			 datetime
	,@p_from_year				 int
	,@p_to_year					 int
	--,@p_total_premi_sell_amount	 decimal
	,@p_total_premi_buy_amount	 decimal
	,@p_total_discount_amount	 decimal
	,@p_total_net_premi_amount	 decimal
	,@p_stamp_fee_amount		 decimal
	,@p_admin_fee_amount		 decimal
	,@p_total_adjusment_amount	 decimal
	,@p_is_policy_existing		 nvarchar(1)
	,@p_endorsement_count		 int
	--,@p_fa_code					 nvarchar(50)
	--
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(15)
	,@p_cre_ip_address			 nvarchar(15)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg				  nvarchar(max)
			,@year				  nvarchar(4)
			,@month				  nvarchar(2)
			,@batch_currency_code nvarchar(3) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;
	
	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output 
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N'' 
												,@p_custom_prefix = N'AMSIPM'  
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = N'INSURANCE_POLICY_MAIN' 
												,@p_run_number_length = 6 
												,@p_delimiter = N'.'  
												,@p_run_number_only = N'0'  

	begin try
		if @p_is_policy_existing = 'T'
			set @p_is_policy_existing = '1' ;
		else
			set @p_is_policy_existing = '0' ;

		insert into insurance_policy_main
		(
			code
			,sppa_code
			,register_code
			,branch_code
			,branch_name
			,source_type
			,policy_status
			,policy_payment_status
			,insured_name
			,insured_qq_name
			,policy_payment_type
			,object_name
			--,sum_insured
			,insurance_code
			,insurance_type
			--,collateral_type
			--,collateral_category_code
			--,depreciation_code
			--,occupation_code
			--,region_code 
			,currency_code
			,cover_note_no
			,cover_note_date
			,policy_no
			,policy_eff_date
			,policy_exp_date
			,file_name
			,paths 
			,eff_rate
			,invoice_no
			,invoice_date
			,from_year
			,to_year
			--,total_premi_sell_amount
			,total_premi_buy_amount
			,total_discount_amount
			,total_net_premi_amount
			,stamp_fee_amount
			,admin_fee_amount
			,total_adjusment_amount
			,is_policy_existing
			,endorsement_count
			--,fa_code
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code
			,@p_sppa_code
			,@p_register_code
			,@p_branch_code
			,@p_branch_name
			,@p_source_type
			,@p_policy_status
			,@p_policy_payment_status
			,@p_insured_name
			,@p_insured_qq_name
			,@p_policy_payment_type
			,@p_object_name
			--,@p_sum_insured
			,@p_insurance_code
			,@p_insurance_type
			--,@p_collateral_type
			--,@p_collateral_category_code
			--,@p_depreciation_code
			--,@p_occupation_code
			--,@p_region_code 
			,@p_currency_code
			,@p_cover_note_no
			,@p_cover_note_date
			,@p_policy_no
			,@p_policy_eff_date
			,@p_policy_exp_date
			,@p_file_name
			,@p_paths 
			,@p_eff_rate
			,@p_invoice_no
			,@p_invoice_date
			,@p_from_year
			,@p_to_year
			--,@p_total_premi_sell_amount
			,@p_total_premi_buy_amount
			,@p_total_discount_amount
			,@p_total_net_premi_amount
			,@p_stamp_fee_amount
			,@p_admin_fee_amount
			,@p_total_adjusment_amount
			,@p_is_policy_existing
			,@p_endorsement_count
			--,@p_fa_code
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

 
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

