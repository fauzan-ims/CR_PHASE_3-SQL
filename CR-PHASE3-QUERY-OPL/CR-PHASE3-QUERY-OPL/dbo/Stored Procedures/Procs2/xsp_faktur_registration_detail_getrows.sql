CREATE procedure dbo.xsp_faktur_registration_detail_getrows
(
	@p_keywords			  nvarchar(50)
	,@p_pagenumber		  int
	,@p_rowspage		  int
	,@p_order_by		  int
	,@p_sort_by			  nvarchar(5)
	--
	,@p_registration_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	faktur_registration_detail
	where	registration_code = @p_registration_code
			and (faktur_no like '%' + @p_keywords + '%') ;

	select		id
				,registration_code
				,year
				,faktur_no
				,@rows_count 'rowcount'
	from		faktur_registration_detail
	where		registration_code = @p_registration_code
				and (faktur_no like '%' + @p_keywords + '%')
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then faktur_no
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then faktur_no
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
