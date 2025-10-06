CREATE PROCEDURE dbo.xsp_deposit_main_by_agreement_getrow
(
	@p_agreement_no		nvarchar(50) = ''
	,@p_currency_code	nvarchar(50) = ''
)
as
begin
	declare @code						nvarchar(50)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@deposit_type				nvarchar(15)
			,@deposit_currency_code		nvarchar(3)
			,@deposit_amount			decimal(18, 2) = 0;

	select	@code					= dm.code
			,@branch_code			= dm.branch_code
			,@branch_name			= dm.branch_name
			,@deposit_type			= dm.deposit_type
			,@deposit_currency_code	= dm.deposit_currency_code
			,@deposit_amount		= dm.deposit_amount
	from	deposit_main dm
	where	dm.agreement_no = @p_agreement_no
			and dm.deposit_currency_code = @p_currency_code  
			and	dm.deposit_type = 'INSTALLMENT';

	select	@code					   'code'
			,@branch_code			   'branch_code'
			,@branch_name			   'branch_name'
			,@deposit_type			   'deposit_type'
			,@deposit_currency_code	   'deposit_currency_code'
			,isnull(@deposit_amount,0) 'deposit_amount'

end ;
