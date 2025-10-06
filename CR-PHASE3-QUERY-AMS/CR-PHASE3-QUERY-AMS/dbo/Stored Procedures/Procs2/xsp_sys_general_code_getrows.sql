CREATE PROCEDURE dbo.xsp_sys_general_code_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sys_general_code
	where	company_code = @p_company_code
	and		(
				code						like '%' + @p_keywords + '%'
				or	description				like '%' + @p_keywords + '%'
				or	case is_editable
						when '1' then 'Yes'
						else 'No'
					end						like '%' + @p_keywords + '%'
			) ;

		select		code
					,description
					,case is_editable
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_editable'
					,@rows_count 'rowcount'
		from		sys_general_code
		where		company_code = @p_company_code
		and			(
						code						like '%' + @p_keywords + '%'
						or	description				like '%' + @p_keywords + '%'
						or	case is_editable
								when '1' then 'Yes'
								else 'No'
							end						like '%' + @p_keywords + '%'
					) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then code
													when 2 then description
													when 3 then is_editable
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then code
													when 2 then description
													when 3 then is_editable
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
