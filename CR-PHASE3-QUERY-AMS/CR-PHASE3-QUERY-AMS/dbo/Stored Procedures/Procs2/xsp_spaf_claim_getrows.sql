CREATE PROCEDURE dbo.xsp_spaf_claim_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_status		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	spaf_claim
	where	status = case @p_status
						when 'ALL' then status
						else @p_status
					end
	and		(
				code									like '%' + @p_keywords + '%'
				or	convert(varchar(30), date, 103)		like '%' + @p_keywords + '%'
				or	status								like '%' + @p_keywords + '%'
				or	total_claim_amount					like '%' + @p_keywords + '%'
				or	remark								like '%' + @p_keywords + '%'
				or	claim_type							like '%' + @p_keywords + '%'
			) ;

	select		code
				,convert(varchar(30), date, 103) 'date'
				,status
				,total_claim_amount
				,remark
				,claim_type
				,@rows_count 'rowcount'
	from		spaf_claim
	where		status = case @p_status
						when 'ALL' then status
						else @p_status
					end
	and			(
					code									like '%' + @p_keywords + '%'
					or	convert(varchar(30), date, 103)		like '%' + @p_keywords + '%'
					or	status								like '%' + @p_keywords + '%'
					or	total_claim_amount					like '%' + @p_keywords + '%'
					or	remark								like '%' + @p_keywords + '%'
					or	claim_type							like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then cast(date as sql_variant)
													 when 3 then claim_type
													 when 4 then cast(total_claim_amount as sql_variant)
													 when 5 then remark
													 when 6 then status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then code
														when 2 then cast(date as sql_variant)
														when 3 then claim_type
														when 4 then cast(total_claim_amount as sql_variant)
														when 5 then remark
														when 6 then status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
