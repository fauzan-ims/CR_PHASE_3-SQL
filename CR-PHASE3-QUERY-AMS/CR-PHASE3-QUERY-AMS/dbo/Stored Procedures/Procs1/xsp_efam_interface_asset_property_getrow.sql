CREATE procedure dbo.xsp_efam_interface_asset_property_getrow
(
	@p_asset_code nvarchar(50)
)
as
begin
	select	asset_code
			,imb_no
			,certificate_no
			,land_size
			,building_size
			,status_of_ruko
			,number_of_ruko_and_floor
			,total_square
			,pph
			,vat
			,no_lease_agreement
			,date_of_lease_agreement
			,land_and_building_tax
			,security_deposit
			,penalty
			,owner
			,address
			,total_rental_period
			,rental_period
			,rental_price_per_year
			,rental_price_per_month
			,total_rental_price
			,start_rental_date
			,end_rental_date
			,remark
	from	efam_interface_asset_property
	where	asset_code = @p_asset_code ;
end ;
