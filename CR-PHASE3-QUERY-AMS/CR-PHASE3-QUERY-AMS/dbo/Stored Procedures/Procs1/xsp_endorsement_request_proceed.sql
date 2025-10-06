/*
	alterd : Yunus Muslim, 28 April 2020
*/
CREATE PROCEDURE dbo.xsp_endorsement_request_proceed 
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
	declare @msg							nvarchar(max)
			,@policy_code					nvarchar(50)
			,@endorsment_code				nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@endorsement_status			nvarchar(10)
			,@endorsement_date				datetime
			,@endorsement_type				nvarchar(15)
			,@old_or_new					nvarchar(3)
			,@sum_insured					decimal(18, 2)
			,@rate_depreciation				decimal(9, 6)
			,@coverage_code					nvarchar(50)
			,@year_period					int
			,@initial_buy_rate				decimal(9, 6)
			,@initial_buy_amount			decimal(18, 2)
			,@initial_sell_rate				decimal(9, 6)
			,@initial_sell_amount			decimal(18, 2)
			,@initial_discount_pct			decimal(9, 6)
			,@initial_discount_amount		decimal(18, 2)
			,@initial_admin_fee_amount		decimal(18, 2)
			,@initial_stamp_fee_amount		decimal(18, 2)
			,@total_buy_amount				decimal(18, 2)
			,@total_sell_amount				decimal(18, 2)
			,@remain_buy					decimal(18, 2)
			,@remain_sell					decimal(18, 2)
			,@occupation_code				nvarchar(50)
			,@region_code					nvarchar(50)
			,@collateral_category_code		nvarchar(50)
			,@object_name					nvarchar(4000)
			,@insured_name					nvarchar(250)
			,@insured_qq_name				nvarchar(250)
			,@eff_date						datetime
			,@exp_date						datetime
			,@currency_code					nvarchar(3);

	begin try
		select	@policy_code				= policy_code	
				,@endorsement_type          = endorsement_request_type					
		from	dbo.endorsement_request
		where	code						= @p_code
		
		select	 @branch_code				= branch_code				
				,@branch_name				= branch_name				
				--,@endorsement_status		= policy_status
				,@endorsement_date			= getdate()
				,@occupation_code			= occupation_code				
				,@region_code				= region_code				
				,@collateral_category_code	= collateral_category_code	
				,@object_name				= object_name				
				,@insured_name				= insured_name				
				,@insured_qq_name			= insured_qq_name			
				,@eff_date					= policy_eff_date					
				,@exp_date					= policy_exp_date	
				,@currency_code				= currency_code				
		from	dbo.insurance_policy_main
		where	code						= @policy_code

		if exists (select 1 from dbo.endorsement_request where code = @p_code and endorsement_request_status = 'HOLD')
		begin		
			exec dbo.xsp_endorsement_main_insert @p_code							= @endorsment_code output
												 ,@p_branch_code					= @branch_code
												 ,@p_branch_name					= @branch_name
												 ,@p_endorsement_status				= 'HOLD'
												 ,@p_endorsement_date				= @endorsement_date
												 ,@p_policy_code					= @policy_code
												 ,@p_endorsement_type				= @endorsement_type
												 ,@p_endorsement_remarks			= 'ENDORSEMENT REQUEST PROCEED'
												 ,@p_endorsement_request_code		= @p_code      
												 ,@p_currency_code					= @currency_code
												 ,@p_endorsement_payment_amount		= 0
												 ,@p_endorsement_received_amount	= 0
												 --
												 ,@p_cre_date						= @p_cre_date		
												 ,@p_cre_by							= @p_cre_by		
												 ,@p_cre_ip_address					= @p_cre_ip_address
												 ,@p_mod_date						= @p_mod_date		
												 ,@p_mod_by							= @p_mod_by		
												 ,@p_mod_ip_address					= @p_mod_ip_address
			
			update	dbo.endorsement_request 
			set		endorsement_request_status	= 'POST'
					,endorsement_code = @endorsment_code
					--
					,mod_date					= @p_mod_date		
					,mod_by						= @p_mod_by			
					,mod_ip_address				= @p_mod_ip_address
			where	code						= @p_code

		end
        else
		begin
			set @msg = 'Error data already proceed' ;

			raiserror(@msg, 16, -1) ;
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


