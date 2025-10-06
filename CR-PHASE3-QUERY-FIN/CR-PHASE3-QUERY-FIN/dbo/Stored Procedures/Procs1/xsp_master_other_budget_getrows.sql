
-- Louis Kamis, 04 April 2024 16.52.12 --
CREATE procedure [dbo].[xsp_master_other_budget_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.master_other_budget mb
	where	(
				mb.code										like '%' + @p_keywords + '%'
				or	mb.description							like '%' + @p_keywords + '%'
				or	mb.class_code							like '%' + @p_keywords + '%'
				or	mb.class_description					like '%' + @p_keywords + '%'
				or	convert(varchar(30), mb.exp_date, 103)	like '%' + @p_keywords + '%'
				or	case mb.is_subject_to_purchase
						when '1' then 'Yes'
						else 'No'
					end										like '%' + @p_keywords + '%'
				or	case is_active
						when '1' then 'Yes'
						else 'No'
					end										like '%' + @p_keywords + '%'
			) ;

	select		mb.code
				,mb.description
				,mb.class_code
				,mb.class_description
				,convert(varchar(30), mb.exp_date, 103) 'exp_date'
				,case mb.is_subject_to_purchase
					 when '1' then 'Yes'
					 else 'No'
				 end 'is_subject_to_purchase'
				,case mb.is_active
					 when '1' then 'Yes'
					 else 'No'
				 end 'is_active'
				,@rows_count 'rowcount'
	from		dbo.master_other_budget mb
	where		(
					mb.code										like '%' + @p_keywords + '%'
					or	mb.description							like '%' + @p_keywords + '%'
					or	mb.class_code							like '%' + @p_keywords + '%'
					or	mb.class_description					like '%' + @p_keywords + '%'
					or	convert(varchar(30), mb.exp_date, 103)	like '%' + @p_keywords + '%'
					or	case mb.is_subject_to_purchase
							when '1' then 'Yes'
							else 'No'
						end										like '%' + @p_keywords + '%'
					or	case is_active
							when '1' then 'Yes'
							else 'No'
						end										like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mb.code
													 when 2 then mb.description
													 when 3 then mb.class_description
													 when 4 then cast(mb.exp_date as sql_variant)
													 when 5 then case mb.is_subject_to_purchase
																	 when '1' then 'Yes'
																	 else 'No'
																 end
													 when 6 then case mb.is_active
																	 when '1' then 'Yes'
																	 else 'No'
																 end
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then mb.code
													   when 2 then mb.description
													   when 3 then mb.class_description
													   when 4 then cast(mb.exp_date as sql_variant)
													   when 5 then case mb.is_subject_to_purchase
																	   when '1' then 'Yes'
																	   else 'No'
																   end
													   when 6 then case mb.is_active
																	   when '1' then 'Yes'
																	   else 'No'
																   end
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
