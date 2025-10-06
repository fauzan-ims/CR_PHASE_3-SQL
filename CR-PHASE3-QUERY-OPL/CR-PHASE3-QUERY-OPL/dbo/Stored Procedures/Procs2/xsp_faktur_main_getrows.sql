CREATE PROCEDURE dbo.xsp_faktur_main_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	--
	,@p_status		nvarchar(10)
)
as
begin

	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	faktur_main
	where   status	= case @p_status
										when 'ALL' then status
										else @p_status
									end
	and		(
					faktur_no				like 	'%'+@p_keywords+'%'
				or	year					like 	'%'+@p_keywords+'%'
				or	status					like 	'%'+@p_keywords+'%'
				or	registration_code		like 	'%'+@p_keywords+'%'
				or	invoice_no				like 	'%'+@p_keywords+'%'
		);

	select	faktur_no
			,year
			,status
			,registration_code
			,invoice_no
			,@rows_count	 'rowcount'
	from	faktur_main
	where   status	= case @p_status
										when 'ALL' then status
										else @p_status
									end
	and		(
						faktur_no				like 	'%'+@p_keywords+'%'
					or	year					like 	'%'+@p_keywords+'%'
					or	status					like 	'%'+@p_keywords+'%'
					or	registration_code		like 	'%'+@p_keywords+'%'
					or	invoice_no				like 	'%'+@p_keywords+'%'
			)
	order by	 case
			when @p_sort_by = 'asc' then case @p_order_by
			when 1	then faktur_no
			when 2	then year
			when 3	then registration_code
			when 4	then invoice_no
			when 5	then status
	end
		end asc
			 ,case
				when @p_sort_by = 'desc' then case @p_order_by
				when 1	then faktur_no
				when 2	then year
				when 3	then registration_code
				when 4	then invoice_no
				when 5	then status
	end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end
