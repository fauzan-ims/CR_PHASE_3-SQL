--created by, Rian at 11/05/2023	

CREATE procedure dbo.xsp_master_budget_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	--
	,@p_type	   nvarchar(15)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.master_budget mb
	where	mb.type = @p_type
			and (
					mb.code										like '%' + @p_keywords + '%'
					or	mb.type									like '%' + @p_keywords + '%'
					or	mb.class_code							like '%' + @p_keywords + '%'
					or	mb.class_description					like '%' + @p_keywords + '%'
					or	convert(varchar(30), mb.exp_date, 103)	like '%' + @p_keywords + '%'
					or	case is_active
							when '1' then 'Yes'
							else 'No'
						end 									like '%' + @p_keywords + '%'
				) ;

	select		mb.code
				,mb.type
				,mb.class_code
				,mb.class_description
				,convert(varchar(30), mb.exp_date, 103) 'exp_date'
				,case mb.is_active
					 when '1' then 'Yes'
					 else 'No'
				 end 'is_active'
				,@rows_count 'rowcount'
	from		dbo.master_budget mb
	where		mb.type = @p_type
				and (
						mb.code										like '%' + @p_keywords + '%'
						or	mb.type									like '%' + @p_keywords + '%'
						or	mb.class_code							like '%' + @p_keywords + '%'
						or	mb.class_description					like '%' + @p_keywords + '%'
						or	convert(varchar(30), mb.exp_date, 103)	like '%' + @p_keywords + '%'
						or	case is_active
								when '1' then 'Yes'
								else 'No'
							end 									like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mb.code
													 when 2 then mb.class_description
													 when 3 then cast(mb.exp_date as sql_variant)
													 when 4 then mb.is_active
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then mb.code
													   when 2 then mb.class_description
													   when 3 then cast(mb.exp_date as sql_variant)
													   when 4 then mb.is_active
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
