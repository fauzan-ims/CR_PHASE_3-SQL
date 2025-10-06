CREATE PROCEDURE dbo.xsp_application_amortization_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_asset_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_amortization
	where	asset_no = @p_asset_no
			and (
					installment_no								like '%' + @p_keywords + '%'
					or	convert(varchar(30), due_date, 103)		like '%' + @p_keywords + '%'
					or	convert(varchar(30), billing_date, 103)	like '%' + @p_keywords + '%'
					or	billing_amount							like '%' + @p_keywords + '%' 
					or	description								like '%' + @p_keywords + '%' 
				) ;

	select		asset_no
				,installment_no
				,convert(varchar(30), due_date, 103) 'due_date'
				,convert(varchar(30), billing_date, 103) 'billing_date'
				,billing_amount 
				,description
				,@rows_count 'rowcount'
	from		application_amortization
	where		asset_no = @p_asset_no
				and (
						installment_no								like '%' + @p_keywords + '%'
						or	convert(varchar(30), due_date, 103)		like '%' + @p_keywords + '%'
						or	convert(varchar(30), billing_date, 103)	like '%' + @p_keywords + '%'
						or	billing_amount							like '%' + @p_keywords + '%' 
						or	description								like '%' + @p_keywords + '%' 
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then cast(installment_no as sql_variant)
														when 2 then convert(varchar(30), due_date, 103) 
														when 3 then convert(varchar(30), billing_date, 103) 
														when 4 then cast(billing_amount as sql_variant)  
														when 5 then description
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then cast(installment_no as sql_variant)
														when 2 then convert(varchar(30), due_date, 103) 
														when 3 then convert(varchar(30), billing_date, 103) 
														when 4 then cast(billing_amount as sql_variant)   
														when 5 then description
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;   
end ;

