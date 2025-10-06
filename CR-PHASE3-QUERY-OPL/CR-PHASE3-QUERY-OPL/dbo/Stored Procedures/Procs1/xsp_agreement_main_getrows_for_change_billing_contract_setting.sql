CREATE PROCEDURE dbo.xsp_agreement_main_getrows_for_change_billing_contract_setting
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	--
	,@p_agreement_no	nvarchar(50)
	,@p_asset_no		nvarchar(50) = 'ALL'
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.agreement_main am 
			left join dbo.agreement_asset ast on (ast.agreement_no = am.agreement_no)
			--outer apply
			--(
			--	select	min(aaa.due_date) due_date
			--	from	dbo.agreement_asset_amortization aaa
			--	where	aaa.agreement_no = ast.agreement_no
			--			and aaa.asset_no = ast.asset_no
			--) aaa
	where	am.agreement_no = @p_agreement_no
			and	ast.asset_no = case @p_asset_no
											when 'ALL' then ast.asset_no
											else @p_asset_no
										end	
			and	am.agreement_status = 'GO LIVE'
			and (
					am.agreement_no									like 	'%'+@p_keywords+'%'
					or	am.client_name								like 	'%'+@p_keywords+'%'
					or	ast.asset_no								like 	'%'+@p_keywords+'%'
					or	ast.asset_name								like 	'%'+@p_keywords+'%'
					or	ast.lease_rounded_amount					like 	'%'+@p_keywords+'%'
					or	convert(varchar(30), ast.handover_bast_date, 103)		like 	'%'+@p_keywords+'%'
				) ;

	select		am.agreement_no
				,am.agreement_external_no
				,am.client_name
				,ast.asset_no
				,ast.asset_name
				,ast.lease_rounded_amount 
				,CONVERT(varchar(30), ast.handover_bast_date, 103)  'due_date'-- CONVERT(varchar(30), aaa.due_date, 103) 'due_date'
				,@rows_count 'rowcount'
	from	dbo.agreement_main am 
			left join dbo.agreement_asset ast on (ast.agreement_no = am.agreement_no)
			--outer apply
			--(
			--	select	min(aaa.due_date) due_date
			--	from	dbo.agreement_asset_amortization aaa
			--	where	aaa.agreement_no = ast.agreement_no
			--			and aaa.asset_no = ast.asset_no
			--) aaa
	where	am.agreement_no = @p_agreement_no
			and	ast.asset_no = case @p_asset_no
											when 'ALL' then ast.asset_no
											else @p_asset_no
										end	
			and	am.agreement_status = 'GO LIVE'
				and (
						am.agreement_no									like 	'%'+@p_keywords+'%'
						or	am.client_name								like 	'%'+@p_keywords+'%'
						or	ast.asset_no								like 	'%'+@p_keywords+'%'
						or	ast.asset_name								like 	'%'+@p_keywords+'%'
						or	ast.lease_rounded_amount					like 	'%'+@p_keywords+'%'
						or	convert(varchar(30), ast.handover_bast_date, 103)		like 	'%'+@p_keywords+'%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then am.agreement_no + am.client_name
													 when 2 then ast.asset_no + ast.asset_name
													 when 3 then cast(ast.lease_rounded_amount as sql_variant)
													 when 4 then cast(ast.handover_bast_date as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then am.agreement_no + am.client_name
														when 2 then ast.asset_no + ast.asset_name
														when 3 then cast(ast.lease_rounded_amount as sql_variant)
														when 4 then cast(ast.handover_bast_date as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
