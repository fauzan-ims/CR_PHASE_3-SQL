CREATE PROCEDURE [dbo].[xsp_agreement_main_lookup_for_stop_billing]
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)

)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	agreement_main
	where	agreement_status	= 'GO LIVE'
			and is_stop_billing = '0'
			and
			(
				agreement_no like '%' + @p_keywords + '%'
				or	agreement_external_no like '%' + @p_keywords + '%'
				or	client_name like '%' + @p_keywords + '%'
			) ;

	select		agreement_no
				,agreement_external_no
				,client_no
				,client_name
				,@rows_count 'rowcount'
	from		agreement_main
	where		agreement_status	= 'GO LIVE'
				and is_stop_billing = '0'
				and
				(
					agreement_no like '%' + @p_keywords + '%'
					or	agreement_external_no like '%' + @p_keywords + '%'
					or	client_name like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then agreement_external_no
													 when 2 then client_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then agreement_external_no
													   when 2 then client_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
