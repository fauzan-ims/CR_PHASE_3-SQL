CREATE PROCEDURE dbo.xsp_insurance_policy_main_history_getrows
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_policy_code  nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	insurance_policy_main_history
	where	policy_code = @p_policy_code
			and (
					convert(varchar(30), history_date, 103)			like '%' + @p_keywords + '%'
					or	history_type	                            like '%' + @p_keywords + '%'
					or	policy_status	                            like '%' + @p_keywords + '%'
					or	history_remarks                             like '%' + @p_keywords + '%'
				) ;

		select		id
					,convert(varchar(30), history_date, 103) 'history_date'
					,history_type
					,policy_status
					,history_remarks
					,@rows_count 'rowcount'
		from		insurance_policy_main_history
		where		policy_code = @p_policy_code
					and (
							convert(varchar(30), history_date, 103)			like '%' + @p_keywords + '%'
							or	history_type	                            like '%' + @p_keywords + '%'
							or	policy_status	                            like '%' + @p_keywords + '%'
							or	history_remarks                             like '%' + @p_keywords + '%'
						)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then cast(history_date as sql_variant)
													when 2 then history_type
													when 3 then policy_status
													when 4 then history_remarks
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then cast(history_date as sql_variant)
													when 2 then history_type
													when 3 then policy_status
													when 4 then history_remarks
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

