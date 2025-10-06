CREATE procedure dbo.xsp_sale_upload_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,company_code
			,sale_date
			,description
			,branch_code
			,branch_name
			,location_code
			,buyer
			,buyer_phone_no
			,sale_amount
			,remark
			,status
			,asset_code
			,description_detail
			,sale_value
	from	sale_upload
	where	code = @p_code ;
end ;
