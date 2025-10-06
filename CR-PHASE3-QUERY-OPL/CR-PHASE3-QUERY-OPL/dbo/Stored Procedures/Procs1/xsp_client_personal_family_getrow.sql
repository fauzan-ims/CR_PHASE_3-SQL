CREATE PROCEDURE [dbo].[xsp_client_personal_family_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,client_code
			,family_type_code
			,family_client_code
			,is_emergency_contact
			,sgs.description 'family_type_desc'
			,cm.client_name 'family_client_name'
	from	client_personal_family cpf
			inner join dbo.sys_general_subcode sgs on (sgs.code = cpf.family_type_code)
			inner join dbo.client_main cm on (cm.code			= cpf.family_client_code)
	where	id = @p_id ;
end ;

