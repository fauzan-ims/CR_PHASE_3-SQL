
CREATE PROCEDURE [dbo].[xsp_sys_company_user_main_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	scum.code
			,scum.company_code
			,upass
			,upassapproval
			,scum.name
			,sem.nik
			,username
			,main_task_code
			,mtu.description 'main_task_name'
			,scum.email
			,scum.phone_no
			,scum.province_code
			,province_name
			,scum.city_code
			,city_name
			,last_login_date
			,last_fail_count
			,next_change_pass
			,file_name
			,paths
			,module
			,scum.is_active
			,scum.is_lock
			,is_default
	from	sys_company_user_main scum
			left join dbo.master_task_user mtu on (mtu.code = scum.main_task_code)
			left join dbo.sys_employee_main sem on (sem.code = scum.code)
	where	scum.code = @p_code ;
end ;
