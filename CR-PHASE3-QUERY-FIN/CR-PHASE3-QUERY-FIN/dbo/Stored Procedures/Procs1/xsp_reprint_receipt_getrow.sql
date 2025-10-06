CREATE PROCEDURE dbo.xsp_reprint_receipt_getrow
(
	@p_code	nvarchar(50)
)
as
begin
	select	rr.code
			,rr.branch_code
			,rr.branch_name
			,reprint_status
			,reprint_date
			,reprint_reason_code
			,reprint_remarks
			,cashier_type
			,rr.cashier_code
			,old_receipt_code
			,rmo.receipt_no 'old_receipt_no'
			,new_receipt_code
			,rmn.receipt_no 'new_receipt_no'
			,sgs.description 'reprint_reason_name'
	from	reprint_receipt rr
			inner join dbo.sys_general_subcode sgs on (sgs.code= rr.reprint_reason_code)
			left join dbo.receipt_main rmo on (rmo.code = rr.old_receipt_code)
			left join dbo.receipt_main rmn on (rmn.code = rr.new_receipt_code)
	where	rr.code = @p_code;
end ;
