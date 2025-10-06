CREATE procedure dbo.xsp_disposal_upload_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,company_code
			,disposal_date
			,branch_code
			,branch_name
			,location_code
			,description
			,reason_type
			,remarks
			,status
			,asset_code
			,description_detail
	from	disposal_upload
	where	code = @p_code ;
end ;
