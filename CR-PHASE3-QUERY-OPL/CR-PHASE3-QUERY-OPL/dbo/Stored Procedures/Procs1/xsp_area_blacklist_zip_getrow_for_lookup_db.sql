--created by, Rian at 16/05/2023 

CREATE procedure dbo.xsp_area_blacklist_zip_getrow_for_lookup_db
(
	@p_area_blacklist_transaction_code nvarchar(50)
)
as
begin
	select		city_code
	from		dbo.area_blacklist_transaction_detail
	where	area_blacklist_transaction_code = @p_area_blacklist_transaction_code ;
end ;
