CREATE PROCEDURE dbo.xsp_change_item_type_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_branch_code	  nvarchar(50)
	,@p_status		  nvarchar(20)
	,@p_company_code  nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
		and		value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	change_item_type
	where	branch_code			  = case @p_branch_code
										when 'ALL' then branch_code
										else @p_branch_code
									end

			and status			  = case @p_status
										when 'ALL' then status
										else @p_status
									end
			and company_code  = @p_company_code
			and (
					code									like '%' + @p_keywords + '%'
					or	convert(varchar(30), date, 103)		like '%' + @p_keywords + '%'
					or	branch_name							like '%' + @p_keywords + '%'
					or	from_item_name						like '%' + @p_keywords + '%'
					or	to_item_name						like '%' + @p_keywords + '%'
					or	status								like '%' + @p_keywords + '%'
				) ;

	select		code
				,convert(varchar(30), date, 103) 'date'
				,description
				,branch_code
				,branch_name
				,from_item_code
				,from_item_name
				,to_item_code
				,to_item_name
				,from_category_code
				,from_category_name
				,original_price_amount
				,net_book_value_amount
				,remark
				,status
				,@rows_count					 'rowcount'
	from		change_item_type
	where		branch_code			  = case @p_branch_code
											when 'ALL' then branch_code
											else @p_branch_code
										end

				and status			  = case @p_status
											when 'ALL' then status
											else @p_status
										end
				and company_code  = @p_company_code
				and (
					code									like '%' + @p_keywords + '%'
					or	convert(varchar(30), date, 103)		like '%' + @p_keywords + '%'
					or	branch_name							like '%' + @p_keywords + '%'
					or	from_item_name						like '%' + @p_keywords + '%'
					or	to_item_name						like '%' + @p_keywords + '%'
					or	status								like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then branch_name
													 when 3 then cast(date as sql_variant)
													 when 4 then from_item_name
													 when 5 then to_item_name
													 when 6 then status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
														when 2 then branch_name
														when 3 then cast(date as sql_variant)
														when 4 then from_item_name
														when 5 then to_item_name
														when 6 then status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
