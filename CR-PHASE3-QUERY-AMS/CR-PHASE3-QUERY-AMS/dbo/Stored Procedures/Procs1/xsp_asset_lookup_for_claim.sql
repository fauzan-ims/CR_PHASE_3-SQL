CREATE procedure [dbo].[xsp_asset_lookup_for_claim]
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_policy_code nvarchar(50)
	,@p_claim_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.insurance_policy_asset	ipa
			left join dbo.asset			ass on (ass.code	   = ipa.fa_code)
			left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	where	ipa.policy_code = @p_policy_code
			and ipa.code not in
				(
					select	policy_asset_code
					from	dbo.claim_detail_asset	  cda
							inner join dbo.claim_main clm on clm.code = cda.claim_code
					where	clm.claim_status in
					(
						'HOLD', 'ON PROCESS', 'APPROVE', 'PAID'
					)
				)
			and
			(
				ass.code				like '%' + @p_keywords + '%'
				or	avh.plat_no			like '%' + @p_keywords + '%'
				or	ass.item_name		like '%' + @p_keywords + '%'
				or	avh.engine_no		like '%' + @p_keywords + '%'
				or	avh.chassis_no		like '%' + @p_keywords + '%'
			) ;

	select		ass.code
				,ass.branch_code
				,ass.branch_name
				,ass.item_name
				,ass.purchase_price
				,ass.total_depre_comm
				,ass.net_book_value_comm
				,ass.item_group_code
				,avh.plat_no
				,avh.engine_no
				,avh.chassis_no
				,ipa.sum_insured_amount
				,ipa.code	 'policy_asset_code'
				,@rows_count 'rowcount'
	from		dbo.insurance_policy_asset	ipa
				left join dbo.asset			ass on (ass.code	   = ipa.fa_code)
				left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	where		ipa.policy_code = @p_policy_code
				and ipa.code not in
					(
						select	policy_asset_code
						from	dbo.claim_detail_asset	  cda
								inner join dbo.claim_main clm on clm.code = cda.claim_code
						where	clm.claim_status in
						(
							'HOLD', 'ON PROCESS', 'APPROVE', 'PAID'
						)
					)
				and
				(
					ass.code				like '%' + @p_keywords + '%'
					or	avh.plat_no			like '%' + @p_keywords + '%'
					or	ass.item_name		like '%' + @p_keywords + '%'
					or	avh.engine_no		like '%' + @p_keywords + '%'
					or	avh.chassis_no		like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ass.code
													 when 2 then ass.item_name
													 when 3 then avh.plat_no
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then ass.code
													   when 2 then ass.item_name
													   when 3 then avh.plat_no
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
