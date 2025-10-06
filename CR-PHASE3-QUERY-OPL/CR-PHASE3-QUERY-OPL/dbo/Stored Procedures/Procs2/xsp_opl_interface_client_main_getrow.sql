create PROCEDURE dbo.xsp_opl_interface_client_main_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,code
			,client_type
			,client_no
			,client_name
			,is_validate
			,is_red_flag
			,watchlist_status
			,status_slik_checking
			,status_dukcapil_checking
	from	opl_interface_client_main
	where	id = @p_id ;
end ;

