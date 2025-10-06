CREATE PROCEDURE dbo.xsp_master_dashboard_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,dashboard_name
			,dashboard_type
			,dashboard_grid
			,sp_name
			,is_active
			,is_editable
	from	master_dashboard
	where	code = @p_code ;
end ;
