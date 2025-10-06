CREATE PROCEDURE [dbo].[xsp_dashboard_get_data]
(
	@p_code nvarchar(50)
)
as
begin
	declare @sp_name nvarchar(250)

	select	@sp_name = sp_name
	from	master_dashboard
	where	code = @p_code 

	exec @sp_name
end ;
