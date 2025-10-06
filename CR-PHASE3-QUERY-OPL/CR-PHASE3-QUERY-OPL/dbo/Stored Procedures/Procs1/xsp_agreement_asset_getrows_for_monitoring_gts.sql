--created by, Rian at 23/05/2023 

CREATE PROCEDURE dbo.xsp_agreement_asset_getrows_for_monitoring_gts	
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	--
	,@p_agreement_no nvarchar(50)
)
as
begin

	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	agreement_asset ast
			inner join dbo.sys_general_subcode sgs on (ast.asset_type_code	= sgs.code and sgs.general_code='ASTPRT')
			inner join dbo.agreement_main am on (am.agreement_no = ast.agreement_no)
			inner join dbo.application_asset aps on (aps.asset_no = ast.asset_no)
	where	ast.agreement_no = @p_agreement_no
	and		ast.is_request_gts = '1'
	and		ast.asset_status = 'RENTED'
	and		ast.asset_no not in
			(
				select	ard.old_asset_no
				from	dbo.asset_replacement ar
						inner join dbo.asset_replacement_detail ard on (ard.replacement_code = ar.code)
				where	ar.status <> 'CANCEL'
			)
	and		(
				ast.asset_no					like '%' + @p_keywords + '%'
				or	ast.asset_name				like '%' + @p_keywords + '%'
				or	sgs.description				like '%' + @p_keywords + '%'
				or	ast.asset_year				like '%' + @p_keywords + '%'
				or	ast.asset_condition			like '%' + @p_keywords + '%'
				or	ast.lease_rounded_amount	like '%' + @p_keywords + '%'
				or	ast.net_margin_amount		like '%' + @p_keywords + '%'
			) ;

	select	ast.asset_no
			,ast.asset_name
			,ast.asset_year
			,ast.asset_condition
			,sgs.description 'asset_type'
			,ast.lease_rounded_amount		
			,ast.net_margin_amount
			,isnull(ast.fa_code, aps.fa_code) 'fa_code'
			,isnull(ast.fa_name, aps.fa_name) 'fa_name'
			,isnull(ast.fa_reff_no_01, aps.fa_reff_no_01) 'fa_reff_no_01'
			,isnull(ast.fa_reff_no_02, aps.fa_reff_no_02) 'fa_reff_no_02'
			,isnull(ast.fa_reff_no_03, aps.fa_reff_no_03) 'fa_reff_no_03'
			,ast.replacement_fa_code
			,ast.replacement_fa_name
			,ast.replacement_fa_reff_no_01
			,ast.replacement_fa_reff_no_02
			,ast.replacement_fa_reff_no_03
			,convert(varchar(30), ast.estimate_delivery_date,103) 'estimate_delivery_date'
			,convert(varchar(30), ast.estimate_po_date,103) 'estimate_po_date'
			,datediff(day, ast.estimate_delivery_date, ast.estimate_po_date) 'aging_day'
			,@rows_count 'rowcount'
	from	agreement_asset ast
			inner join dbo.sys_general_subcode sgs on (ast.asset_type_code	= sgs.code and sgs.general_code='ASTPRT')
			inner join dbo.agreement_main am on (am.agreement_no = ast.agreement_no)
			inner join dbo.application_asset aps on (aps.asset_no = ast.asset_no)
	where	ast.agreement_no = @p_agreement_no
	and		ast.is_request_gts = '1'
	and		ast.asset_status = 'RENTED'
	and		ast.asset_no not in
			(
				select	ard.old_asset_no
				from	dbo.asset_replacement ar
						inner join dbo.asset_replacement_detail ard on (ard.replacement_code = ar.code)
				where	ar.status <> 'CANCEL'
			)
	and		(
				ast.asset_no					like '%' + @p_keywords + '%'
				or	ast.asset_name				like '%' + @p_keywords + '%'
				or	sgs.description				like '%' + @p_keywords + '%'
				or	ast.asset_year				like '%' + @p_keywords + '%'
				or	ast.asset_condition			like '%' + @p_keywords + '%'
				or	ast.lease_rounded_amount	like '%' + @p_keywords + '%'
				or	ast.net_margin_amount		like '%' + @p_keywords + '%'
			)
	order by	case 
					when @p_sort_by='asc' then case @p_order_by
													when 1 then ast.asset_no + ast.asset_name
													when 2 then ast.fa_code + am.facility_name
													when 3 then ast.fa_reff_no_01 + ast.fa_reff_no_02 + ast.fa_reff_no_03
													when 4 then ast.replacement_fa_code + ast.replacement_fa_name
													when 5 then ast.replacement_fa_reff_no_01 + ast.replacement_fa_reff_no_02 + ast.replacement_fa_reff_no_03
													when 6 then cast(ast.estimate_po_date as sql_variant)
													when 7 then cast(datediff(day, ast.estimate_po_date, ast.estimate_po_date) as sql_variant)
													when 8 then cast(ast.estimate_delivery_date as sql_variant)
												end
					end asc,
				case 
					when @p_sort_by='desc' then case @p_order_by 
													when 1 then ast.asset_no + ast.asset_name
													when 2 then ast.fa_code + am.facility_name
													when 3 then ast.fa_reff_no_01 + ast.fa_reff_no_02 + ast.fa_reff_no_03
													when 4 then ast.replacement_fa_code + ast.replacement_fa_name
													when 5 then ast.replacement_fa_reff_no_01 + ast.replacement_fa_reff_no_02 + ast.replacement_fa_reff_no_03
													when 6 then cast(ast.estimate_po_date as sql_variant)
													when 7 then cast(datediff(day, ast.estimate_po_date, ast.estimate_po_date) as sql_variant)
													when 8 then cast(ast.estimate_delivery_date as sql_variant)
												end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only;

end ;
