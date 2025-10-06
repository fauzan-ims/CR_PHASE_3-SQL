/*
exec xsp_agreement_asset_interest_income_generate
*/
-- Louis Jumat, 03 Maret 2023 19.21.04 -- 
CREATE PROCEDURE [dbo].[xsp_agreement_asset_interest_income_generate]
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
			,@loop						  int			= 0
			,@end_duedate				  datetime		
			,@eom_date					  datetime		--= eomonth(dbo.xfn_get_system_date())
			,@propotional_invoice_day	  decimal(18, 2)
			,@propotional_invoice_due_day decimal(18, 2)
			,@income_amount				  decimal(18, 2)
			,@accrue_type				  nvarchar(2) = 'P'
			,@invoice_date				  datetime
            ,@end_loop					  int
			,@eom_date_bf				  datetime

			select	@end_duedate	=  dateadd(month, @p_schedule_month, due_date)
					,@invoice_date	= due_date
			from	dbo.agreement_asset_amortization
			where	agreement_no	= @p_agreement_no
			and		asset_no		= @p_asset_no
			and		invoice_no		= @p_invoice_no
			and		billing_no		= @p_billing_no

			set @end_loop = datediff(month, @invoice_date, @end_duedate)
			set @eom_date = eomonth(@invoice_date)

	begin try
		while (@loop <= @end_loop)
		begin
			
			--get propotional day
			set @propotional_invoice_due_day = datediff(day, @invoice_date, @end_duedate) ;

			if(@loop = 0)
			begin
				set @propotional_invoice_day = datediff(day, @invoice_date, @eom_date) ;
				set @income_amount = round(@p_income_amount * (@propotional_invoice_day / @propotional_invoice_due_day), 0) ;
			end
            else if (@loop = @end_loop)
			begin
                set @propotional_invoice_day = datediff(day, @eom_date_bf, @eom_date) ;
				set @income_amount = @p_income_amount - (select sum(income_amount) from dbo.agreement_asset_interest_income where invoice_no = @p_invoice_no and asset_no = @p_asset_no and agreement_no = @p_agreement_no)
			end
			else
            begin
                set @propotional_invoice_day = datediff(day, @eom_date_bf, @eom_date) ;
				set @income_amount = round(@p_income_amount * (@propotional_invoice_day / @propotional_invoice_due_day), 0) ;
            end

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
					--
					,income_amount_1 --(sepria 09-07-2024: penambahan kolom ini untuk mengcover perubahan konsep income yg dari post reverse jadi post saja untuk report dwh)
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
					--
					,@income_amount
				) ;
			end

			set @propotional_invoice_day = 0;
			set @propotional_invoice_due_day = 0;
			set @income_amount = 0;
			set @loop = @loop + 1

			set @eom_date_bf = @eom_date
			set @eom_date = eomonth(dateadd(month, 1, @eom_date)) 

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
