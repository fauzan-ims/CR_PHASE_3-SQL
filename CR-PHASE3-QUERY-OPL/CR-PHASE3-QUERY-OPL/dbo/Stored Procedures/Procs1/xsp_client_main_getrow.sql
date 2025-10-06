CREATE PROCEDURE dbo.xsp_client_main_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	cm.code
			,cm.client_no
			,cm.client_type
			,cm.client_name
			,cm.is_validate
			,cm.watchlist_status
			,cm.status_slik_checking
			,cm.status_dukcapil_checking
	from	client_main cm
	where	cm.code = @p_code ;
end ;

