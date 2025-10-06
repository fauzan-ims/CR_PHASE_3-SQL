CREATE procedure dbo.xsp_asset_property_upload_getrow
(
	@p_fa_upload_id bigint
)
as
begin
	select	fa_upload_id
			,file_name
			,upload_no
			,asset_code
			,imb_no
			,certificate_no
			,land_size
			,building_size
			,status_of_ruko
			,number_of_ruko_and_floor
			,total_square
			,vat
			,no_lease_agreement
			,date_of_lease_agreement
			,land_and_building_tax
			,security_deposit
			,penalty
			,owner
			,address
			,purchase
			,total_rental_period
			,rental_period
			,rental_price_per_year
			,rental_price_per_month
			,total_rental_price
			,start_rental_date
			,end_rental_date
			,remark
	from	asset_property_upload
	where	FA_UPLOAD_ID = @p_fa_upload_id ;
end ;
