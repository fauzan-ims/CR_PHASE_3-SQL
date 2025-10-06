CREATE procedure xsp_agreement_asset_interest_income_download_template_excel
(
	@p_agreement_no		nvarchar(50)
)
as
begin
	declare	@msg	nvarchar(max)
	begin try
			select	aii.agreement_no
			,aii.asset_no
			,aas.asset_name
			,aii.installment_no
			,aii.invoice_no
			,aii.branch_code
			,aii.branch_name
			,convert(varchar(30), aii.transaction_date, 103) 'transaction_date'
			,aii.income_amount
			,aii.reff_no
			,aii.reff_name
	from	dbo.agreement_asset_interest_income aii
			inner join dbo.agreement_asset aas on (aas.asset_no = aii.asset_no)
	where	aii.agreement_no = @p_agreement_no
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
end
