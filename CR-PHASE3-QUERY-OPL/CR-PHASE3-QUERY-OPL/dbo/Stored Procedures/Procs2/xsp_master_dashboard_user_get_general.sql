CREATE PROCEDURE dbo.xsp_master_dashboard_user_get_general
(
	@p_user	   nvarchar(50)
)
as
begin
	select	mdu.id
		   ,mdu.employee_code
		   ,mdu.employee_name
		   ,mdu.dashboard_code
		   ,mdu.order_key
		   ,md.code
		   ,md.dashboard_name
		   ,md.dashboard_type
		   ,md.dashboard_grid
		   ,md.sp_name
		   ,md.is_active
		   ,md.is_editable
	from	dbo.master_dashboard_user mdu
			inner join dbo.master_dashboard md on (md.code = mdu.dashboard_code)
	where mdu.employee_code = @p_user 
			--and md.CODE in ('MD002','MD007')
	order by mdu.order_key asc

end ;
