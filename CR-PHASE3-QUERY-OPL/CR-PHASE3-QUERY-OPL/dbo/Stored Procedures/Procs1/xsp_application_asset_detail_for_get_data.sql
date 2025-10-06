--created by, Rian at 17/05/2023 

CREATE procedure dbo.xsp_application_asset_detail_for_get_data
(
	@p_asset_no nvarchar(50)
	,@p_type	nvarchar(15)
)
as
begin
	select	code
	from	dbo.application_asset_detail
	where	asset_no	= @p_asset_no
	and		type		= @p_type
end ;
