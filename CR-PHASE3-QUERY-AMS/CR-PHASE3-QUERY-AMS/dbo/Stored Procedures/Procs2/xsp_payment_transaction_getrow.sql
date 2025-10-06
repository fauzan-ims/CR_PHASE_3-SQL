CREATE PROCEDURE [dbo].[xsp_payment_transaction_getrow]
(
	@p_code nvarchar(50)
)
as
begin
		select	ptc.code
				,ptc.branch_code
				,ptc.branch_name
				,ptc.payment_transaction_date
				,ptc.payment_amount
				,ptc.remark
				,ptc.payment_status
				,prq.to_bank_name
				,prq.to_bank_account_no
				,prq.to_bank_account_name
				,prq.payment_to
				,isnull(ptc.file_name,'') 'file_name'
				,isnull(ptc.paths,'') 'paths'
		from	dbo.payment_transaction ptc
				LEFT join dbo.payment_transaction_detail ptd on ptc.code = ptd.payment_transaction_code
				left join dbo.payment_request prq on prq.code	   = ptd.payment_request_code
		where	ptc.code = @p_code ;
end ;
