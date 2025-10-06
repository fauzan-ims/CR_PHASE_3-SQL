CREATE PROCEDURE [dbo].[xsp_sys_job_tasklist_getrows]
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.sys_job_tasklist
	where	type = 'EOD'
			and (
				description											like '%' + @p_keywords + '%'
				or	sp_name											like '%' + @p_keywords + '%'
				or	order_no										like '%' + @p_keywords + '%'
				or	eod_status										like '%' + @p_keywords + '%'
				or	eod_remark										like '%' + @p_keywords + '%'
			) ;

	
		select		type		
					,description	
					,sp_name		
					,order_no	
					,eod_status	
					,eod_remark	
					,@rows_count 'rowcount'
		from		dbo.sys_job_tasklist
		where		type = 'EOD'
					and (
						description											like '%' + @p_keywords + '%'
						or	sp_name											like '%' + @p_keywords + '%'
						or	order_no										like '%' + @p_keywords + '%'
						or	eod_status										like '%' + @p_keywords + '%'
						or	eod_remark										like '%' + @p_keywords + '%'
					)
		order by case when @p_sort_by = 'asc' then case @p_order_by			                    
													when 1 then description								                    
													when 2 then sp_name					
													when 3 then cast(order_no as sql_variant)
													when 4 then eod_status
													when 5 then eod_remark
												   end
					end asc 
					,case when @p_sort_by = 'desc' then case @p_order_by
															when 1 then description						
															when 2 then sp_name					
															when 3 then cast(order_no as sql_variant)
															when 4 then eod_status
															when 5 then eod_remark
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
