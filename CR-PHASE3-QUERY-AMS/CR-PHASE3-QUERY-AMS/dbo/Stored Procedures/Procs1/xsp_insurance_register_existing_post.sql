CREATE PROCEDURE dbo.xsp_insurance_register_existing_post 
(
	@p_code				nvarchar(50)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@policy_code				nvarchar(50)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@policy_status				nvarchar(10)
			,@sum_insured				decimal(18, 0)
			,@policy_name				nvarchar(250)
			,@policy_qq_name			nvarchar(250)
			,@policy_no					nvarchar(50)
			,@policy_object_name		nvarchar(250)
			,@insurance_code			nvarchar(50)
			,@insurance_type			nvarchar(10)
			,@collateral_type			nvarchar(50)
			,@collateral_category_code	nvarchar(50)
			,@depreciation_code			nvarchar(50)
			,@occupation_code			nvarchar(50)
			,@region_code				nvarchar(50)
			,@currency_code				nvarchar(3)
			,@policy_eff_date			datetime
			,@policy_exp_date			datetime
			,@from_year					int
			,@to_year					int
			,@total_premi_sell_amount	decimal(18, 0)
			,@history_type				nvarchar(5)
			,@source_type				nvarchar(20)
			,@fa_code					nvarchar(50) ;


	begin try
		select  @branch_code				= ire.branch_code
				,@branch_name				= ire.branch_name
				,@source_type				= ire.source_type
				,@insurance_code			= ire.insurance_code
				,@policy_name				= ire.policy_name
				,@policy_qq_name			= ire.policy_qq_name
				,@policy_object_name		= ire.policy_object_name
				,@policy_no					= ire.policy_no
				,@sum_insured				= ire.sum_insured_amount
				,@insurance_type			= ire.insurance_type
				,@collateral_type			= ire.collateral_type
				,@collateral_category_code	= ire.collateral_category_code
				,@depreciation_code			= ire.depreciation_code
				,@occupation_code			= ire.occupation_code 
				,@currency_code				= ire.currency_code
				,@region_code				= ire.region_code
				,@from_year					= ire.from_year
				,@to_year					= ire.to_year
				,@total_premi_sell_amount	= ire.total_premi_sell_amount
				,@policy_eff_date			= ire.policy_eff_date
				,@policy_exp_date			= ire.policy_exp_date
				,@policy_status				= 'HOLD'
				,@history_type				= 'ENTRY'
				,@fa_code					= ire.fa_code
		from	dbo.insurance_register_existing ire
		where	ire.code					= @p_code
		
		if exists (select 1 from dbo.insurance_register_existing where code = @p_code and register_status <> 'HOLD')
		begin
		    raiserror('Error data already proceed',16,1) ;
		end
        else
		begin	
				
			set @to_year = isnull(datediff(year, @policy_eff_date, @policy_exp_date),0)
			
					  --- UNTUK MENGCOPY POLICY MAIN 
					  exec dbo.xsp_insurance_policy_main_insert @p_code						 = @policy_code output			 
					  											,@p_sppa_code				 = null  				 
					  											,@p_register_code			 = @p_code                     				 
					  											,@p_branch_code				 = @branch_code                   				 
					  											,@p_branch_name				 = @branch_name				 
					  											,@p_source_type				 = @source_type                 				 
					  											,@p_policy_status			 = N'ACTIVE'	                  				 
					  											,@p_policy_payment_status	 = N'PAID'				   				 
					  											,@p_insured_name			 = @policy_name                				 
					  											,@p_insured_qq_name			 = @policy_qq_name              				 
					  											,@p_policy_payment_type		 =  N'FTFP'        				 
					  											,@p_object_name				 = @policy_object_name				 
					  											--,@p_sum_insured				 = @sum_insured                   				 
					  											,@p_insurance_code			 = @insurance_code                 				 
					  											,@p_insurance_type			 = @insurance_type                 				 
					  											--,@p_collateral_type			 = @collateral_type              				 
					  											--,@p_collateral_category_code = @collateral_category_code       				 
					  											--,@p_depreciation_code		 = @depreciation_code            				 
					  											--,@p_occupation_code			 = @occupation_code              				 
					  											--,@p_region_code				 = @region_code		       				 
					  											,@p_currency_code			 = @currency_code				 
					  											,@p_cover_note_no			 = NULL							 
					  											,@p_cover_note_date			 = NULL							 
					  											,@p_policy_no				 = @policy_no 
					  											,@p_policy_eff_date			 = @policy_eff_date 
					  											,@p_policy_exp_date			 = @policy_exp_date
					  											,@p_eff_rate				 = 0            				 
					  											,@p_file_name				 = NULL             				 
					  											,@p_paths					 = NULL                 				 
					  											,@p_invoice_no				 = NULL                 				 
					  											,@p_invoice_date			 = NULL									 
					  											,@p_from_year				 = @from_year							 
					  											,@p_to_year					 = @to_year	            				 
					  											--,@p_total_premi_sell_amount  = @total_premi_sell_amount				 
					  											,@p_total_premi_buy_amount	 = 0                  				 
					  											,@p_total_discount_amount	 = 0                  				 
					  											,@p_total_net_premi_amount   = 0                  				 
					  											,@p_stamp_fee_amount		 = 0                  				 
					  											,@p_admin_fee_amount		 = 0                  				 
					  											,@p_total_adjusment_amount	 = 0                  				 
					  											,@p_is_policy_existing		 = 'T'                 				 
					  											,@p_endorsement_count		 = 0									 
					  											--,@p_fa_code					 = @fa_code												 
					  											,@p_cre_date				 = @p_cre_date	 										 
					  											,@p_cre_by					 = @p_cre_by		
					  											,@p_cre_ip_address			 = @p_cre_ip_address
					  											,@p_mod_date				 = @p_mod_date	 
					  											,@p_mod_by					 = @p_mod_by	 
					  											,@p_mod_ip_address			 = @p_mod_ip_address 
			
			exec dbo.xsp_insurance_policy_main_history_insert @p_id					= 0
															  ,@p_policy_code		= @policy_code
															  ,@p_history_date		= @p_cre_date
															  ,@p_history_type		= @history_type
															  ,@p_policy_status		= @policy_status
															  ,@p_history_remarks	= 'Manual Insurance Register'
															  ,@p_cre_date			= @p_cre_date		
															  ,@p_cre_by			= @p_cre_by		
															  ,@p_cre_ip_address	= @p_cre_ip_address
															  ,@p_mod_date			= @p_mod_date		
															  ,@p_mod_by			= @p_mod_by		
															  ,@p_mod_ip_address	= @p_mod_ip_address
			

			update	dbo.insurance_register_existing 
			set		register_status	= 'POST'
			        ,policy_code    = @policy_code
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	code			= @p_code

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



