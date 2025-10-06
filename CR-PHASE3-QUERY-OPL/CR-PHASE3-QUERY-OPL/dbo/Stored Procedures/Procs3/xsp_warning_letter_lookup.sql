CREATE PROCEDURE dbo.xsp_warning_letter_lookup
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
	from	warning_letter wl
			inner join dbo.agreement_main am on (am.agreement_no = wl.agreement_no)
	where	(
				letter_no						like '%' + @p_keywords + '%'
				or	am.agreement_external_no	like '%' + @p_keywords + '%'
				or	am.client_name				like '%' + @p_keywords + '%'
				or	letter_type					like '%' + @p_keywords + '%'
				or	wl.letter_date				like '%' + @p_keywords + '%'
			) ;

		select		letter_no
					,am.agreement_external_no
					,am.client_name
					,letter_type
					,wl.letter_date
					,@rows_count 'rowcount'
		from		warning_letter wl
					inner join dbo.agreement_main am on (am.agreement_no = wl.agreement_no)
		where		(
						letter_no						like '%' + @p_keywords + '%'
						or	am.agreement_external_no	like '%' + @p_keywords + '%'
						or	am.client_name				like '%' + @p_keywords + '%'
						or	letter_type					like '%' + @p_keywords + '%'
						or	wl.letter_date				like '%' + @p_keywords + '%'
					)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then letter_no
													when 2 then am.agreement_external_no
													when 3 then am.client_name
													when 4 then letter_type
													when 5 then wl.letter_date
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then letter_no
														when 2 then am.agreement_external_no
														when 3 then am.client_name
														when 4 then letter_type
														when 5 then wl.letter_date
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;
