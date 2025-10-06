CREATE procedure [dbo].[xsp_client_blacklist_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	cb.code
			,sgs.description 'source'
			,cb.client_type
			,cb.blacklist_type
			,cb.personal_nationality_type_code
			,sgs2.description 'personal_doc_type_code'
			,cb.personal_id_no
			,cb.personal_name
			,cb.personal_alias_name
			,cb.personal_mother_maiden_name
			,cb.personal_dob
			,cb.corporate_name
			,cb.corporate_tax_file_no
			,cb.corporate_est_date
			,cb.entry_date
			,cb.entry_remarks
			,cb.exit_date
			,cb.exit_remarks
			,cb.is_active
	from	client_blacklist cb
			left join dbo.sys_general_subcode sgs on (sgs.code	  = cb.source)
			left join dbo.sys_general_subcode sgs2 on (sgs2.code = cb.personal_doc_type_code)
	where	cb.code = @p_code ;
end ;

