CREATE procedure dbo.xsp_stock_on_customer_active_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 
			,@end_date datetime;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'ho'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'all' ;
	end ;

	select	@rows_count = count(1)
	from	dbo.asset ast with(nolock)
		inner join dbo.asset_vehicle			av with(nolock)	on av.asset_code	= ast.code
		inner join ifinopl.dbo.agreement_asset	aa with(nolock)	on aa.asset_no		= ast.asset_no
	where		ast.branch_code = case @p_branch_code
										when 'all' then ast.branch_code
										else @p_branch_code
									end
	and			ast.status			= 'stock'
	and			ast.fisical_status	= 'on customer'
	and			ast.rental_status	= 'in use'
	and			(ast.monitoring_status	= '' or ast.monitoring_status	is null)
	and		(
				   ast.code										like '%' + @p_keywords + '%'
				or ast.branch_code								like '%' + @p_keywords + '%'
				or ast.branch_name								like '%' + @p_keywords + '%'
				or ast.item_name								like '%' + @p_keywords + '%'
				or av.built_year								like '%' + @p_keywords + '%'
				or av.plat_no									like '%' + @p_keywords + '%'
				or av.engine_no									like '%' + @p_keywords + '%'
				or av.chassis_no								like '%' + @p_keywords + '%'
				or ast.agreement_no								like '%' + @p_keywords + '%'
				or ast.agreement_external_no					like '%' + @p_keywords + '%'
				or ast.client_name								like '%' + @p_keywords + '%'
				or ast.parking_location							like '%' + @p_keywords + '%'
				or ast.unit_province_name						like '%' + @p_keywords + '%'
				or ast.unit_city_name							like '%' + @p_keywords + '%'
				or ast.status_condition							like '%' + @p_keywords + '%'
				or ast.status_progress							like '%' + @p_keywords + '%'
				or ast.status_remark							like '%' + @p_keywords + '%'
				or ast.status_last_update_by					like '%' + @p_keywords + '%'
				or aa.is_purchase_requirement_after_lease		like '%' + @p_keywords + '%'
				or aa.maturity_date								like '%' + @p_keywords + '%'
				or (
					case 
						when aa.is_purchase_requirement_after_lease = 1 then 'yes'
						when aa.is_purchase_requirement_after_lease = 0 then 'no'
						else ''
					end
				) like '%' + lower(@p_keywords) + '%'

			)

	select 		 ast.code		
				,ast.branch_code
				,ast.branch_name
				,ast.item_name
				,av.built_year
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,ast.agreement_no
				,ast.agreement_external_no
				,ast.client_name
				,ast.parking_location
				,ast.unit_province_name
				,ast.unit_city_name
				,ast.status_condition
				,ast.status_progress
				,ast.status_remark
				,ast.status_last_update_by				'last_update_by'
				,aa.is_purchase_requirement_after_lease 'pral'
				,aa.maturity_date 'end_contract_date'
				,@rows_count 'rowcount'
	from	dbo.asset ast
		inner join dbo.asset_vehicle			av	on av.asset_code	= ast.code
		inner join ifinopl.dbo.agreement_asset	aa	on aa.asset_no		= ast.asset_no
	where		ast.branch_code = case @p_branch_code
										when 'all' then ast.branch_code
										else @p_branch_code
									end

	and			ast.status			= 'stock'
	and			ast.fisical_status	= 'on customer'
	and			ast.rental_status	= 'in use'
	and			(ast.monitoring_status	= '' or ast.monitoring_status	is null)
	and		(
				   ast.code										like '%' + @p_keywords + '%'
				or ast.branch_code								like '%' + @p_keywords + '%'
				or ast.branch_name								like '%' + @p_keywords + '%'
				or ast.item_name								like '%' + @p_keywords + '%'
				or av.built_year								like '%' + @p_keywords + '%'
				or av.plat_no									like '%' + @p_keywords + '%'
				or av.engine_no									like '%' + @p_keywords + '%'
				or av.chassis_no								like '%' + @p_keywords + '%'
				or ast.agreement_no								like '%' + @p_keywords + '%'
				or ast.agreement_external_no					like '%' + @p_keywords + '%'
				or ast.client_name								like '%' + @p_keywords + '%'
				or ast.parking_location							like '%' + @p_keywords + '%'
				or ast.unit_province_name						like '%' + @p_keywords + '%'
				or ast.unit_city_name							like '%' + @p_keywords + '%'
				or ast.status_condition							like '%' + @p_keywords + '%'
				or ast.status_progress							like '%' + @p_keywords + '%'
				or ast.status_remark							like '%' + @p_keywords + '%'
				or ast.status_last_update_by					like '%' + @p_keywords + '%'
				or aa.is_purchase_requirement_after_lease		like '%' + @p_keywords + '%'
				or aa.maturity_date								like '%' + @p_keywords + '%'
				or (
					case 
						when aa.is_purchase_requirement_after_lease = 1 then 'yes'
						when aa.is_purchase_requirement_after_lease = 0 then 'no'
						else ''
					end
				) like '%' + lower(@p_keywords) + '%'

			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then ast.code
													when 2 then ast.item_name
													when 3 then case when av.plat_no is null then '~' else av.plat_no end
													when 4 then case when ast.agreement_external_no is null then '~' else ast.agreement_external_no end
													when 5 then aa.is_purchase_requirement_after_lease
													when 6 then aa.maturity_date
													when 7 then case when ast.unit_province_name is null then '~' else ast.unit_province_name end
													when 8 then case when ast.status_condition is null then '~' else ast.status_condition end
													when 9 then case when ast.status_progress is null then '~' else ast.status_progress end
													when 10 then case when ast.status_remark is null then '~' else ast.status_remark end
													when 11 then case when ast.status_last_update_by is null then '~' else ast.status_last_update_by end
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													when 1 then ast.code
													when 2 then ast.item_name
													when 3 then case when av.plat_no is null then '~' else av.plat_no end
													when 4 then case when ast.agreement_external_no is null then '~' else ast.agreement_external_no end
													when 5 then aa.is_purchase_requirement_after_lease
													when 6 then aa.maturity_date
													when 7 then case when ast.unit_province_name is null then '~' else ast.unit_province_name end
													when 8 then case when ast.status_condition is null then '~' else ast.status_condition end
													when 9 then case when ast.status_progress is null then '~' else ast.status_progress end
													when 10 then case when ast.status_remark is null then '~' else ast.status_remark end
													when 11 then case when ast.status_last_update_by is null then '~' else ast.status_last_update_by end
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
