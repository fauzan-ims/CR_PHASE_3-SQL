--created by, Rian at 20/02/2023 

create procedure dbo.xsp_sys_job_tasklist_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,type
			,description
			,sp_name
			,order_no
			,is_active
			,row_to_process
			,eod_status
			,eod_remark
			,last_id
	from	dbo.sys_job_tasklist
	where	code = @p_code ;
end ;
