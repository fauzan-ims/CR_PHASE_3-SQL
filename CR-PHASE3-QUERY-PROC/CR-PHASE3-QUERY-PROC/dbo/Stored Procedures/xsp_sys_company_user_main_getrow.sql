CREATE PROCEDURE dbo.xsp_sys_company_user_main_getrow
(
	@p_code				nvarchar(50)
	,@p_company_code	nvarchar(50)
)
as
begin
	select	scu.code
			,scu.company_code
			,scu.upass
			,scu.upassapproval
			,scu.name
			,scu.username
			,scu.main_task_code
			,scu.email
			,scu.phone_no
			,scu.province_code
			,scu.province_name
			,scu.city_code
			,scu.city_name
			,scu.last_login_date
			,scu.last_fail_count
			,scu.next_change_pass
			,scu.file_name
			,scu.paths
			,scu.is_default
			,scu.is_active
			--,scu.user_type
			--,scu.module
			,scm.name 'company_name'
			,mtu.description 'main_task_name'
	from	sys_company_user_main scu
			left join dbo.sys_company scm on scm.code = scu.company_code collate sql_latin1_general_cp1_ci_as
			left join dbo.master_task_user mtu on mtu.code = scu.main_task_code  collate sql_latin1_general_cp1_ci_as and mtu.company_code = scu.company_code collate sql_latin1_general_cp1_ci_as
	where	scu.code = @p_code 
	and		scu.company_code = @p_company_code;
end ;
