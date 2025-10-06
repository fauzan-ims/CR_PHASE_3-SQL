CREATE PROCEDURE dbo.xsp_spaf_asset_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_validation_status	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	spaf_asset sa
			left join asset a on a.code = sa.fa_code
			left join dbo.asset_vehicle av on av.asset_code = sa.fa_code
			--outer apply(select	count(1) 'id' from	dbo.spaf_claim_detail scd where	scd.spaf_asset_code = sa.code) claim
			outer apply(select	count(1) 'id' from	dbo.spaf_claim_detail scd 
							INNER JOIN dbo.SPAF_CLAIM b ON b.CODE = scd.SPAF_CLAIM_CODE
							WHERE	scd.spaf_asset_code = sa.code AND b.STATUS <> 'REJECT'
							) claim
	where	sa.validation_status = case @p_validation_status
										  when 'ALL' then sa.validation_status
										  else @p_validation_status
									  end
	and		(
				sa.code																										like '%' + @p_keywords + '%'
				or sa.claim_type																							like '%' + @p_keywords + '%'
				or sa.spaf_receipt_no																						like '%' + @p_keywords + '%'
				or sa.subvention_receipt_no																					like '%' + @p_keywords + '%'
				or convert(varchar(30), sa.receipt_date , 103)																like '%' + @p_keywords + '%'
				or convert(varchar(30), sa.date , 103)																		like '%' + @p_keywords + '%'
				or sa.fa_code																								like '%' + @p_keywords + '%'
				or a.item_name																								like '%' + @p_keywords + '%'
				or av.engine_no																								like '%' + @p_keywords + '%'
				or av.chassis_no																							like '%' + @p_keywords + '%'
				or av.plat_no																								like '%' + @p_keywords + '%'
				or a.purchase_price																							like '%' + @p_keywords + '%'
				or ((a.ppn/100) * sa.spaf_amount)																			like '%' + @p_keywords + '%'
				or ((a.pph/100) * sa.spaf_amount)																			like '%' + @p_keywords + '%'
				or (sa.spaf_amount + ((a.ppn/100) * sa.spaf_amount) - ((a.pph/100) * sa.spaf_amount))						like '%' + @p_keywords + '%'
				or sa.spaf_pct																								like '%' + @p_keywords + '%'
				or sa.spaf_amount																							like '%' + @p_keywords + '%'
				or sa.subvention_amount																						like '%' + @p_keywords + '%'
				or (a.ppn/100) * sa.subvention_amount																		like '%' + @p_keywords + '%'
				or (a.pph/100) * sa.subvention_amount																		like '%' + @p_keywords + '%'
				or (sa.subvention_amount + ((a.ppn/100) * sa.subvention_amount) - ((a.pph/100) * sa.subvention_amount))		like '%' + @p_keywords + '%'
				or sa.validation_status																						like '%' + @p_keywords + '%'
				or convert(varchar(30),sa.validation_date, 103)																like '%' + @p_keywords + '%'
				or sa.validation_remark																						like '%' + @p_keywords + '%'
			) ;

	select		sa.code				
				,convert(varchar(30), sa.date , 103) 'date'			
				,sa.fa_code	
				,a.item_name
				,av.engine_no
				,av.chassis_no
				,av.plat_no
				,a.purchase_price
				,(a.ppn/100) * sa.spaf_amount 'ppn'
				,(a.pph/100) * sa.SPAF_AMOUNT 'pph' 
				,(sa.spaf_amount + ((a.ppn/100) * sa.spaf_amount) - ((a.pph/100) * sa.spaf_amount))'net'
				,sa.spaf_pct		
				,sa.spaf_amount			
				,sa.validation_status	
				,convert(varchar(30), sa.validation_date, 103) 'validation_date'
				,sa.validation_remark	
				,sa.claim_code
				,sa.claim_type
				,sa.subvention_amount
				,(a.ppn/100) * sa.subvention_amount 'ppn_sub'
				,(a.pph/100) * sa.subvention_amount 'pph_sub' 
				,(sa.subvention_amount + ((a.ppn/100) * sa.subvention_amount) - ((a.pph/100) * sa.subvention_amount))'nett'
				,sa.spaf_receipt_no
				,sa.subvention_receipt_no
				,convert(varchar(30), sa.receipt_date, 103) 'receipt_date'
				,claim.id
				,@rows_count 'rowcount'
	from		spaf_asset sa
				left join asset a on a.code = sa.fa_code
				left join dbo.asset_vehicle av on av.asset_code = sa.fa_code
				outer apply(select	count(1) 'id' from	dbo.spaf_claim_detail scd 
							INNER JOIN dbo.SPAF_CLAIM b ON b.CODE = scd.SPAF_CLAIM_CODE
							WHERE	scd.spaf_asset_code = sa.code AND b.STATUS <> 'REJECT'
							) claim
	where		sa.validation_status = case @p_validation_status
										  when 'ALL' then sa.validation_status
										  else @p_validation_status
									  end
	and			(
					sa.code																										like '%' + @p_keywords + '%'
				or sa.claim_type																							like '%' + @p_keywords + '%'
				or sa.spaf_receipt_no																						like '%' + @p_keywords + '%'
				or sa.subvention_receipt_no																					like '%' + @p_keywords + '%'
				or convert(varchar(30), sa.receipt_date , 103)																like '%' + @p_keywords + '%'
				or convert(varchar(30), sa.date , 103)																		like '%' + @p_keywords + '%'
				or sa.fa_code																								like '%' + @p_keywords + '%'
				or a.item_name																								like '%' + @p_keywords + '%'
				or av.engine_no																								like '%' + @p_keywords + '%'
				or av.chassis_no																							like '%' + @p_keywords + '%'
				or av.plat_no																								like '%' + @p_keywords + '%'
				or a.purchase_price																							like '%' + @p_keywords + '%'
				or ((a.ppn/100) * sa.spaf_amount)																			like '%' + @p_keywords + '%'
				or ((a.pph/100) * sa.spaf_amount)																			like '%' + @p_keywords + '%'
				or (sa.spaf_amount + ((a.ppn/100) * sa.spaf_amount) - ((a.pph/100) * sa.spaf_amount))						like '%' + @p_keywords + '%'
				or sa.spaf_pct																								like '%' + @p_keywords + '%'
				or sa.spaf_amount																							like '%' + @p_keywords + '%'
				or sa.subvention_amount																						like '%' + @p_keywords + '%'
				or (a.ppn/100) * sa.subvention_amount																		like '%' + @p_keywords + '%'
				or (a.pph/100) * sa.subvention_amount																		like '%' + @p_keywords + '%'
				or (sa.subvention_amount + ((a.ppn/100) * sa.subvention_amount) - ((a.pph/100) * sa.subvention_amount))		like '%' + @p_keywords + '%'
				or sa.validation_status																						like '%' + @p_keywords + '%'
				or convert(varchar(30),sa.validation_date, 103)																like '%' + @p_keywords + '%'
				or sa.validation_remark																						like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then sa.code
													 when 2 then sa.spaf_receipt_no
													 when 3 then cast(sa.receipt_date as sql_variant)
													 when 4 then sa.fa_code + a.item_name 
													 when 5 then av.engine_no + av.chassis_no + av.plat_no
													 when 6 then cast(sa.spaf_amount as sql_variant)
													 when 7 then cast(sa.subvention_amount as sql_variant)
													 when 8 then cast(sa.validation_date as sql_variant)
													 when 9 then sa.validation_remark	
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then sa.code
													 when 2 then sa.spaf_receipt_no
													 when 3 then cast(sa.receipt_date as sql_variant)
													 when 4 then fa_code + a.item_name 
													 when 5 then av.engine_no + av.chassis_no + av.plat_no
													 when 6 then cast(sa.spaf_amount as sql_variant)
													 when 7 then cast(sa.subvention_amount as sql_variant)
													 when 8 then cast(sa.validation_date as sql_variant)
													 when 9 then sa.validation_remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
