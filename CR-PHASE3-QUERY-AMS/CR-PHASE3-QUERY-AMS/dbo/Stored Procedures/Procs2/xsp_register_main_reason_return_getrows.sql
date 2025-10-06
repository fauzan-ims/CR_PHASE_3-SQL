CREATE PROCEDURE	[dbo].[xsp_register_main_reason_return_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_code	   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.REGISTER_MAIN rm
	where	rm.CODE = @p_code
			and
			(
				convert(varchar(30), rm.return_date, 103)	like '%' + @p_keywords + '%'
				or rm.return_by								like '%' + @p_keywords + '%'
				or rm.reason_return_code					like '%' + @p_keywords + '%'
				or rm.reason_return_desc					like '%' + @p_keywords + '%'
				or rm.reason_return_remark					like '%' + @p_keywords + '%'
			) ;

	select		convert(varchar(30), rm.return_date, 103) 'return_date'
				,rm.return_by
				,rm.reason_return_code
				,rm.reason_return_desc
				,rm.reason_return_remark
				,@rows_count 'rowcount'
	from		dbo.REGISTER_MAIN rm
	where		rm.CODE = @p_code
				and
				(
					convert(varchar(30), rm.return_date, 103)	like '%' + @p_keywords + '%'
					or rm.return_by								like '%' + @p_keywords + '%'
					or rm.reason_return_code					like '%' + @p_keywords + '%'
					or rm.reason_return_desc					like '%' + @p_keywords + '%'
					or rm.reason_return_remark					like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then cast(rm.return_date as sql_variant)
													 when 2 then rm.return_by
													 when 3 then rm.reason_return_desc
													 when 4 then rm.reason_return_remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then cast(rm.return_date as sql_variant)
													 when 2 then rm.return_by
													 when 3 then rm.reason_return_desc
													 when 4 then rm.reason_return_remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
