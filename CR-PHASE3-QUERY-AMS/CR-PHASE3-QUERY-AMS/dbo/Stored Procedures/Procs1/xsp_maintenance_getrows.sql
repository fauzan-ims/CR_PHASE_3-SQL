CREATE PROCEDURE [dbo].[xsp_maintenance_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)	= ''
	,@p_status			nvarchar(20)	= 'ALL'
	,@p_company_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

		--HO akan menampilkan semua branch
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
	from	maintenance mn
			inner join dbo.asset ast with(nolock) on mn.asset_code = ast.code
			inner join dbo.asset_vehicle av with(nolock) on av.asset_code = ast.code
	where	mn.branch_code		  = case @p_branch_code
										when 'ALL' then mn.branch_code
										else @p_branch_code
									end
	and		mn.status = case @p_status
						when 'ALL' then mn.status
						else @p_status
					end
	and		(
				mn.code											 like '%' + @p_keywords + '%'
				or	mn.spk_no									 like '%' + @p_keywords + '%'
				or	mn.asset_code								 like '%' + @p_keywords + '%'
				or	convert(nvarchar(30),transaction_date, 103)  like '%' + @p_keywords + '%'
				or	mn.branch_name								 like '%' + @p_keywords + '%'
				or	transaction_amount							 like '%' + @p_keywords + '%'
				or	mn.status									 like '%' + @p_keywords + '%'
				or	mn.remark									 like '%' + @p_keywords + '%'
				or	ast.item_name								 like '%' + @p_keywords + '%'
				or	av.plat_no									 like '%' + @p_keywords + '%'
				or	av.engine_no								 like '%' + @p_keywords + '%'
				or	av.chassis_no								 like '%' + @p_keywords + '%'
				or	av.built_year								 like '%' + @p_keywords + '%'
				or	convert(nvarchar(30),mn.work_date, 103)		 like '%' + @p_keywords + '%'
				or	mn.vendor_name								 like '%' + @p_keywords + '%'
				or	mn.requestor_name							 like '%' + @p_keywords + '%'
				or	mn.actual_km								 like '%' + @p_keywords + '%'
			) ;
			
	select		mn.code
				,mn.spk_no
				,mn.company_code
				,mn.asset_code
				,convert(nvarchar(30), transaction_date, 103) 'transaction_date'
				,ast.barcode
				,transaction_amount
				,mn.branch_code
				,mn.branch_name
				,mn.requestor_code
				,mn.division_code
				,mn.division_name
				,mn.department_code
				,mn.department_name
				,mn.status
				,mn.remark
				,ast.item_name
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,mn.is_reimburse
				,av.built_year
				,convert(nvarchar(30), mn.work_date, 103) 'work_date'
				,mn.vendor_name
				,mn.requestor_name
				,mn.actual_km
				,@rows_count 'rowcount'
	from		maintenance mn
				inner join dbo.asset ast with(nolock) on mn.asset_code = ast.code
				inner join dbo.asset_vehicle av with(nolock) on av.asset_code = ast.code
	where		mn.branch_code		  = case @p_branch_code
											when 'ALL' then mn.branch_code
											else @p_branch_code
										end
	and			mn.status = case @p_status
							when 'ALL' then mn.status
							else @p_status
						end
	and			(
					mn.code											 like '%' + @p_keywords + '%'
					or	mn.spk_no									 like '%' + @p_keywords + '%'
					or	mn.asset_code								 like '%' + @p_keywords + '%'
					or	convert(nvarchar(30),transaction_date, 103)  like '%' + @p_keywords + '%'
					or	mn.branch_name								 like '%' + @p_keywords + '%'
					or	transaction_amount							 like '%' + @p_keywords + '%'
					or	mn.status									 like '%' + @p_keywords + '%'
					or	mn.remark									 like '%' + @p_keywords + '%'
					or	ast.item_name								 like '%' + @p_keywords + '%'
					or	av.plat_no									 like '%' + @p_keywords + '%'
					or	av.engine_no								 like '%' + @p_keywords + '%'
					or	av.chassis_no								 like '%' + @p_keywords + '%'
					or	av.built_year								 like '%' + @p_keywords + '%'
					or	convert(nvarchar(30),mn.work_date, 103)		 like '%' + @p_keywords + '%'
					or	mn.vendor_name								 like '%' + @p_keywords + '%'
					or	mn.requestor_name							 like '%' + @p_keywords + '%'
					or	mn.actual_km								 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mn.code
													 when 2 then mn.asset_code
													 when 3 then av.plat_no
													 when 4 then cast(mn.transaction_date as sql_variant)
													 when 5 then mn.branch_name
													 when 6 then mn.vendor_name
													 when 7 then mn.actual_km
													 when 8 then cast(mn.work_date as sql_variant)
													 when 9 then av.built_year
													 when 10 then mn.requestor_name
													 when 11 then mn.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then mn.code
													 when 2 then mn.asset_code
													 when 3 then av.plat_no
													 when 4 then cast(mn.transaction_date as sql_variant)
													 when 5 then mn.branch_name
													 when 6 then mn.vendor_name
													 when 7 then mn.actual_km
													 when 8 then cast(mn.work_date as sql_variant)
													 when 9 then av.built_year
													 when 10 then mn.requestor_name
													 when 11 then mn.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
