CREATE PROCEDURE dbo.xsp_asset_other_getrow
(
	@p_asset_code nvarchar(50)
)
as
begin
	select	asset_code
			,license_no
			,start_date_license
			,end_date_license
			,nominal
			,remark
	from	asset_other
	where	asset_code = @p_asset_code ;
end ;
