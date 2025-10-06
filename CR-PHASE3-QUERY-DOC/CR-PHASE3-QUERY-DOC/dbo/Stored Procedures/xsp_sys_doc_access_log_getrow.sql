CREATE PROCEDURE dbo.xsp_sys_doc_access_log_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,module_name
			,transaction_name
			,transaction_no
			,convert(varchar(30), access_date, 103) 'access_date'
			,acess_type
			,file_name
			,print_by_code
			,print_by_name
			,print_by_ip
	from	sys_doc_access_log
	where	id = @p_id ;
end ;
