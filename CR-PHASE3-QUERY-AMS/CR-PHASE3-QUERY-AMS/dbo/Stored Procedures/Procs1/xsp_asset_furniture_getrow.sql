CREATE PROCEDURE dbo.xsp_asset_furniture_getrow
(
	@p_asset_code nvarchar(50)
)
as
begin
	select	asset_code
			,merk_code
			,merk_name
			,type_code
			,type_name
			,model_code
			,model_name
			,purchase
			,no_lease_agreement		
			,date_of_lease_agreement
			,security_deposit		
			,total_rental_period	
			,rental_period			
			,rental_price			
			,total_rental_price		
			,start_rental_date		
			,end_rental_date		
			,remark
	from	asset_furniture
	where	asset_code = @p_asset_code ;
end ;
