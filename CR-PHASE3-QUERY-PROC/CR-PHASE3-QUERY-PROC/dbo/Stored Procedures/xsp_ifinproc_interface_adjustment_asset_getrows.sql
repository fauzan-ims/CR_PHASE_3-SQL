CREATE PROCEDURE dbo.xsp_ifinproc_interface_adjustment_asset_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch			nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch
	)
	begin
		set @p_branch = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	dbo.ifinproc_interface_adjustment_asset
	where	branch_code = case @p_branch
									 when 'ALL' then branch_code
									 else @p_branch
								 end
	and		(
				code										like '%' + @p_keywords + '%'
				or	branch_name								like '%' + @p_keywords + '%'
				or	fa_name									like '%' + @p_keywords + '%'
				or	fa_code									like '%' + @p_keywords + '%'
				or	description								like '%' + @p_keywords + '%'
				or	adjustment_amount						like '%' + @p_keywords + '%'
				or	convert(varchar(30), date, 103)			like '%' + @p_keywords + '%'
			) ;

	select		id
				,code
				,branch_code
				,branch_name
				,convert(varchar(30), date, 103) 'date'
				,fa_code
				,fa_name
				,division_code
				,division_name
				,department_code
				,department_name
				,description
				,adjustment_amount
				,job_status
				,failed_remarks
				,@rows_count 'rowcount'
	from		ifinproc_interface_adjustment_asset
	where		branch_code = case @p_branch
									 when 'ALL' then branch_code
									 else @p_branch
								 end
	and			(
					code										like '%' + @p_keywords + '%'
					or	branch_name								like '%' + @p_keywords + '%'
					or	fa_name									like '%' + @p_keywords + '%'
					or	fa_code									like '%' + @p_keywords + '%'
					or	description								like '%' + @p_keywords + '%'
					or	adjustment_amount						like '%' + @p_keywords + '%'
					or	convert(varchar(30), date, 103)			like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then branch_name
													 when 3 then cast(date as sql_variant)
													 when 4 then fa_code
													 when 5 then cast(adjustment_amount as sql_variant)
													 when 6 then description
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then branch_name
														when 3 then cast(date as sql_variant)
														when 4 then fa_code
														when 5 then cast(adjustment_amount as sql_variant)
														when 6 then description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
