CREATE PROCEDURE [dbo].[xsp_sys_job_tasklist_getrows_for_integration]
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_type				nvarchar(20)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.sys_job_tasklist sjt
			outer apply (select top 1 sjtl.status,sjtl.log_description from dbo.sys_job_tasklist_log sjtl 
							 where sjt.code = sjtl.job_tasklist_code
							 order by sjtl.CRE_DATE desc) sjtl
	where	type = case @p_type
						when 'ALL' then sjt.type
						else @p_type
					end
	and		sjt.is_active = '1'
	and     sjt.type <> 'EOD'
	and		(
				description											like '%' + @p_keywords + '%'
				or	type											like '%' + @p_keywords + '%'
				or	sp_name											like '%' + @p_keywords + '%'
				or	code											like '%' + @p_keywords + '%'
				or	sjtl.status										like '%' + @p_keywords + '%'
				or	sjtl.log_description							like '%' + @p_keywords + '%'
			) ;
    
	
		select		code
					,type		
					,description	
					,sp_name		
					,sjtl.status				
					,sjtl.log_description	
					,@rows_count 'rowcount'
		from	dbo.sys_job_tasklist sjt
				outer apply (select top 1 sjtl.status,sjtl.log_description from dbo.sys_job_tasklist_log sjtl 
							 where sjt.code = sjtl.job_tasklist_code
							 order by sjtl.CRE_DATE desc) sjtl
		where	type = case @p_type
							when 'ALL' then sjt.type
							else @p_type
						end
		and		sjt.is_active = '1'
		and     sjt.type <> 'EOD'
		and		(
					description											like '%' + @p_keywords + '%'
					or	type											like '%' + @p_keywords + '%'
					or	sp_name											like '%' + @p_keywords + '%'
					or	code											like '%' + @p_keywords + '%'
					or	sjtl.status										like '%' + @p_keywords + '%'
					or	sjtl.log_description							like '%' + @p_keywords + '%'
				)
		order by case when sjtl.STATUS = 'ERROR' then 0
						else 1
					 end,
		case when @p_sort_by = 'asc' then case @p_order_by			                    
													when 1 then code 
													when 2 then type		                  
													when 3 then description						
													when 4 then sp_name					
													when 5 then sjtl.status			
													when 6 then sjtl.log_description
												   end
					end asc 
					,case when @p_sort_by = 'desc' then case @p_order_by
															when 1 then code 
															when 2 then type		                  
															when 3 then description						
															when 4 then sp_name					
															when 5 then sjtl.status			
															when 6 then sjtl.log_description
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
