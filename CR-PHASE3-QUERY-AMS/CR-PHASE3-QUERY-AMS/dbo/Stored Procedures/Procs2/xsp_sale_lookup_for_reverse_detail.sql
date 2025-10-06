CREATE PROCEDURE dbo.xsp_sale_lookup_for_reverse_detail
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
	,@p_branch_code		nvarchar(50)
	,@p_location_code	nvarchar(50)
	,@p_sale_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select 	@rows_count = count(1) 
	from 	sale sle
			inner join dbo.sale_detail sld on sld.sale_code = sle.code 
			inner join dbo.asset ast on ast.code = sld.asset_code
	where	sle.status = 'POST' 
	and		ast.status = 'SOLD'
	and		sle.company_code = @p_company_code
	and		sle.branch_code = @p_branch_code
	and		sld.asset_code not in (select rsd.asset_code
									from dbo.reverse_sale rs
									inner join dbo.reverse_sale_detail rsd on (rs.code = rsd.reverse_sale_code)
									where company_code = @p_company_code
									and rs.sale_code = @p_sale_code
									and status in ('NEW', 'ON PROGRESS'))
	and		sld.sale_code = @p_sale_code
	and		(
				sle.code										 like '%' + @p_keywords + '%'
				or  ast.code									 like '%' + @p_keywords + '%'
				or  ast.item_name								 like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), sle.sale_date, 103)	 like '%' + @p_keywords + '%'
				or	sle.branch_name								 like '%' + @p_keywords + '%'
				or	ast.barcode									 like '%' + @p_keywords + '%'
				or	sle.buyer									 like '%' + @p_keywords + '%'
				or	sle.sale_amount								 like '%' + @p_keywords + '%'
				or	sle.status									 like '%' + @p_keywords + '%'
			) ;

	select 	sle.code 'sale_no' 
			,sle.company_code
			,convert(nvarchar(30), sle.sale_date, 103) 'sale_date_lookup'
			,ast.item_name
			,sle.branch_code
			,sle.branch_name
			,sle.buyer
			,sle.buyer_phone_no
			,ast.barcode
			,sle.sale_amount
			,sle.remark
			,sle.status
			,ast.code 'asset_code'
			,@rows_count 'rowcount'
	from	sale  sle 
			inner join dbo.sale_detail sld on sld.sale_code = sle.code 
			inner join dbo.asset ast on ast.code = sld.asset_code
	where	sle.status = 'POST'
	and		ast.status = 'SOLD'
	and		sle.company_code = @p_company_code
	and		sle.branch_code = @p_branch_code
	and		sld.asset_code not in (select rsd.asset_code
									from dbo.reverse_sale rs
									inner join dbo.reverse_sale_detail rsd on (rs.code = rsd.reverse_sale_code)
									where company_code = @p_company_code
									and rs.sale_code = @p_sale_code
									and status in ('NEW', 'ON PROGRESS'))
	and		sld.sale_code = @p_sale_code
	and		(
				sle.code										 like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), sle.sale_date, 103)	 like '%' + @p_keywords + '%'
				or  ast.code									 like '%' + @p_keywords + '%'
				or  ast.item_name								 like '%' + @p_keywords + '%'
				or	sle.branch_name								 like '%' + @p_keywords + '%'
				or	ast.barcode									 like '%' + @p_keywords + '%'
				or	sle.buyer									 like '%' + @p_keywords + '%'
				or	sle.sale_amount								 like '%' + @p_keywords + '%'
				or	sle.status									 like '%' + @p_keywords + '%'
			)
	order by	
			case
				when @p_sort_by = 'asc' then case @p_order_by
												when 1 then ast.code
												when 2 then ast.item_name
											end
				end asc
			,case
			when @p_sort_by = 'desc' then case @p_order_by
											 when 1 then ast.code
										     when 2 then ast.item_name
										   end
			end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
