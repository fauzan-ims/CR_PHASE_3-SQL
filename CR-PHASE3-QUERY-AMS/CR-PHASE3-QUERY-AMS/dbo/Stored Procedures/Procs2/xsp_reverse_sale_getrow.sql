CREATE PROCEDURE dbo.xsp_reverse_sale_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	rs.code
			,rs.company_code
			,rs.sale_code
			,rs.sale_date
			,rs.reverse_sale_date
			,rs.reason_reverse_code
			,sgs.description 'description_reason'
			,rs.description
			,rs.branch_code
			,rs.branch_name
			,rs.location_code
			,rs.location_name
			,rs.to_bank_account_no
			,rs.to_bank_account_name
			,rs.to_bank_code
			,rs.to_bank_name
			,rs.buyer
			,rs.buyer_phone_no
			,rs.sale_amount
			,rs.remark
			,rs.status
	from	reverse_sale rs
	left join dbo.sys_general_subcode sgs on (sgs.code = rs.reason_reverse_code)
	where	rs.code = @p_code ;
end ;
