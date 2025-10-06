---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[xsp_master_vehicle_pricelist_getrow]
(
	@p_code			nvarchar(50)
) as
begin

	select		p.code
				,p.description
				,p.vehicle_category_code
				,c.description 'vehicle_category_name'
				,p.vehicle_subcategory_code
				,s.description 'vehicle_subcategory_name'
				,p.vehicle_merk_code
				,m.description 'vehicle_merk_name'
				,p.vehicle_model_code
				,mo.description 'vehicle_model_name'
				,p.vehicle_type_code
				,t.description 'vehicle_type_name'
				,p.vehicle_unit_code
				,u.description 'vehicle_unit_name'
				,p.asset_year
				,p.condition
				,p.is_active
	from	master_vehicle_pricelist p
			inner join dbo.master_vehicle_category c on (c.CODE = p.VEHICLE_CATEGORY_CODE)
			inner join dbo.master_vehicle_subcategory s on (s.CODE = p.VEHICLE_SUBCATEGORY_CODE)
			inner join dbo.master_vehicle_merk m on (m.code = p.vehicle_merk_code)
			inner join dbo.master_vehicle_model mo on (mo.code = p.vehicle_model_code)
			inner join dbo.master_vehicle_type t on (t.code = p.vehicle_type_code)
			inner join dbo.master_vehicle_unit u on (u.CODE = p.VEHICLE_UNIT_CODE)
	where	p.code	= @p_code
end


