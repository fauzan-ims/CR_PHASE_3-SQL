CREATE PROCEDURE dbo.xsp_register_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,register_code
			,service_code
	from	register_detail
	where	id = @p_id ;
end ;
