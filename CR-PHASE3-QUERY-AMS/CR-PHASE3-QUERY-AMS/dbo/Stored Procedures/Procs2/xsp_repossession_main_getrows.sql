CREATE procedure dbo.xsp_repossession_main_getrows
(
	@p_keywords						nvarchar(50)
	,@p_pagenumber					int
	,@p_rowspage					int
	,@p_order_by					int
	,@p_sort_by						nvarchar(5)
	,@p_branch_code					nvarchar(50)
	,@p_repossession_status			nvarchar(10)
	,@p_repossession_status_process nvarchar(20)
	,@p_exit_status					nvarchar(20)
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	repossession_main rmn
			inner join dbo.ASSET ast on (ast.code = rmn.asset_code)
	where	rmn.branch_code						= case @p_branch_code
													  when 'ALL' then rmn.branch_code
													  else @p_branch_code
												  end
			and rmn.repossession_status			= case @p_repossession_status
													  when 'ALL' then rmn.repossession_status
													  else @p_repossession_status
												  end
			and rmn.repossession_status_process = case @p_repossession_status_process
													  when 'ALL' then rmn.repossession_status_process
													  else @p_repossession_status_process
												  end
			and rmn.exit_status					= case @p_exit_status
													  when 'ALL' then rmn.repossession_status
													  else @p_exit_status
												  end
			and
			(
					rmn.code like '%' + @p_keywords + '%'
					or	convert(varchar(30), rmn.purchase_date, 103) like '%' + @p_keywords + '%'
					or	ast.category_name like '%' + @p_keywords + '%'
					or	ast.item_name like '%' + @p_keywords + '%'
					or	ast.type_code like '%' + @p_keywords + '%'
					or	rmn.branch_name like '%' + @p_keywords + '%'
					or	ast.location_name like '%' + @p_keywords + '%'
					or	ast.status like '%' + @p_keywords + '%'
					or	ast.fisical_status like '%' + @p_keywords + '%'
					or	ast.rental_status like '%' + @p_keywords + '%'
			) ;

	select		rmn.code
				,convert(varchar(30), rmn.purchase_date, 103) 'purchase_date'
				,ast.category_name
				,ast.item_name
				,ast.type_code
				,rmn.branch_name
				,ast.location_name
				,rmn.status
				,rmn.fisical_status
				,rmn.rental_status
				,@rows_count 'rowcount'
	from		repossession_main rmn
				inner join dbo.ASSET ast on (ast.code = rmn.asset_code)
	where		rmn.branch_code						= case @p_branch_code
														  when 'ALL' then rmn.branch_code
														  else @p_branch_code
													  end
				and rmn.repossession_status			= case @p_repossession_status
														  when 'ALL' then rmn.repossession_status
														  else @p_repossession_status
													  end
				and rmn.repossession_status_process = case @p_repossession_status_process
														  when 'ALL' then rmn.repossession_status_process
														  else @p_repossession_status_process
													  end
				and rmn.exit_status					= case @p_exit_status
														  when 'ALL' then rmn.repossession_status
														  else @p_exit_status
													  end
				and
				(
					rmn.code like '%' + @p_keywords + '%'
					or	convert(varchar(30), rmn.purchase_date, 103) like '%' + @p_keywords + '%'
					or	ast.category_name like '%' + @p_keywords + '%'
					or	ast.item_name like '%' + @p_keywords + '%'
					or	ast.type_code like '%' + @p_keywords + '%'
					or	rmn.branch_name like '%' + @p_keywords + '%'
					or	ast.location_name like '%' + @p_keywords + '%'
					or	ast.status like '%' + @p_keywords + '%'
					or	ast.fisical_status like '%' + @p_keywords + '%'
					or	ast.rental_status like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then rmn.code
													 when 2 then cast(rmn.purchase_date as sql_variant)
													 when 3 then ast.category_name
													 when 4 then ast.item_name
													 when 5 then ast.type_code
													 when 6 then rmn.branch_name
													 when 7 then ast.location_name
													 when 8 then rmn.status
													 when 9 then rmn.fisical_status
													 when 10 then rmn.rental_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													  when 1 then rmn.code
													  when 2 then cast(rmn.purchase_date as sql_variant)
													  when 3 then ast.category_name
													  when 4 then ast.item_name
													  when 5 then ast.type_code
													  when 6 then rmn.branch_name
													  when 7 then ast.location_name
													  when 8 then rmn.status
													  when 9 then rmn.fisical_status
													  when 10 then rmn.rental_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
