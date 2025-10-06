-- Louis Jumat, 23 Juni 2023 11.03.49 --
CREATE PROCEDURE dbo.xsp_application_asset_calculate
(
	@p_asset_no		   nvarchar(50)
	,@p_spaf_rate	   decimal(9, 6) = 0
	--											
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg							  nvarchar(max)
			,@periode						  int
			,@rounding_type					  nvarchar(20)
			,@rounding_value				  decimal(18, 2)
			,@lease_rounded_amount			  decimal(18, 2) = 0
			,@basic_lease_amount			  decimal(18, 2) = 0
			,@pmt_amount					  decimal(18, 2) = 0
			,@insurance_commission_rate		  decimal(9, 6)	 = 0
			,@additional_charge_amount		  decimal(18, 2) = 0
			,@insurance_commission_amount	  decimal(18, 2) = 0
			,@spaf_amount					  decimal(18, 2) = 0
			,@average_asset_amount			  decimal(18, 2) = 0
			,@yearly_profit_amount			  decimal(18, 2) = 0
			,@roa_pct						  decimal(9, 6)	 = 0
			,@borrowing_rate				  decimal(9, 6)	 = 0
			,@total_budget_amount			  decimal(18, 2) = 0
			,@subvention_amount				  decimal(18, 2) = 0
			,@asset_amount					  decimal(18, 2) = 0
			,@asset_rv_amount				  decimal(18, 2) = 0 
			,@borrowing_interest_amount		  decimal(18, 2) = 0
			,@top_interest_amount			  decimal(18, 2) = 0
			,@depreciation_amount			  decimal(18, 2) = 0
			,@income_amount					  decimal(18, 2) = 0
			,@expense_amount				  decimal(18, 2) = 0
			,@disposal_amount				  decimal(18, 2) = 0 
			,@monthly_rental_amount			  decimal(18, 2) = 0 
			,@unit_amount					  decimal(18, 2) = 0 
			,@discount_amount				  decimal(18, 2) = 0 
			,@total_rental_amount			  decimal(18, 2) = 0 
			,@budget_insurance_amount		  decimal(18, 2) = 0
			,@use_life						  int = 5
			,@top_days						  int
			,@periode_devider				  int
			,@multiplier					  int
			,@mobilization_amount			  decimal(18, 2) = 0
			,@asset_condition				  nvarchar(5)
			,@karoseri_amount				  decimal(18, 2) = 0
			,@karoseri_discount_amount		  decimal(18, 2) = 0
			,@unit_source					nvarchar(50)

	begin try
		select	@periode				= am.periode
				,@rounding_type			= aa.round_type
				,@rounding_value		= aa.round_amount
				,@subvention_amount		= aa.subvention_amount
				,@asset_amount			= aa.asset_amount
				,@asset_rv_amount		= aa.asset_rv_amount
				,@pmt_amount			= aa.pmt_amount
				,@unit_amount			= aa.market_value
				,@discount_amount		= aa.discount_amount
				,@borrowing_rate		= aa.borrowing_interest_rate
				,@top_days				= am.credit_term 
				,@monthly_rental_amount	= aa.lease_rounded_amount
				,@multiplier			= mbt.multiplier
				,@mobilization_amount	= aa.mobilization_amount
				,@basic_lease_amount	= basic_lease_amount
				,@additional_charge_amount = aa.additional_charge_amount
				,@insurance_commission_amount = aa.insurance_commission_amount
				,@asset_condition = aa.asset_condition
				,@karoseri_amount			= aa.karoseri_amount
				,@karoseri_discount_amount	= aa.discount_karoseri_amount 
				,@unit_source		= aa.unit_source
		from	dbo.application_asset aa
				inner join dbo.application_main am on (am.application_no = aa.application_no)
				inner join master_billing_type mbt on (mbt.code = aa.billing_type)
		where	asset_no				= @p_asset_no ;

		select	@insurance_commission_rate = cast(value as decimal(9, 6))
		from	dbo.sys_global_param
		where	code = 'INSCOMM'
		
		--select	@insurance_commission_amount = budget_amount * (@insurance_commission_rate / 100)
		--from	dbo.application_asset_budget
		--where	asset_no	  = @p_asset_no
		--		and cost_code = N'MBDC.2211.000001' ;

		select	@budget_insurance_amount = budget_amount
		from	dbo.application_asset_budget
		where	asset_no	  = @p_asset_no
				and cost_code = N'MBDC.2211.000001' ;
	
		if (@p_spaf_rate > 0 and @unit_source <> 'STOCK' ) --@asset_condition <> 'USED')
		begin
			set @spaf_amount = @unit_amount * (@p_spaf_rate / 100) ;
		end ;  
		else
		begin
			set @spaf_amount = 0;
		end
		
		--select	@basic_lease_amount = ((isnull(sum(isnull(budget_amount, 0)), 0) / @periode) + @pmt_amount) * @multiplier
		--from	dbo.application_asset_budget
		--where	asset_no = @p_asset_no ; 

		select	@total_budget_amount = isnull(sum(isnull(budget_amount, 0)), 0)
		from	dbo.application_asset_budget
		where	asset_no = @p_asset_no ;

		select	@borrowing_interest_amount = (isnull(borrowing_interest_amount, 0) + ((lease_rounded_amount - basic_lease_amount) * periode))
		from	dbo.application_asset
		where	asset_no = @p_asset_no ;
		--select @periode
		set @periode_devider =ceiling((@periode * 1.00) / 12)
		
		--if (@top_days > 0)
		--begin
		--	set @additional_charge_amount = (@asset_amount  + (@budget_insurance_amount / @periode_devider)) * (@borrowing_rate / 100) * @top_days / 360  ;
		--end ;

		select	@depreciation_amount = isnull(asset_amount, 0)
		from	dbo.application_asset
		where	asset_no = @p_asset_no ;

		select	@disposal_amount = isnull(asset_rv_amount, 0)
		from	dbo.application_asset	
		where	asset_no = @p_asset_no ;
		 
		select	@total_rental_amount = sum(billing_amount)--lease_rounded_amount * (@periode * @multiplier)  --isnull(sum(billing_amount), 0)
		from	dbo.application_amortization--amortization	
		where	asset_no = @p_asset_no ;
		 
		--if (@rounding_type = 'DOWN')
		--	set @lease_rounded_amount = dbo.fn_get_floor(@basic_lease_amount, @rounding_value) ;
		--else if (@rounding_type = 'UP')
		--	set @lease_rounded_amount = dbo.fn_get_ceiling(@basic_lease_amount, @rounding_value) ;
		--else
		--	set @lease_rounded_amount = dbo.fn_get_round(@basic_lease_amount, @rounding_value) ;
			
		--yearly income
			--SPAF dll (KTB) + Subvention
			--Insurance Commision
			--Rental/instalment
			--Disposal/Sale
			 
		set @income_amount = ((@subvention_amount) /@periode_devider) + (@insurance_commission_amount / @periode_devider) + (@total_rental_amount / @periode_devider) + (@disposal_amount / @periode_devider) 
		
		--select  ((@subvention_amount)), (@insurance_commission_amount), (@total_rental_amount), (@disposal_amount)
		--select  round(((@subvention_amount) /@periode_devider) + (@insurance_commission_amount / @periode_devider) + (@total_rental_amount/ @periode_devider) + (@disposal_amount / @periode_devider), 0)
		 
		--yearly expense 
			--Bunga TOP
			--Borrowing Interest
			--Depreciation
			--Biaya From Budget
			--Mobilization Amount

		set @expense_amount = (@additional_charge_amount / @periode_devider) + (@borrowing_interest_amount / @periode_devider) + (@depreciation_amount / @periode_devider) + (@total_budget_amount / @periode_devider) + (@mobilization_amount / @periode_devider)
		--select (@additional_charge_amount / @periode_devider) + (@borrowing_interest_amount / @periode_devider) + (@depreciation_amount / @periode_devider) + (@total_budget_amount / @periode_devider) + (@mobilization_amount / @periode_devider)
		--select  round((@additional_charge_amount / @periode_devider) + (@borrowing_interest_amount / @periode_devider) + (@depreciation_amount / @periode_devider) + (@total_budget_amount / @periode_devider) + (@mobilization_amount / @periode_devider), 0)

		set @average_asset_amount = (((@unit_amount + @karoseri_amount) - @asset_rv_amount) / 2) + @asset_rv_amount ;
		 
		set @yearly_profit_amount = round(@income_amount, 0) -  round(@expense_amount, 0)

		set @roa_pct = (@yearly_profit_amount / @average_asset_amount) * 100 ;
		--select @income_amount 'income_amount',@expense_amount 'expense_amount',@average_asset_amount 'average_asset_amount',@yearly_profit_amount 'yearly_profit_amount',@roa_pct 'roa_pct'

		update	dbo.application_asset
		set		average_asset_amount		 = @average_asset_amount
				,yearly_profit_amount		 = @yearly_profit_amount
				,roa_pct					 = @roa_pct
				--
				,mod_date					 = @p_mod_date
				,mod_by						 = @p_mod_by
				,mod_ip_address				 = @p_mod_ip_address
		where	asset_no					 = @p_asset_no ;
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;




