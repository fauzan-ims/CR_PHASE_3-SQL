CREATE PROCEDURE dbo.xsp_sale_lookup_for_reverse
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select 	@rows_count = count(1) 
	from 	sale sle
	outer apply
				(
					select top 1
								sale_code
								,ast.status
								,sd.asset_code
								,ast.barcode
					from		dbo.sale_detail sd
					inner join dbo.asset ast on (ast.code = sd.asset_code)
					where		sale_code = sle.code
					order by	id desc
				) SaleDetail 
	where	sle.status = 'POST' 
	and		SaleDetail.status = 'SOLD'
	and		sle.company_code = @p_company_code
	and		SaleDetail.sale_code not in (select sale_code
									from dbo.reverse_sale 
									where company_code = @p_company_code 
									and status in ('NEW', 'ON PROGRESS'))
	and		(
				sle.code											like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), sle.sale_date, 103)		like '%' + @p_keywords + '%'
				or	sle.description									like '%' + @p_keywords + '%'
				or	saledetail.asset_code							like '%' + @p_keywords + '%'
				or	saledetail.barcode								like '%' + @p_keywords + '%'
			) ;

	select 	sle.code 'sale_no' 
			,convert(nvarchar(30), sle.sale_date, 103) 'sale_date_lookup'
			,sle.description
			,sle.branch_code
			,sle.branch_name
			,sle.buyer
			,sle.buyer_phone_no
			,sle.sale_amount
			,sle.remark
			,sle.status
			,@rows_count 'rowcount'
	from	sale  sle
	outer apply
				(
					select top 1
								sale_code
								,ast.status
								,sd.asset_code
								,ast.barcode
					from		dbo.sale_detail sd
					inner join dbo.asset ast on (ast.code = sd.asset_code)
					where		sale_code = sle.code
					order by	id desc
				) SaleDetail  
	where	sle.status = 'POST'
	and		SaleDetail.status = 'SOLD'
	and		sle.company_code = @p_company_code
	and		SaleDetail.sale_code not in (select sale_code
									from dbo.reverse_sale 
									where company_code = @p_company_code 
									and status in ('NEW', 'ON PROGRESS'))
	and		(
				sle.code										like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), sle.sale_date, 103)	like '%' + @p_keywords + '%'
				or	sle.description								like '%' + @p_keywords + '%'
				or	saledetail.asset_code						like '%' + @p_keywords + '%'
				or	saledetail.barcode							like '%' + @p_keywords + '%'
			)
	order by	
			case
				when @p_sort_by = 'asc' then case @p_order_by
												when 1 then sle.code
												when 2 then cast(sle.sale_date as sql_variant)
												when 3 then sle.description
											end
				end asc
			,case
			when @p_sort_by = 'desc' then case @p_order_by
												when 1 then sle.code
												when 2 then cast(sle.sale_date as sql_variant)
												when 3 then sle.description
										   end
			end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
