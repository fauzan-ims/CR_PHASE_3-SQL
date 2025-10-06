--Created, Rian at 28/12/2022

CREATE PROCEDURE dbo.xsp_master_bast_checklist_asset_getrow
(
	@p_code					nvarchar(50)
	,@p_asset_type_code		nvarchar(50)
)
as
begin
	select	code
			,asset_type_code
			,checklist_name
			,order_key
			,is_active
	from	dbo.master_bast_checklist_asset
	where	code = @p_code
	and		asset_type_code = @p_asset_type_code ;
end ;
