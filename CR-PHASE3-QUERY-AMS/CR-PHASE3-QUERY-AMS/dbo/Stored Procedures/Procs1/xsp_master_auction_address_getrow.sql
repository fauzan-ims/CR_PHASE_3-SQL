CREATE procedure dbo.xsp_master_auction_address_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,auction_code
			,province_code
			,province_name
			,city_code
			,city_name
			,zip_code
			,sub_district
			,village
			,address
			,rt
			,rw
			,is_latest
	from	master_auction_address
	where	id = @p_id ;
end ;
