CREATE procedure dbo.xsp_agreement_obligation_lookup_inquiry
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_agreement_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	(
					select		distinct obligation_type 
								,obligation_name 'obligation_name'
					from		agreement_obligation
					where		agreement_no = @p_agreement_no
			) agob
	WHERE	 (
						agob.obligation_type			like '%' + @p_keywords + '%'
						or	agob.obligation_name		like '%' + @p_keywords + '%'
					);
	select	agob.obligation_type
			,agob.obligation_name
			,@rows_count 'rowcount'
	from	(
					select		DISTINCT obligation_type 
								,obligation_name 'obligation_name'
					from		agreement_obligation
					where		agreement_no = @p_agreement_no
			) agob
	WHERE	 (
						agob.obligation_type			like '%' + @p_keywords + '%'
						or	agob.obligation_name		like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then agob.obligation_type
													 when 2 then agob.obligation_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then agob.obligation_type
													   when 2 then agob.obligation_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
