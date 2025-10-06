CREATE procedure dbo.xsp_application_fee_getrows
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
	from	application_fee af
			inner join dbo.master_fee mf on (mf.code = af.fee_code)
	where	af.application_no = @p_application_no
			and (
					mf.description		like '%' + @p_keywords + '%'
					or	fee_amount		like '%' + @p_keywords + '%'
					or	currency_code	like '%' + @p_keywords + '%'
				) ;

	select		af.id
				,mf.description 'fee_desc'
				,af.fee_amount
				,af.is_calculated
				,af.currency_code
				,@rows_count 'rowcount'
	from		application_fee af
				inner join dbo.master_fee mf on (mf.code = af.fee_code)
	where		af.application_no = @p_application_no
				and (
						mf.description		like '%' + @p_keywords + '%'
						or	af.fee_amount	like '%' + @p_keywords + '%'
						or	currency_code	like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mf.description
													 when 2 then af.currency_code
													 when 3 then cast(af.fee_amount as nvarchar(20))
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then mf.description
													   when 2 then af.currency_code
													   when 3 then cast(af.fee_amount as nvarchar(20))
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
