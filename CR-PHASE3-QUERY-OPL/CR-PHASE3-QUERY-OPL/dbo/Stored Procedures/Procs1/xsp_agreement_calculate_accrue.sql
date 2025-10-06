/*
exec xsp_agreement_calculate_accrue
*/
-- Louis Senin, 06 Maret 2023 13.15.12 -- 
CREATE PROCEDURE [dbo].[xsp_agreement_calculate_accrue]
(
	@p_transaction_date datetime
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
	declare @msg			nvarchar(max)
			,@no			int
			,@first_duedate datetime
			,@income_amount decimal(18, 2) ;

	begin try
		delete	dbo.agreement_asset_interest_income
		where	isnull(reff_name,'') = ''
		and		isnull(reff_no,'') = ''
		and		isnull(status_accrue,'') = ''

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
			,income_amount_1
		)
		select	aaii.agreement_no
				,aaii.asset_no
				,installment_no
				,aaii.invoice_no
				,aaii.branch_code
				,aaii.branch_name
				,aaii.transaction_date
				,aaii.income_amount * -1
				,''
				,''
				,aaii.accrue_type
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,aaii.income_amount * -1
		from	agreement_asset_interest_income aaii
				inner join dbo.invoice inv on (inv.invoice_no = aaii.invoice_no)
		where	convert(nvarchar(6),transaction_date, 112) <= convert(nvarchar(6), @p_transaction_date, 112)
				--CAST(right('0' + rtrim(month(transaction_date)), 2) as nvarchar(2)) + cast(year(transaction_date) as nvarchar(4)) <= cast(right('0' + rtrim(month(@p_transaction_date)), 2) as nvarchar(2)) + cast(year(@p_transaction_date) as nvarchar(4))
				and isnull(accrue_type, '')	  <> ''
				and inv.invoice_status		  <> 'CANCEL' 
				and invoice_type			  <> 'PENALTY'
				and	isnull(status_accrue,'') = ''

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
