CREATE PROCEDURE [dbo].[xsp_application_deviation_getrows]
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_application_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_deviation ad
			inner join master_deviation md on (md.code = ad.deviation_code)
	where	ad.application_no = @p_application_no
			and (
					md.description				like '%' + @p_keywords + '%'
					or	ad.remarks				like '%' + @p_keywords + '%'
					or	ad.position_name		like '%' + @p_keywords + '%'
					or	case ad.is_manual
							when '1' then 'Yes'
							else 'No'
						end						like '%' + @p_keywords + '%'
				) ;

	select		id
				,md.description 'deviation_desc'
				,ad.position_name
				,ad.remarks
				,case ad.is_manual
						when '1' then 'Yes'
						else 'No'
					end 'is_manual'
				,@rows_count 'rowcount'
	from		application_deviation ad
				inner join master_deviation md on (md.code = ad.deviation_code)
	where		ad.application_no = @p_application_no
				and (
						md.description				like '%' + @p_keywords + '%'
						or	ad.position_name		like '%' + @p_keywords + '%'
						or	ad.remarks				like '%' + @p_keywords + '%'
						or	case ad.is_manual
								when '1' then 'Yes'
								else 'No'
							end						like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then md.description
														when 2 then ad.remarks
														when 3 then ad.position_name
														when 4 then ad.is_manual
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then md.description
														when 2 then ad.remarks
														when 3 then ad.position_name
														when 4 then ad.is_manual
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;  
end ;

