
create procedure [dbo].[xsp_sys_job_blacklist_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,status
			,source
			,job_code
			,entry_date
			,entry_reason
			,exit_date
			,exit_reason
	from	sys_job_blacklist
	where	code = @p_code ;
end ;
