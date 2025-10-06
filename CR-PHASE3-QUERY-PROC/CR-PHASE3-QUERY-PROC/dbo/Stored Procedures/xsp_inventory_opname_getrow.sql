
create procedure xsp_inventory_opname_getrow
(
	 @p_code				nvarchar(50)
	,@p_company_code		nvarchar(50)
) as
begin

	select	 code
			,company_code
			,opname_date
			,branch_code
			,branch_name
			,warehouse_code
			,item_code
			,item_name
			,uom_code
			,uom_name
			,quantity_stock
			,quantity_opname
			,quantity_deviation
			,status
	from	inventory_opname
	where		code			= @p_code
			and company_code	= @p_company_code
end
