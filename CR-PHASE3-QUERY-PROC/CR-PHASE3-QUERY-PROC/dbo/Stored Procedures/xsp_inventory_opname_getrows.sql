CREATE PROCEDURE dbo.xsp_inventory_opname_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_company_code   nvarchar(50)
	,@p_warehouse_code nvarchar(50)
	,@p_branch_code	   nvarchar(50)
	,@p_status		   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	inventory_opname				iop
			inner join dbo.master_warehouse mw on mw.code = iop.warehouse_code
	where	iop.company_code	   = @p_company_code
			and iop.warehouse_code = case @p_warehouse_code
										 when 'ALL' then iop.warehouse_code
										 else @p_warehouse_code
									 end
			and iop.branch_code	   = case @p_branch_code
										 when 'ALL' then iop.branch_code
										 else @p_branch_code
									 end
			and iop.status		   = case @p_status
										 when 'ALL' then iop.status
										 else @p_status
									 end
			and
			(
				iop.code										like '%' + @p_keywords + '%'
				or	convert(nvarchar(50), iop.opname_date, 103) like '%' + @p_keywords + '%'
				or	iop.item_name								like '%' + @p_keywords + '%'
				or	mw.description								like '%' + @p_keywords + '%'
				or	iop.quantity_stock							like '%' + @p_keywords + '%'
				or	iop.uom_name								like '%' + @p_keywords + '%'
				or	iop.quantity_opname							like '%' + @p_keywords + '%'
				or	iop.quantity_deviation						like '%' + @p_keywords + '%'
				or	iop.status									like '%' + @p_keywords + '%'
			) ;

	select		iop.code
				,iop.company_code
				,convert(nvarchar(50), iop.opname_date, 103) 'opname_date'
				,iop.branch_code
				,iop.branch_name
				,iop.warehouse_code
				,mw.description								 'warehouse_name'
				,iop.item_code
				,iop.item_name
				,iop.uom_code
				,iop.uom_name
				,iop.quantity_stock
				,iop.quantity_opname
				,iop.quantity_deviation
				,iop.status
				,@rows_count								 'rowcount'
	from		inventory_opname				iop
				inner join dbo.master_warehouse mw on mw.code = iop.warehouse_code
	where		iop.company_code	   = @p_company_code
				and iop.warehouse_code = case @p_warehouse_code
											 when 'ALL' then iop.warehouse_code
											 else @p_warehouse_code
										 end
				and iop.branch_code	   = case @p_branch_code
											 when 'ALL' then iop.branch_code
											 else @p_branch_code
										 end
				and iop.status		   = case @p_status
											 when 'ALL' then iop.status
											 else @p_status
										 end
				and
				(
					iop.code										like '%' + @p_keywords + '%'
					or	convert(nvarchar(50), iop.opname_date, 103) like '%' + @p_keywords + '%'
					or	iop.item_name								like '%' + @p_keywords + '%'
					or	mw.description								like '%' + @p_keywords + '%'
					or	iop.quantity_stock							like '%' + @p_keywords + '%'
					or	iop.uom_name								like '%' + @p_keywords + '%'
					or	iop.quantity_opname							like '%' + @p_keywords + '%'
					or	iop.quantity_deviation						like '%' + @p_keywords + '%'
					or	iop.status									like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													-- when 1 then iop.code
													 when 1 then cast(iop.opname_date as sql_variant)
													 when 2 then iop.item_name
													 when 3 then mw.description
													 when 4 then cast(iop.quantity_stock as sql_variant)
													 when 5 then cast(iop.quantity_opname as sql_variant)
													 when 6 then iop.uom_name
													 when 7 then cast(iop.quantity_deviation as sql_variant)
													 when 8 then iop.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then cast(iop.opname_date as sql_variant)
													   when 2 then iop.item_name
													   when 3 then mw.description
													   when 4 then cast(iop.quantity_stock as sql_variant)
													   when 5 then cast(iop.quantity_opname as sql_variant)
													   when 6 then iop.uom_name
													   when 7 then cast(iop.quantity_deviation as sql_variant)
													   when 8 then iop.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
