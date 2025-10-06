CREATE procedure [dbo].[xsp_client_asset_getrow]
(
	@p_id			bigint
)
as
begin
	select	ca.id
			,ca.client_code
			,ca.asset_type_code
			,ca.asset_name
			,ca.asset_value
			,ca.reff_no
			,ca.location
			,ca.remarks
			,sgs.description 'asset_type_desc'
	from	client_asset ca
			inner join dbo.sys_general_subcode sgs on (sgs.code = ca.asset_type_code)
	where	id				= @p_id ;
end ;

