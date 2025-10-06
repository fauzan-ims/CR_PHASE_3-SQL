CREATE PROCEDURE dbo.xsp_faktur_registration_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_status			nvarchar(50) 
)
as
begin
	declare @rows_count int = 0 ;

	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	END

	select	@rows_count = count(1)
	from	faktur_registration
	where	branch_code		 = case @p_branch_code
									when 'ALL' then branch_code
									else @p_branch_code
								end
			and status	= case @p_status
								when 'ALL' then status
								else @p_status
							end
			and (
					code							like '%' + @p_keywords + '%'
					or	branch_name					like '%' + @p_keywords + '%'
					or	remark						like '%' + @p_keywords + '%'
					or	count						like '%' + @p_keywords + '%'
					or	status						like '%' + @p_keywords + '%'
				) ;

	select		code
				,branch_name
				,status
				,remark
				,count
				,@rows_count 'rowcount'
	from		faktur_registration
	where		branch_code		 = case @p_branch_code
										   when 'ALL' then branch_code
										   else @p_branch_code
									   end
				and status	= case @p_status
									when 'ALL' then status
									else @p_status
								end
				and (
						code							like '%' + @p_keywords + '%'
						or	branch_name					like '%' + @p_keywords + '%'
						or	remark						like '%' + @p_keywords + '%'
						or	count						like '%' + @p_keywords + '%'
						or	status						like '%' + @p_keywords + '%'
					)
	

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then cast(code as sql_variant)
													 when 2 then branch_name
													 when 3 then remark
													 when 4 then cast(count as sql_variant)
													 when 5 then status
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then cast(code as sql_variant)
													 when 2 then branch_name
													 when 3 then remark
													 when 4 then cast(count as sql_variant)
													 when 5 then status
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
