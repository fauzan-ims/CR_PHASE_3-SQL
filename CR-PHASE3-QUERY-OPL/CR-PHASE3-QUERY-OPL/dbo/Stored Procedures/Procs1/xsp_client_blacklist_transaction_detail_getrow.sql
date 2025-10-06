CREATE PROCEDURE [dbo].[xsp_client_blacklist_transaction_detail_getrow]
(
	@p_id bigint
)
as
begin
	select	cbtd.id
			,cbtd.blacklist_transaction_code
			,isnull(cb.personal_name, cb.corporate_name) 'client_blacklist_name'
			,cbtd.client_type
			,cbtd.blacklist_type
			,cbtd.client_blacklist_code
			,cbtd.personal_id_no
			,cbtd.personal_nationality_type_code
			,cbtd.personal_doc_type_code
			,cbtd.personal_name
			,cbtd.personal_alias_name
			,cbtd.personal_mother_maiden_name
			,cbtd.personal_dob
			,cbtd.corporate_name
			,cbtd.corporate_tax_file_no
			,cbtd.corporate_est_date
			,sgs.description 'personal_doc_type_desc'
			,cbt.transaction_status
	from	client_blacklist_transaction_detail cbtd
			left join dbo.client_blacklist cb on (cb.code				 = cbtd.client_blacklist_code)
			inner join dbo.client_blacklist_transaction cbt on (cbt.code = cbtd.blacklist_transaction_code)
			left join dbo.sys_general_subcode sgs on (sgs.code			 = cbtd.personal_doc_type_code)
	where	id = @p_id ;
end ;

