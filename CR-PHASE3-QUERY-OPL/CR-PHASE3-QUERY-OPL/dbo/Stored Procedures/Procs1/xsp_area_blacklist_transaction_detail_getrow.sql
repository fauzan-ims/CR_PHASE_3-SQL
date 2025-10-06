--created by, Rian at 16/05/2023 

CREATE PROCEDURE dbo.xsp_area_blacklist_transaction_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
		   ,area_blacklist_transaction_code
		   ,province_code
		   ,city_code
		   ,province_name
		   ,city_name
	from	area_blacklist_transaction_detail
	where	id = @p_id ;
end ;
