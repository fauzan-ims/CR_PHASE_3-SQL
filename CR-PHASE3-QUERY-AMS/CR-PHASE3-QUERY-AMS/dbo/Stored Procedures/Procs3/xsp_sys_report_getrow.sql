
CREATE PROCEDURE [dbo].[xsp_sys_report_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,name
			,report_type
			,table_name
			,sp_name
			,screen_name
			,rpt_name
			,is_active
	from	sys_report
	where	code = @p_code ;
end ;
