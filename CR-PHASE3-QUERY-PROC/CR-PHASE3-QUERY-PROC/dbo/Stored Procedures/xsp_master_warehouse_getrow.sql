CREATE PROCEDURE dbo.xsp_master_warehouse_getrow
(
	@p_code				nvarchar(50)
	,@p_company_code	nvarchar(50)
) as
begin

	select	 code
			,company_code
			,branch_code
			,branch_name
			,description
			,city_code
			,city_name
			,address
			,pic
			,is_active
	from	master_warehouse
	where	code	= @p_code
	and company_code	= @p_company_code
end
