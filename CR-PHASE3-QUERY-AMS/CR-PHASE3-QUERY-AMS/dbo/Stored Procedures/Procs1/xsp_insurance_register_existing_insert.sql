CREATE PROCEDURE dbo.xsp_insurance_register_existing_insert
(
	@p_code						 nvarchar(50)	output
	,@p_policy_code				 nvarchar(50)	= null
	,@p_branch_code				 nvarchar(50)
	,@p_branch_name				 nvarchar(250)
	,@p_source_type				 nvarchar(20)
	,@p_policy_name				 nvarchar(250)	= ''
	,@p_policy_qq_name			 nvarchar(250)
	,@p_register_status			 nvarchar(10)
	,@p_policy_object_name		 nvarchar(250)	= ''
	,@p_sum_insured_amount		 decimal(18, 2)	= 0
	,@p_insurance_code			 nvarchar(50)
	,@p_insurance_type			 nvarchar(10)
	,@p_fa_code					 nvarchar(50)	= null
	,@p_collateral_type			 nvarchar(10)   = null
	,@p_collateral_year			 nvarchar(4)    = null
	,@p_collateral_category_code nvarchar(50)   = null
	,@p_depreciation_code		 nvarchar(50)   = null
	,@p_occupation_code			 nvarchar(50)   = null
	,@p_currency_code			 nvarchar(3)
	,@p_policy_no				 nvarchar(50)
	,@p_policy_eff_date			 datetime
	,@p_policy_exp_date			 datetime
	--,@p_file_name				 nvarchar(250)
	--,@p_paths					 nvarchar(250)
	,@p_region_code				 nvarchar(50)	= null
	--,@p_from_year				 nvarchar(1)  
	,@p_to_year					 nvarchar(1)	= null
	,@p_total_premi_amount		 decimal(18, 2)	= 0
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
	declare @msg		  nvarchar(max)
			,@year		  nvarchar(2)
			,@month		  nvarchar(2)
			,@register_no nvarchar(50)
			,@from_year	  nvarchar(1) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @register_no output -- nvarchar(50)
												,@p_branch_code = @p_branch_code -- nvarchar(10)
												,@p_sys_document_code = N'AMSIRE' -- nvarchar(10)
												,@p_custom_prefix = N'' -- nvarchar(10)
												,@p_year = @year -- nvarchar(2)
												,@p_month = @month -- nvarchar(2)
												,@p_table_name = N'INSURANCE_REGISTER_EXISTING' -- nvarchar(100)
												,@p_run_number_length = 6 -- int
												,@p_delimiter = N'.' -- nvarchar(1)
												,@p_run_number_only = N'0' -- nvarchar(1)
												,@p_specified_column = 'REGISTER_NO' ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'AMSIRE'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'INSURANCE_REGISTER_EXISTING'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		if (@p_policy_eff_date > @p_policy_exp_date)
		begin
			set @msg = 'Effective Date must be less than Expired Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (
			   @p_collateral_type <> 'VHCL'
			   and	@p_occupation_code = ''
		   )
		begin
			set @msg = 'Please input Occupation' ;

			raiserror(@msg, 16, -1) ;
		end ;

		set @from_year = 1 ;
		set @p_to_year = ceiling(datediff(month, @p_policy_eff_date, @p_policy_exp_date) / 12.0) ;

		if @p_insurance_type = 'LIFE'
		begin
			set @p_source_type = 'AGREEMENT' ;
		end ;

		insert into dbo.insurance_register_existing
		(
			code
			,register_no
			,policy_code
			,branch_code
			,branch_name
			,source_type
			,policy_name
			,policy_qq_name
			,register_status
			,policy_object_name
			,sum_insured_amount
			,insurance_code
			,insurance_type
			,fa_code
			,collateral_type
			,collateral_year
			,collateral_category_code
			,depreciation_code
			,occupation_code
			,currency_code
			,policy_no
			,policy_eff_date
			,policy_exp_date
			--file_name,
			--paths,
			,region_code
			,from_year
			,to_year
			,total_premi_sell_amount
			,total_premi_buy_amount
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code
			,@register_no
			,@p_policy_code
			,@p_branch_code
			,@p_branch_name
			,@p_source_type
			,@p_policy_name
			,upper(@p_policy_qq_name)
			,@p_register_status
			,@p_policy_object_name
			,@p_sum_insured_amount
			,@p_insurance_code
			,@p_insurance_type
			,@p_fa_code
			,@p_collateral_type
			,@p_collateral_year
			,@p_collateral_category_code
			,@p_depreciation_code
			,@p_occupation_code
			,@p_currency_code
			,upper(@p_policy_no)
			,@p_policy_eff_date
			,@p_policy_exp_date
			--,@p_file_name
			--,@p_paths
			,@p_region_code
			,@from_year
			,@p_to_year
			,@p_total_premi_amount
			,@p_total_premi_amount
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
