
CREATE PROCEDURE [dbo].[xsp_application_asset_component_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,asset_no
			,component_name
			,component_no
			,component_date
			,component_remarks
	from	application_asset_component
	where	id = @p_id ;
end ;

