CREATE PROCEDURE dbo.xsp_maintenance_detail_getrows_for_work_order
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_maintenance_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	maintenance_detail md
			inner join dbo.maintenance mnt on (mnt.code = md.maintenance_code)
			inner join dbo.asset ass on (ass.code = mnt.asset_code) 
	where	maintenance_code = @p_maintenance_code
	and		(
				md.service_code			 like '%' + @p_keywords + '%'
				or	md.service_name		 like '%' + @p_keywords + '%'
				or	md.service_fee		 like '%' + @p_keywords + '%'
				or	md.pph_amount		 like '%' + @p_keywords + '%'
				or	md.ppn_amount		 like '%' + @p_keywords + '%'
				or	md.quantity			 like '%' + @p_keywords + '%'
				or	md.total_amount		 like '%' + @p_keywords + '%'
				or	md.payment_amount	 like '%' + @p_keywords + '%'
				or	md.tax_name			 like '%' + @p_keywords + '%'
			) ;

	select		id
				,maintenance_code
				,md.service_code
				,md.service_name
				,file_name
				,path
				,ass.type_code
				,md.service_fee
				,md.pph_amount
				,md.ppn_amount
				,md.total_amount
				,md.quantity
				,md.payment_amount
				,md.tax_name
				,@rows_count 'rowcount'
	from		maintenance_detail md 
				inner join dbo.maintenance mnt on (mnt.code = md.maintenance_code)
				inner join dbo.asset ass on (ass.code = mnt.asset_code) 
	where		maintenance_code = @p_maintenance_code
	and			(
					md.service_code			 like '%' + @p_keywords + '%'
					or	md.service_name		 like '%' + @p_keywords + '%'
					or	md.service_fee		 like '%' + @p_keywords + '%'
					or	md.pph_amount		 like '%' + @p_keywords + '%'
					or	md.ppn_amount		 like '%' + @p_keywords + '%'
					or	md.quantity			 like '%' + @p_keywords + '%'
					or	md.total_amount		 like '%' + @p_keywords + '%'
					or	md.payment_amount	 like '%' + @p_keywords + '%'
					or	md.tax_name			 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then md.service_code
													 when 2 then cast(md.service_fee as sql_variant)
													 when 3 then cast(md.quantity as sql_variant)
													 when 4 then cast(md.total_amount as sql_variant)
													 when 5 then md.tax_name
													 when 6 then cast(md.pph_amount + md.ppn_amount as sql_variant)
													 when 7 then cast(md.payment_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then md.service_code
													 when 2 then cast(md.service_fee as sql_variant)
													 when 3 then cast(md.quantity as sql_variant)
													 when 4 then cast(md.total_amount as sql_variant)
													 when 5 then md.tax_name
													 when 6 then cast(md.pph_amount + md.ppn_amount as sql_variant)
													 when 7 then cast(md.payment_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
