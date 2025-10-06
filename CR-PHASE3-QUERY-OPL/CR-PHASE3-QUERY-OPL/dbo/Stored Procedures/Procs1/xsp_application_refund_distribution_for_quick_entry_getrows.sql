CREATE procedure [dbo].[xsp_application_refund_distribution_for_quick_entry_getrows]
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
	from	application_refund_distribution ard
			inner join dbo.application_refund ar on (ar.code = ard.application_refund_code)
			inner join master_refund mf on (mf.code = ar.refund_code)
			outer apply
	(
		select	isnull(sum(ard.distribution_amount), 0) 'distribution_amount'
		from	application_refund_distribution ard
		where	ard.application_refund_code = ar.code
	) refundDistributed
	where	ar.application_no = @p_application_no
			and (
					mf.description				like '%' + @p_keywords + '%'
					or	ar.refund_amount		like '%' + @p_keywords + '%'
					or	ard.staff_position_name like '%' + @p_keywords + '%'
					or	ard.refund_pct			like '%' + @p_keywords + '%'
					or	ard.distribution_amount like '%' + @p_keywords + '%'
					or	ard.staff_name			like '%' + @p_keywords + '%'
				) ;

	select		id
				,mf.description 'refund_desc'
				,ar.refund_amount
				,staff_name
				,staff_position_name
				,ard.refund_pct
				,ard.distribution_amount 
				,@rows_count 'rowcount'
	from		application_refund_distribution ard
				inner join dbo.application_refund ar on (ar.code = ard.application_refund_code)
				inner join master_refund mf on (mf.code = ar.refund_code)
				outer apply
	(
		select	isnull(sum(ard.distribution_amount), 0) 'distribution_amount'
		from	application_refund_distribution ard
		where	ard.application_refund_code = ar.code
	) refundDistributed
	where		ar.application_no = @p_application_no
				and (
						mf.description				like '%' + @p_keywords + '%'
						or	ar.refund_amount		like '%' + @p_keywords + '%'
						or	ard.staff_position_name like '%' + @p_keywords + '%'
						or	ard.refund_pct			like '%' + @p_keywords + '%'
						or	ard.distribution_amount like '%' + @p_keywords + '%'
						or	ard.staff_name			like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mf.description
													 when 2 then cast(ar.refund_amount as sql_variant)
													 when 3 then ard.staff_position_name
													 when 4 then cast(ard.refund_pct as sql_variant)
													 when 5 then cast(ard.distribution_amount as sql_variant)
													 when 6 then ard.staff_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then mf.description
													   when 2 then cast(ar.refund_amount as sql_variant)
													   when 3 then ard.staff_position_name
													   when 4 then cast(ard.refund_pct as sql_variant)
													   when 5 then cast(ard.distribution_amount as sql_variant)
													   when 6 then ard.staff_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

