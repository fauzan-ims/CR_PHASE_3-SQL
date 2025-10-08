CREATE PROCEDURE dbo.xsp_stock_on_customer_not_active_end_contract_getrows
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
	from	dbo.asset	ast with (nolock)
			inner join	dbo.asset_vehicle	av with (nolock)	on av.asset_code	= ast.code
			inner join ifinopl.dbo.agreement_asset aa with (nolock)	on aa.asset_no		= ast.asset_no
			inner join ifinopl.dbo.agreement_main am with (nolock)	on am.agreement_no = aa.agreement_no
			outer apply (
				select max(due_date) as max_due_date
				from ifinopl.dbo.agreement_asset_amortization aaa with (nolock)
				where aaa.asset_no = ast.asset_no
			) amort
	where		ast.branch_code = case @p_branch_code
										when 'all' THEN ast.branch_code
										else @p_branch_code
									end
	and			aa.maturity_date			< dbo.xfn_get_system_date()
	and			ast.status					= 'STOCK'
	and			ast.fisical_status			= 'ON CUSTOMER'
	and			ast.rental_status			= 'IN USE'
	and			aa.asset_status				= 'TERMINATE'
	and		(
				ast.code																			like '%' + @p_keywords + '%'
				or ast.branch_code																	like '%' + @p_keywords + '%'
				or ast.branch_name																	like '%' + @p_keywords + '%'
				or ast.item_name																	like '%' + @p_keywords + '%'
				or av.built_year																	like '%' + @p_keywords + '%'
				or av.plat_no																		like '%' + @p_keywords + '%'	
				or av.engine_no																		like '%' + @p_keywords + '%'
				or av.chassis_no																	like '%' + @p_keywords + '%'
				or ast.agreement_external_no														like '%' + @p_keywords + '%'
				or ast.client_name																	like '%' + @p_keywords + '%'
				or case when aa.is_purchase_requirement_after_lease = '1' then 'yes' else 'no' end  like '%' + @p_keywords + '%'
				or am.marketing_name																like '%' + @p_keywords + '%'
				or convert(varchar(30), aa.maturity_date, 103)	like '%' + @p_keywords + '%'
				or ast.parking_location							like '%' + @p_keywords + '%'
				or ast.unit_province_name						like '%' + @p_keywords + '%'
				or ast.unit_city_name						    like '%' + @p_keywords + '%'
			) ;

	SELECT		ast.code		
				,ast.branch_code
				,ast.branch_name
				,ast.item_name
				,av.built_year
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,ast.agreement_external_no
				,ast.client_name
				,aa.is_purchase_requirement_after_lease 'PRAL'
				,am.marketing_name
				,ast.status_condition
				,ast.status_progress
				,ast.status_remark
				,convert(varchar(30),aa.maturity_date, 103)		'end_contract_date'
				,convert(varchar(30),ast.disposal_date, 103)
				,ast.parking_location
				,ast.unit_province_name
				,ast.unit_city_name
				,@rows_count 'rowcount'
	from	dbo.asset ast with (nolock)
			inner join	dbo.asset_vehicle			av with (nolock)	on av.asset_code	= ast.code
			inner join ifinopl.dbo.agreement_asset	aa with (nolock)	on aa.asset_no		= ast.asset_no
			inner join ifinopl.dbo.agreement_main	am with (nolock)	on am.agreement_no	= aa.agreement_no
			outer apply (
				select max(due_date) as max_due_date
				from ifinopl.dbo.agreement_asset_amortization aaa with (nolock)
				where aaa.asset_no = ast.asset_no
			) amort
	where		ast.branch_code = case @p_branch_code
										when 'all' then ast.branch_code
										else @p_branch_code
									end
	and			ast.status					= 'STOCK'
	and			ast.fisical_status			= 'ON CUSTOMER'
	and			ast.rental_status			= 'IN USE'
	and			aa.asset_status				= 'TERMINATE'
	and		(
				ast.code																			LIKE '%' + @p_keywords + '%'
				or ast.branch_code																	LIKE '%' + @p_keywords + '%'
				or ast.branch_name																	LIKE '%' + @p_keywords + '%'
				or ast.item_name																	LIKE '%' + @p_keywords + '%'
				or av.built_year																	LIKE '%' + @p_keywords + '%'
				or av.plat_no																		LIKE '%' + @p_keywords + '%'	
				or av.engine_no																		LIKE '%' + @p_keywords + '%'
				or av.chassis_no																	LIKE '%' + @p_keywords + '%'
				or ast.agreement_external_no														LIKE '%' + @p_keywords + '%'
				or ast.client_name																	LIKE '%' + @p_keywords + '%'
				or case when aa.is_purchase_requirement_after_lease = '1' then 'Yes' else 'No' end  LIKE '%' + @p_keywords + '%'
				or am.marketing_name																LIKE '%' + @p_keywords + '%'
				or convert(varchar(30), aa.maturity_date, 103)	like '%' + @p_keywords + '%'
				or ast.parking_location							like '%' + @p_keywords + '%'
				or ast.unit_province_name						like '%' + @p_keywords + '%'
				or ast.unit_city_name						    like '%' + @p_keywords + '%'



			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then ast.agreement_external_no
													 when 5 then aa.is_purchase_requirement_after_lease
													 when 6 then am.marketing_name
													 when 7 then convert(varchar(30), maturity_date, 120)
													 when 8 then parking_location
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then ast.agreement_external_no
													 when 5 then aa.is_purchase_requirement_after_lease
													 when 6 then am.marketing_name
													 when 7 then convert(varchar(30), maturity_date, 120)
													 when 8 then parking_location
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;