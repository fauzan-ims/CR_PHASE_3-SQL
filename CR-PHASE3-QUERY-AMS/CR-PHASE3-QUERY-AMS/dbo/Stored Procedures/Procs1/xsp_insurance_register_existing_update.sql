CREATE PROCEDURE dbo.xsp_insurance_register_existing_update
(
	@p_code						 nvarchar(50) 
	,@p_register_no				 nvarchar(50)
	,@p_policy_code				 nvarchar(50) = null
	,@p_branch_code				 nvarchar(50)
	,@p_branch_name				 nvarchar(250)
	--,@p_source_type				 nvarchar(20)
	,@p_policy_name				 nvarchar(250) = ''
	,@p_policy_qq_name			 nvarchar(250)
	,@p_register_status			 nvarchar(10)
	,@p_sum_insured_amount		 decimal(18, 2)
	,@p_insurance_code			 nvarchar(50)
	,@p_insurance_type			 nvarchar(10)
	,@p_collateral_type			 nvarchar(10) = null
	,@p_collateral_year			 nvarchar(4)  = null    
	,@p_collateral_category_code nvarchar(50) = null
	,@p_depreciation_code		 nvarchar(50) = null
	,@p_occupation_code			 nvarchar(50) = null

	,@p_currency_code			 nvarchar(3)
	,@p_policy_no				 nvarchar(50)
	,@p_policy_eff_date			 datetime
	,@p_policy_exp_date			 datetime
	--,@p_file_name				 nvarchar(250) 
	--,@p_paths					 nvarchar(250) 
	,@p_region_code				 nvarchar(50)  = NULL
	,@p_from_year				 nvarchar(1)   
	,@p_to_year					 nvarchar(1)   = NULL
	,@p_total_premi_amount		decimal(18, 2)
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		 if (@p_policy_eff_date > @p_policy_exp_date)
		begin
			set @msg = 'Effective Date must be less than Expired Date' ;
			raiserror(@msg, 16, -1) ;
		end
		set @p_from_year = 1
		set @p_to_year =  ceiling(datediff(month, @p_policy_eff_date, @p_policy_exp_date)/12.0)

		--if @p_insurance_type = 'LIFE'
		--begin
		--	set @p_source_type = 'AGREEMENT'
		--end

		update	insurance_register_existing
		set		register_no                 = @p_register_no
				,policy_code				= @p_policy_code
				,branch_code				= @p_branch_code
				,branch_name				= @p_branch_name				 	 
				,policy_name				= @p_policy_name				 
				,policy_qq_name			    = @p_policy_qq_name			 
				,register_status			= @p_register_status			 		 
				,sum_insured_amount		    = @p_sum_insured_amount		 
				,insurance_code			    = @p_insurance_code			 
				,insurance_type			    = @p_insurance_type			 
				,collateral_type			= @p_collateral_type	
				,collateral_year			= @p_collateral_year			 						 
				,collateral_category_code   = @p_collateral_category_code 
				,depreciation_code		    = @p_depreciation_code		 
				,occupation_code			= @p_occupation_code			  		 
				,currency_code				= @p_currency_code			 
				,policy_no					= @p_policy_no				 
				,policy_eff_date			= @p_policy_eff_date			 
				,policy_exp_date			= @p_policy_exp_date			 					 
				,region_code				= @p_region_code				 
				,from_year					= @p_from_year				 
				,to_year					= @p_to_year					 
				,total_premi_sell_amount	= @p_total_premi_amount	
				,total_premi_buy_amount		= @p_total_premi_amount
									  
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;
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

