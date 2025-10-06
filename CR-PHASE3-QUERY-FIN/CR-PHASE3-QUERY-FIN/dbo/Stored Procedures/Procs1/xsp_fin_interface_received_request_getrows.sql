CREATE PROCEDURE dbo.xsp_fin_interface_received_request_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_branch_code			nvarchar(50)
	,@p_received_status		nvarchar(10)
	,@p_job_status			nvarchar(10) = 'ALL'
)
as
begin

    declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	fin_interface_received_request
	where	branch_code		= case @p_branch_code
										  when 'ALL' then branch_code
										  else @p_branch_code
									  end
			and received_status = case @p_received_status
										  when 'ALL' then received_status
										  else @p_received_status
									  end
			and  job_status = case @p_job_status
										when 'ALL' then job_status
										else @p_job_status
								   end
			and	(
					code													like '%' + @p_keywords + '%'
					or	branch_name											like '%' + @p_keywords + '%'
					or	received_source										like '%' + @p_keywords + '%'
					or	received_source_no									like '%' + @p_keywords + '%'
					or	convert(varchar(30), received_request_date, 103)	like '%' + @p_keywords + '%'
					or	convert(varchar(30), mod_date, 103)					like '%' + @p_keywords + '%'
					or	received_currency_code								like '%' + @p_keywords + '%'
					or	received_amount										like '%' + @p_keywords + '%'
					or	received_status										like '%' + @p_keywords + '%'
					or	received_remarks									like '%' + @p_keywords + '%'
			) ;

		select	code
				,branch_name
				,received_source 
				,received_source_no 
				,convert(varchar(30), received_request_date, 103) 'received_request_date'
				,convert(varchar(30), mod_date, 103) 'mod_date'
				,received_currency_code
				,received_amount
				,received_remarks
				,received_status
				,job_status
				,@rows_count 'rowcount'
		from	fin_interface_received_request
		where	branch_code		= case @p_branch_code
											  when 'ALL' then branch_code
											  else @p_branch_code
										  end
				and received_status = case @p_received_status
											  when 'ALL' then received_status
											  else @p_received_status
										  end
				and  job_status = case @p_job_status
										when 'ALL' then job_status
										else @p_job_status
								   end
				and	(
						code													like '%' + @p_keywords + '%'
						or	branch_name											like '%' + @p_keywords + '%'
						or	received_source										like '%' + @p_keywords + '%'
						or	received_source_no									like '%' + @p_keywords + '%'
						or	convert(varchar(30), received_request_date, 103)	like '%' + @p_keywords + '%'
						or	convert(varchar(30), mod_date, 103)					like '%' + @p_keywords + '%'
						or	received_currency_code								like '%' + @p_keywords + '%'
						or	received_amount										like '%' + @p_keywords + '%'
						or	received_status										like '%' + @p_keywords + '%'
						or	received_remarks									like '%' + @p_keywords + '%'
					) 
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then branch_name
														when 3 then cast(received_request_date as sql_variant)
														when 4 then received_source_no									
														when 5 then received_remarks	
														when 6 then cast(received_amount as sql_variant)
														when 7 then cast(mod_date as nvarchar(50))
														when 8 then received_status				
														when 9 then job_status				
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then branch_name
														when 3 then cast(received_request_date as sql_variant)
														when 4 then received_source_no									
														when 5 then received_remarks	
														when 6 then cast(received_amount as sql_variant)
														when 7 then cast(mod_date as nvarchar(50))
														when 8 then received_status				
														when 9 then job_status					
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end
