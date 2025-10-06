
CREATE procedure [dbo].[xsp_sys_client_doc_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,client_code
			,doc_type
			,doc_no
			,doc_status
			,eff_date
			,exp_date
			,is_default
	from	sys_client_doc
	where	code = @p_code ;
end ;

