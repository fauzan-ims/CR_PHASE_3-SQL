CREATE PROCEDURE dbo.xsp_monitoring_gps_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_status			nvarchar(50)
)
as
begin
	declare @rows_count int = 0 
			,@first_payment datetime;

	select	@rows_count = count(1)
	from	dbo.monitoring_gps mg
			inner join dbo.asset ast on ast.code = mg.fa_code
			inner join dbo.asset_vehicle		av	on av.asset_code = ast.code
			outer apply (	select	ags.handover_bast_date, isnull(ags.maturity_date, dateadd(month,ags.periode,ags.handover_bast_date)) 'maturity_date'
							from	ifinopl.dbo.agreement_main am 
									inner join ifinopl.dbo.agreement_asset ags on ags.agreement_no = am.agreement_no
							where	am.agreement_no = ast.agreement_no
							and		ags.fa_code = mg.fa_code
							and		ast.asset_no = ags.asset_no
						) am
	where	mg.status = case @p_status
						when 'all' then mg.status
						else @p_status
					end
	and		(
					ast.code												like '%' + @p_keywords + '%'
					or ast.item_name										like '%' + @p_keywords + '%'
					or av.plat_no											like '%' + @p_keywords + '%'
					or av.engine_no											like '%' + @p_keywords + '%'
					or av.chassis_no										like '%' + @p_keywords + '%'
					or ast.agreement_external_no							like '%' + @p_keywords + '%'
					or convert(nvarchar(30), am.handover_bast_date, 103)	like '%' + @p_keywords + '%'
					or convert(nvarchar(30), am.maturity_date, 103)			like '%' + @p_keywords + '%'
					or mg.vendor_name										like '%' + @p_keywords + '%'
					or mg.status											like '%' + @p_keywords + '%'
			) ;

	
	select		ast.code
				,ast.item_name
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,ast.agreement_external_no
				,mg.vendor_name
				,convert(nvarchar(30), mg.first_payment_date, 103) 'first_payment_date'
				,convert(nvarchar(30), handover_bast_date, 103) 'from_periode'
				,convert(nvarchar(30), maturity_date, 103) 'to_periode'
				,mg.status 'gps_status'
				,mg.id
				,@rows_count 'rowcount'
	from	dbo.monitoring_gps mg
			inner join dbo.asset ast on ast.code = mg.fa_code
			inner join dbo.asset_vehicle		av	on av.asset_code = ast.code
			outer apply (	select	ags.handover_bast_date, isnull(ags.maturity_date, dateadd(month,ags.periode,ags.handover_bast_date)) 'maturity_date'
							from	ifinopl.dbo.agreement_main am 
									inner join ifinopl.dbo.agreement_asset ags on ags.agreement_no = am.agreement_no
							where	am.agreement_no = ast.agreement_no
							and		ags.fa_code = mg.fa_code
							and		ast.asset_no = ags.asset_no
						) am
	where	mg.status = case @p_status
						when 'all' then mg.status
						else @p_status
					end
	and		(
					ast.code												like '%' + @p_keywords + '%'
					or ast.item_name										like '%' + @p_keywords + '%'
					or av.plat_no											like '%' + @p_keywords + '%'
					or av.engine_no											like '%' + @p_keywords + '%'
					or av.chassis_no										like '%' + @p_keywords + '%'
					or ast.agreement_external_no							like '%' + @p_keywords + '%'
					or convert(nvarchar(30), am.handover_bast_date, 103)	like '%' + @p_keywords + '%'
					or convert(nvarchar(30), am.maturity_date, 103)			like '%' + @p_keywords + '%'
					or mg.vendor_name										like '%' + @p_keywords + '%'
					or mg.status											like '%' + @p_keywords + '%'
				)	
	order by	
	case
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then ast.code
													when 2 then ast.item_name
													when 3 then av.plat_no
													when 4 then ast.agreement_external_no
													when 5 then mg.vendor_name
													when 6 then mg.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
												    when 1 then ast.code
													when 2 then ast.item_name
													when 3 then av.plat_no
													when 4 then ast.agreement_external_no
													when 5 then mg.vendor_name
													when 6 then mg.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
