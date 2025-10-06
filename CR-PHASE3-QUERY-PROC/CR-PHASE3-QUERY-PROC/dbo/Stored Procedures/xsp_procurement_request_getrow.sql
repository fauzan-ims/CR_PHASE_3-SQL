CREATE PROCEDURE [dbo].[xsp_procurement_request_getrow]
(
	@p_code			 nvarchar(50)
	,@p_company_code nvarchar(50)
)
as
begin

	declare	@count_item	int

	select	@count_item = count(1)
	from	dbo.procurement_request_item
	where	procurement_request_code = @p_code ;

	select	 pr.code
			,pr.company_code
			,pr.request_date
			,pr.requestor_code
			,pr.requestor_name
			,pr.requirement_type
			,pr.branch_code
			,pr.branch_name
			,pr.division_code
			,pr.division_name
			,pr.department_code
			,pr.department_name
			,pr.status
			,pr.remark
			,prc.status 'procurement_status'
			,pr.remark_return
			,pr.is_reimburse
			,pr.procurement_type
			,procurement_type
			,to_province_code
			,to_province_name
			,to_city_code
			,to_city_name
			,to_area_phone_no
			,to_phone_no
			,to_address
			,eta_date
			,pr.from_province_code
			,pr.from_province_name
			,pr.from_city_code
			,pr.from_city_name
			,pr.from_area_phone_no
			,pr.from_phone_no
			,pr.from_address
			,@count_item 'count_item'
			,pr.mobilisasi_type
	from	procurement_request pr
	left join dbo.procurement prc					on (prc.procurement_request_code = pr.code)
	where	pr.code			 = @p_code
			and pr.company_code = @p_company_code ;
end ;
