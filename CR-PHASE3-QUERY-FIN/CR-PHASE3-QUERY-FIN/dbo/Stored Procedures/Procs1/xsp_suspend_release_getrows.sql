CREATE PROCEDURE dbo.xsp_suspend_release_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_branch_code	   nvarchar(50)
	,@p_release_status nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end
	select	@rows_count = count(1)
	from	suspend_release
	where	branch_code		   = case @p_branch_code
										when 'ALL' then branch_code
										else @p_branch_code
									end
			and release_status = case @p_release_status
										when 'ALL' then release_status
										else @p_release_status
									end
			and (
					code										like '%' + @p_keywords + '%'
					or  branch_name								like '%' + @p_keywords + '%'
					or	suspend_code							like '%' + @p_keywords + '%'
					or	convert(varchar(30), release_date, 103)	like '%' + @p_keywords + '%'
					or	release_amount							like '%' + @p_keywords + '%'
					or	release_status							like '%' + @p_keywords + '%'
				);

		select		code
					,branch_name
					,suspend_code
					,convert(varchar(30), release_date, 103) 'release_date'
					,release_amount
					,release_status
					,@rows_count 'rowcount'
		from		suspend_release
		where		branch_code		   = case @p_branch_code
											 when 'ALL' then branch_code
											 else @p_branch_code
										 end
					and release_status = case @p_release_status
											 when 'ALL' then release_status
											 else @p_release_status
										 end
					and (
							code										like '%' + @p_keywords + '%'
							or  branch_name								like '%' + @p_keywords + '%'
							or	suspend_code							like '%' + @p_keywords + '%'
							or	convert(varchar(30), release_date, 103)	like '%' + @p_keywords + '%'
							or	release_amount							like '%' + @p_keywords + '%'
							or	release_status							like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then branch_name
														when 3 then suspend_code
														when 4 then cast(release_date as sql_variant)
														when 5 then cast(release_amount as sql_variant)
														when 6 then release_status
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then branch_name
														when 3 then suspend_code
														when 4 then cast(release_date as sql_variant)
														when 5 then cast(release_amount as sql_variant)
														when 6 then release_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
