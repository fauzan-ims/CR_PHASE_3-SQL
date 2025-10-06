--created by, Rian at 09/02/2023 

CREATE PROCEDURE [dbo].[xsp_master_faq_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,question
			,answer
			,filename 'file_name'
			,paths
			,is_active
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
	from	dbo.master_faq
	where	id = @p_id ;
end ;
