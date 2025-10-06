/*
exec xsp_agreement_asset_interest_income_generate
*/
-- Louis Jumat, 03 Maret 2023 19.21.04 -- 
CREATE PROCEDURE [dbo].[xsp_agreement_asset_interest_income_generate_backup_09072024]
(
	@p_agreement_no		 nvarchar(50)
	,@p_asset_no		 nvarchar(50)
	,@p_invoice_no		 nvarchar(50)
	,@p_branch_code		 nvarchar(50)
	,@p_branch_name		 nvarchar(250)
	,@p_transaction_date datetime
	,@p_income_amount	 decimal(18, 2)
	,@p_reff_no			 nvarchar(50)
	,@p_reff_name		 nvarchar(250)
	,@p_schedule_month	 int
	,@p_billing_no		 int
	--
	,@p_cre_date		 datetime
	,@p_cre_by			 nvarchar(15)
	,@p_cre_ip_address	 nvarchar(15)
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg						  nvarchar(max)
			,@no						  int
			,@loop						  int			= 1
			,@end_duedate				  datetime		= dateadd(month, @p_schedule_month, @p_transaction_date)
			,@eom_date					  datetime		= eomonth(@p_transaction_date)
			,@propotional_invoice_day	  decimal(18, 2)
			,@propotional_invoice_due_day decimal(18, 2)
			,@income_amount				  decimal(18, 2)
			,@accrue_type				  nvarchar(2) ;

	begin try
		while (@loop = 1)
		begin
			--get propotional day
			set @propotional_invoice_day = datediff(day, @p_transaction_date, @eom_date) ;
			set @propotional_invoice_due_day = datediff(day, @p_transaction_date, @end_duedate) ;
			 
			if (@eom_date <= @end_duedate)
			begin  
				--get propotional amount
				set @income_amount = round(@p_income_amount * (@propotional_invoice_day / @propotional_invoice_due_day), 0) ;
				set @accrue_type = N'PR' ;
			end ;
			else
			begin
				set @income_amount = @p_income_amount ;
				set @accrue_type = N'P' ;
				set @loop = 0 ;
			end ;

			if ((@propotional_invoice_day / @propotional_invoice_due_day) > 0)
			begin
				insert into dbo.agreement_asset_interest_income
				(
					agreement_no
					,asset_no
					,installment_no
					,invoice_no
					,branch_code
					,branch_name
					,transaction_date
					,income_amount
					,reff_no
					,reff_name
					,accrue_type
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				values
				(
					@p_agreement_no
					,@p_asset_no
					,@p_billing_no
					,@p_invoice_no
					,@p_branch_code
					,@p_branch_name
					,@eom_date
					,@income_amount
					,@p_reff_no
					,@p_reff_name
					,@accrue_type
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
				) ;
			end

			set @accrue_type = '' ;
			set @propotional_invoice_day = 0;
			set @propotional_invoice_due_day = 0;
			set @income_amount = 0;

			set @eom_date = dateadd(month, 1, @eom_date) ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
