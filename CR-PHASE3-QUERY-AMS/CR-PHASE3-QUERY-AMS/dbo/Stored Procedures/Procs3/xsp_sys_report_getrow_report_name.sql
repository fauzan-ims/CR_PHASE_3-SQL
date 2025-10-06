CREATE PROCEDURE dbo.xsp_sys_report_getrow_report_name	
(
	@p_table_name nvarchar(250)
	,@p_sp_name	  nvarchar(250)
)
as
BEGIN
	select	name
	from	dbo.sys_report
	where	table_name = @p_table_name 
	and		sp_name	   = @p_sp_name;
end ;
