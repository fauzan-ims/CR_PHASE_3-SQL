CREATE PROCEDURE dbo.xsp_monitoring_asset_sold_calim_to_sell_getrows
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
		where	code	  = 'ho'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'all' ;
	end ;

	select	@rows_count = count(1)
	from	dbo.asset	ast
			inner join	dbo.asset_vehicle	av	on av.asset_code	= ast.code
			inner join	dbo.sale_detail		sd	on sd.asset_code	= av.asset_code
			inner join	dbo.sale			sl	on sl.code			= sd.sale_code
			outer apply
			(
				select	top 1	
						cm.claim_remarks
						,ss.description 'reason'
						,ipm.insured_name
						,claim_loss_type
				from	dbo.claim_main cm 
				inner join dbo.claim_detail_asset cda		on cda.claim_code = cm.code
				inner join dbo.insurance_policy_asset ipa	on ipa.code = cda.policy_asset_code
				left join dbo.sys_general_subcode ss		on ss.code = cm.claim_reason_code
				inner join dbo.insurance_policy_main ipm	on ipm.code = ipa.policy_code
				where	ipa.fa_code = ast.code
						and	cm.claim_loss_type = 'cltlo'
						and	cm.claim_status in ('approve','paid')
				order by cm.cre_date desc
			)ins
	where		ast.branch_code = case @p_branch_code
										when 'all' then ast.branch_code
										else @p_branch_code
									end
    and			isnull(sd.is_sold, '') ='1'
	and			sd.sale_detail_status in ('post','paid')
	and			sl.sell_type = 'claim'
	and			ins.claim_loss_type = 'cltlo'
	and		(
				ast.code									like '%' + @p_keywords + '%'
				or ast.branch_code							like '%' + @p_keywords + '%'
				or ast.branch_name							like '%' + @p_keywords + '%'
				or ast.item_name							like '%' + @p_keywords + '%'
				or av.built_year							like '%' + @p_keywords + '%'
				or av.plat_no								like '%' + @p_keywords + '%'	
				or av.engine_no								like '%' + @p_keywords + '%'
				or av.chassis_no							like '%' + @p_keywords + '%'
				or convert(varchar(30),	sd.sale_date, 103)	like '%' + @p_keywords + '%'
				or sl.sell_type								like '%' + @p_keywords + '%'
				or ins.reason								like '%' + @p_keywords + '%'
				or ins.claim_remarks						like '%' + @p_keywords + '%'
				or ins.insured_name							like '%' + @p_keywords + '%'
				or sl.description							like '%' + @p_keywords + '%'
			) ;

	select		ast.code		
				,ast.branch_code
				,ast.branch_name
				,ast.item_name
				,av.built_year
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,convert(varchar(30), sd.sale_date, 103) as sold_date
				--,ast.insurance_status as insurance_name
				,ast.parking_location
				,ast.unit_province_name 
				,ast.unit_city_name
				,ins.reason
				,ins.claim_remarks 'remarks'
				,ins.insured_name 'insurance_name'
				,@rows_count 'rowcount'
	from	dbo.asset	ast
			inner join	dbo.asset_vehicle	av	on av.asset_code	= ast.code
			inner join	dbo.sale_detail		sd	on sd.asset_code	= av.asset_code
			inner join	dbo.sale			sl	on sl.code = sd.sale_code
			outer apply
			(
				select	top 1	
						cm.claim_remarks
						,ss.description 'reason'
						,ipm.insured_name
						,cm.claim_loss_type
				from	dbo.claim_main cm 
				inner join dbo.claim_detail_asset cda		on cda.claim_code = cm.code
				inner join dbo.insurance_policy_asset ipa	on ipa.code = cda.policy_asset_code
				left join dbo.sys_general_subcode ss		on ss.code = cm.claim_reason_code
				inner join dbo.insurance_policy_main ipm	on ipm.code = ipa.policy_code
				where	ipa.fa_code = ast.code
						and	cm.claim_loss_type = 'cltlo'
						and	cm.claim_status in ('approve','paid')
				order by cm.cre_date desc
			)ins
	where		ast.branch_code = case @p_branch_code
										when 'all' then ast.branch_code
										else @p_branch_code
									end
    and			isnull(sd.is_sold, '') ='1'
	and			sd.sale_detail_status in ('post','paid')
	and			sl.sell_type = 'claim'
	and			ins.claim_loss_type = 'cltlo'
	and		(
				ast.code									like '%' + @p_keywords + '%'
				or ast.branch_code							like '%' + @p_keywords + '%'
				or ast.branch_name							like '%' + @p_keywords + '%'
				or ast.item_name							like '%' + @p_keywords + '%'
				or av.built_year							like '%' + @p_keywords + '%'
				or av.plat_no								like '%' + @p_keywords + '%'	
				or av.engine_no								like '%' + @p_keywords + '%'
				or av.chassis_no							like '%' + @p_keywords + '%'
				or convert(varchar(30),	sd.sale_date, 103)	like '%' + @p_keywords + '%'
				or sl.sell_type								like '%' + @p_keywords + '%'
				or ins.reason								like '%' + @p_keywords + '%'
				or ins.claim_remarks						like '%' + @p_keywords + '%'
				or ins.insured_name							like '%' + @p_keywords + '%'
				or sl.description							like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ast.code + ast.branch_name
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then cast(sd.sale_date as sql_variant)
													 when 5 then ins.reason
													 when 6 then ins.insured_name
													 when 7 then ins.claim_remarks
													 when 8 then ast.parking_location
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ast.code + ast.branch_name
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then cast(sd.sale_date as sql_variant)
													 when 5 then ins.reason
													 when 6 then ins.insured_name
													 when 7 then ins.claim_remarks
													 when 8 then ast.parking_location
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
