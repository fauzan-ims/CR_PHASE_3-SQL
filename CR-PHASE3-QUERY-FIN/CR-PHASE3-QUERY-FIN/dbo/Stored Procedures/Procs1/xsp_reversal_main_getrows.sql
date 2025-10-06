CREATE PROCEDURE dbo.xsp_reversal_main_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_reversal_status nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	reversal_main
	where	branch_code			= case @p_branch_code
									  when 'ALL' then branch_code
									  else @p_branch_code
								  end
			and reversal_status = case @p_reversal_status
									  when 'ALL' then reversal_status
									  else @p_reversal_status
								  end
			and (
					code											like '%' + @p_keywords + '%'
					or	branch_name									like '%' + @p_keywords + '%'
					or	convert(varchar(30), reversal_date, 103)	like '%' + @p_keywords + '%'
					or	source_reff_code							like '%' + @p_keywords + '%'
					or	source_reff_name							like '%' + @p_keywords + '%'
					or	reversal_remarks							like '%' + @p_keywords + '%'
					or	reversal_status								like '%' + @p_keywords + '%'
				) ;

		select		code
					,branch_name
					,convert(varchar(30), reversal_date, 103) 'reversal_date'
					,source_reff_code
					,source_reff_name
					,reversal_remarks
					,reversal_status
					,@rows_count 'rowcount'
		from		reversal_main
		where		branch_code			= case @p_branch_code
											  when 'ALL' then branch_code
											  else @p_branch_code
										  end
					and reversal_status = case @p_reversal_status
											  when 'ALL' then reversal_status
											  else @p_reversal_status
										  end
					and (
							code											like '%' + @p_keywords + '%'
							or	branch_name									like '%' + @p_keywords + '%'
							or	convert(varchar(30), reversal_date, 103)	like '%' + @p_keywords + '%'
							or	source_reff_code							like '%' + @p_keywords + '%'
							or	source_reff_name							like '%' + @p_keywords + '%'
							or	reversal_remarks							like '%' + @p_keywords + '%'
							or	reversal_status								like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then branch_name
														when 3 then cast(reversal_date as sql_variant)
														when 4 then source_reff_code
														when 5 then reversal_remarks
														when 6 then reversal_status
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then branch_name
														when 3 then cast(reversal_date as sql_variant)
														when 4 then source_reff_code
														when 5 then reversal_remarks
														when 6 then reversal_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
