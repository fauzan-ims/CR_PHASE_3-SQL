CREATE PROCEDURE dbo.xsp_agreement_asset_getrows_for_stop_billing
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_agreement_no nvarchar(50)
)
as
begin

	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	agreement_asset ast
			inner join dbo.sys_general_subcode sgs on (ast.asset_type_code	= sgs.code and sgs.general_code='ASTPRT')
			inner join dbo.agreement_main am on (am.agreement_no = ast.agreement_no)
			outer apply
			(
				select	count(1) 'hold_billing_status'
				from	dbo.agreement_asset_amortization aaa
				where	aaa.asset_no				= ast.asset_no
						and aaa.hold_billing_status = 'PENDING'
			) aaam
	where	ast.agreement_no = @p_agreement_no
	and		(
				ast.asset_no					like '%' + @p_keywords + '%'
				or	ast.asset_name				like '%' + @p_keywords + '%'
				or	sgs.description				like '%' + @p_keywords + '%'
				or	ast.asset_year				like '%' + @p_keywords + '%'
				or	ast.asset_condition			like '%' + @p_keywords + '%'
				or	ast.lease_rounded_amount		like '%' + @p_keywords + '%'
				or	ast.net_margin_amount		like '%' + @p_keywords + '%'
			) ;

	select	ast.asset_no
			,ast.asset_name
			,ast.asset_year
			,ast.asset_condition
			,sgs.description 'asset_type'
			,ast.lease_rounded_amount		
			,ast.net_margin_amount
			,case 
				aaam.hold_billing_status	when 0 then 'NORMAL'
											else 'PENDING'
			 end 'billing_status'
			,@rows_count 'rowcount'
	from	agreement_asset ast
			inner join dbo.sys_general_subcode sgs on (ast.asset_type_code	= sgs.code and sgs.general_code='ASTPRT')
			inner join dbo.agreement_main am on (am.agreement_no = ast.agreement_no)
			outer apply
			(
				select	count(1) 'hold_billing_status'
				from	dbo.agreement_asset_amortization aaa
				where	aaa.asset_no				= ast.asset_no
						and aaa.hold_billing_status = 'PENDING'
			) aaam
	where	ast.agreement_no = @p_agreement_no
	and		(
				ast.asset_no					like '%' + @p_keywords + '%'
				or	ast.asset_name				like '%' + @p_keywords + '%'
				or	sgs.description				like '%' + @p_keywords + '%'
				or	ast.asset_year				like '%' + @p_keywords + '%'
				or	ast.asset_condition			like '%' + @p_keywords + '%'
				or	ast.lease_rounded_amount		like '%' + @p_keywords + '%'
				or	ast.net_margin_amount		like '%' + @p_keywords + '%'
			)
	order by	case 
					when @p_sort_by='asc' then case @p_order_by
													when 1 then ast.asset_no
													when 2 then ast.asset_name
													when 3 then sgs.description
													when 4 then ast.asset_year
													when 5 then ast.asset_condition
													when 6 then cast(ast.lease_rounded_amount as sql_variant)
													when 7 then cast(ast.net_margin_amount as sql_variant)
												end
					end asc,
				case 
					when @p_sort_by='desc' then case @p_order_by 
													when 1 then ast.asset_no
													when 2 then ast.asset_name
													when 3 then sgs.description
													when 4 then ast.asset_year
													when 5 then ast.asset_condition
													when 6 then cast(ast.lease_rounded_amount as sql_variant)
													when 7 then cast(ast.net_margin_amount as sql_variant)
												end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only;

end ;
