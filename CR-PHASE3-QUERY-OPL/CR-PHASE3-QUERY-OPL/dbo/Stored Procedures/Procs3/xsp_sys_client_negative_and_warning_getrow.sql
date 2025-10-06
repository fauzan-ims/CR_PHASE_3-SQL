
CREATE procedure [dbo].[xsp_sys_client_negative_and_warning_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,status
			,source
			,client_type
			,client_id
			,fullname
			,mother_maiden_name
			,dob
			,id_no
			,tax_file_no
			,est_date
			,entry_date
			,entry_reason
			,exit_date
			,exit_reason
	from	sys_client_negative_and_warning
	where	code = @p_code ;
end ;

