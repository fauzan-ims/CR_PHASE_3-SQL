CREATE procedure [dbo].[xsp_et_main_getrow_external]
(
	@p_code nvarchar(50)
)
as
begin
	declare @msg	nvarchar(max)
			,@total decimal(18, 2) ;

	select	@total = sum(et.transaction_amount)
	from	dbo.et_main em
			inner join dbo.et_transaction et on (et.et_code = em.code)
	where	em.code				  = @p_code
			and et.is_transaction = '0' ;

	select	code
			,branch_code
			,branch_name
			,agreement_no
			,et_status
			,format(cast(isnull(et_date, '') as datetime), 'dd/MM/yyyy', 'en-us') 'et_date'
			,et_exp_date
			,et_amount
			,et_remarks
			,received_request_code
			,received_voucher_no
			,received_voucher_date
			,@total 'total_amount'
	from	et_main
	where	code = @p_code ;
end ;

