create procedure [dbo].[xsp_sys_job_tasklist_getrow]
(
	@p_code	   nvarchar(50)
)
as
begin
	select	code,
            type,
            description,
            sp_name,
            order_no,
            is_active,
            last_id,
            row_to_process,
            eod_status,
            eod_remark
	from	dbo.sys_job_tasklist
	where	code	   = @p_code;
end ;
