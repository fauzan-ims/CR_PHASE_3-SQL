CREATE PROCEDURE dbo.xsp_master_collector_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	 mc.code
			,mc.collector_name
			,mc.supervisor_collector_code
			,mca.collector_name 'supervisor_collector_name'
			,mc.collector_emp_code
			,mc.collector_emp_name
			,mc.max_load_agreement
			,mc.max_load_daily_agreement
			,mc.is_active
	from	master_collector mc
	left join dbo.master_collector mca on (mca.code = mc.supervisor_collector_code)
	where	mc.code = @p_code ;
end ;
