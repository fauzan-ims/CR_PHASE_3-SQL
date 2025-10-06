CREATE PROCEDURE [dbo].[xsp_client_corporate_shareholder_getrow]
(
	@p_id bigint
)
as
begin
	select	ccs.id
			,ccs.client_code
			,ccs.shareholder_client_type
			,ccs.shareholder_client_code
			,ccs.shareholder_pct
			,ccs.is_officer
			,ccs.officer_signer_type
			,ccs.officer_position_type_code
			,ccs.order_key
			,cm.client_name 'shareholder_client_name'
			,sgs.description 'officer_position_type_desc'
	from	client_corporate_shareholder ccs
			left join dbo.client_main cm on (cm.code			= ccs.shareholder_client_code)
			left join dbo.sys_general_subcode sgs on (sgs.code = ccs.officer_position_type_code)
	where	ccs.id = @p_id ;
end ;

