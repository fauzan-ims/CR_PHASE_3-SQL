CREATE PROCEDURE [dbo].[xsp_get_data_master_dashboard_user]
as
begin
	select	distinct
			employee_code
	from	dbo.master_dashboard_user
end ;
