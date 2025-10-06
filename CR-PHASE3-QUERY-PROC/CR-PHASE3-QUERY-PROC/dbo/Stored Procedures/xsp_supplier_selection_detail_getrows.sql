
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_supplier_selection_detail_getrows]
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_selection_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	supplier_selection_detail			  ssd
			left join dbo.supplier_selection	  ss on (ss.code = ssd.selection_code)
			left join dbo.quotation_review_detail qrd on (qrd.id = ssd.quotation_detail_id)
			left join ifinbam.dbo.master_item	  mi on mi.code	 = ssd.item_code
	where	ssd.selection_code = @p_selection_code
			and
			(
				ssd.item_name					like '%' + @p_keywords + '%'
				or	ssd.supplier_name			like '%' + @p_keywords + '%'
				or	ssd.quotation_quantity		like '%' + @p_keywords + '%'
				or	ssd.amount					like '%' + @p_keywords + '%'
				or	ssd.total_amount			like '%' + @p_keywords + '%'
				or	ssd.quotation_amount		like '%' + @p_keywords + '%'
				or	ssd.tax_name				like '%' + @p_keywords + '%'
				or	ssd.remark					like '%' + @p_keywords + '%'
				or	ssd.pph_amount				like '%' + @p_keywords + '%'
				or	ssd.ppn_amount				like '%' + @p_keywords + '%'
				or	ssd.reff_no					like '%' + @p_keywords + '%'
				or	ssd.discount_amount			like '%' + @p_keywords + '%'
				or	ssd.unit_from				like '%' + @p_keywords + '%'
				or	ssd.offering				like '%' + @p_keywords + '%'
				or	case
						when mi.CATEGORY_TYPE = 'ASSET' then ssd.asset_amount
						when mi.CATEGORY_TYPE = 'ACCESSORIES' then ssd.accesories_amount
						when mi.CATEGORY_TYPE = 'KAROSERI' then ssd.karoseri_amount
						else 0
					end							like '%' + @p_keywords + '%'
				or	case
						when mi.CATEGORY_TYPE = 'ASSET' then ssd.ASSET_DISCOUNT_AMOUNT
						when mi.CATEGORY_TYPE = 'ACCESSORIES' then ssd.ACCESORIES_DISCOUNT_AMOUNT
						when mi.CATEGORY_TYPE = 'KAROSERI' then ssd.KAROSERI_DISCOUNT_AMOUNT
						else 0
					end							like '%' + @p_keywords + '%'
				or	ssd.bbn_name				like '%' + @p_keywords + '%'
				or	ssd.bbn_location			like '%' + @p_keywords + '%'
				or	ssd.bbn_address				like '%' + @p_keywords + '%'
				or	ssd.deliver_to_address		like '%' + @p_keywords + '%'
			) ;

	select		ssd.id
				,ssd.selection_code
				,ssd.item_code
				,ssd.item_name
				,ssd.supplier_code
				,ssd.supplier_name
				,ssd.amount
				,ssd.quotation_amount
				,ssd.quantity
				,ssd.quotation_quantity
				,ssd.total_amount
				,ssd.remark
				,ssd.tax_code
				,ssd.tax_name
				,ssd.pph_amount
				,ssd.ppn_amount
				,ssd.reff_no
				,ssd.quotation_detail_id
				,qrd.reff_no 'procurement_code'
				,ssd.supplier_selection_detail_status
				,ssd.discount_amount
				,ssd.unit_from
				,ssd.spesification
				--,isnull(ssd.offering, qrd.offering) 'offering'
				,ssd.offering
				,case
					 when isnull(ssd.application_no, '') <> '' then case
																		when mi.CATEGORY_TYPE = 'ASSET' then case
																												 when ssd.total_amount > isnull(ssd.otr_amount, 0) then '1'
																												 else '0'
																											 end
																		when mi.CATEGORY_TYPE = 'ACCESSORIES' then case
																													   when ssd.total_amount > case
																																				   when ssd.item_code = 'DSFMIT240400001'
																																						and isnull(ssd.accesories_amount, 0) = 0 then ssd.gps_amount
																																				   when ssd.item_code = 'DSFMIT240600002'
																																						and isnull(ssd.accesories_amount, 0) = 0 then ssd.budget_amount
																																				   else ssd.accesories_amount
																																			   end then '1'
																													   else '0'
																												   end
																		when mi.CATEGORY_TYPE = 'KAROSERI' then case
																													when ssd.total_amount > isnull(ssd.karoseri_amount, 0) then '1'
																													else '0'
																												end
																	end
					 else '0'
				 end		 'marketing_amount'
				,case
					 when mi.CATEGORY_TYPE = 'ASSET' then ssd.otr_amount
					 else 0
				 end		 'otr_amount'
				,case
					 when mi.CATEGORY_TYPE = 'ASSET' then ssd.asset_amount
					 --when mi.code = 'DSFMIT240400001' then ssd.gps_amount
					 when mi.CATEGORY_TYPE = 'ACCESSORIES' then case
																	when ssd.item_code = 'DSFMIT240400001'
																		 and isnull(ssd.accesories_amount, 0) = 0 then ssd.gps_amount
																	when ssd.item_code = 'DSFMIT240600002'
																		 and isnull(ssd.accesories_amount, 0) = 0 then ssd.budget_amount
																	else ssd.accesories_amount
																end
					 when mi.CATEGORY_TYPE = 'KAROSERI' then ssd.karoseri_amount
					 when mi.CATEGORY_TYPE = 'MOBILISASI' then ssd.mobilization_amount
					 else 0
				 end		 'asset_amount'
				,case
					 when mi.CATEGORY_TYPE = 'ASSET' then ssd.ASSET_DISCOUNT_AMOUNT
					 when mi.CATEGORY_TYPE = 'ACCESSORIES' then case
																	when ssd.ITEM_CODE = 'DSFMIT240400001'
																		 and isnull(ssd.accesories_amount, 0) = 0 then 0
																	else ssd.ACCESORIES_DISCOUNT_AMOUNT
																end
					 when mi.CATEGORY_TYPE = 'KAROSERI' then ssd.KAROSERI_DISCOUNT_AMOUNT
					 else 0
				 end		 'asset_discount_amount'
				 ,ssd.bbn_name
				 ,ssd.bbn_location
				 ,ssd.bbn_address
				 ,ssd.deliver_to_address
				,@rows_count 'rowcount'
	from		supplier_selection_detail			  ssd
				left join dbo.supplier_selection	  ss on (ss.code = ssd.selection_code)
				left join dbo.quotation_review_detail qrd on (qrd.id = ssd.quotation_detail_id)
				left join ifinbam.dbo.master_item	  mi on mi.code	 = ssd.item_code
	where		ssd.selection_code = @p_selection_code
				and
				(
					ssd.item_name					like '%' + @p_keywords + '%'
					or	ssd.supplier_name			like '%' + @p_keywords + '%'
					or	ssd.quotation_quantity		like '%' + @p_keywords + '%'
					or	ssd.amount					like '%' + @p_keywords + '%'
					or	ssd.total_amount			like '%' + @p_keywords + '%'
					or	ssd.quotation_amount		like '%' + @p_keywords + '%'
					or	ssd.tax_name				like '%' + @p_keywords + '%'
					or	ssd.remark					like '%' + @p_keywords + '%'
					or	ssd.pph_amount				like '%' + @p_keywords + '%'
					or	ssd.ppn_amount				like '%' + @p_keywords + '%'
					or	ssd.reff_no					like '%' + @p_keywords + '%'
					or	ssd.discount_amount			like '%' + @p_keywords + '%'
					or	ssd.unit_from				like '%' + @p_keywords + '%'
					or	ssd.offering				like '%' + @p_keywords + '%'
					or	case
							when mi.CATEGORY_TYPE = 'ASSET' then ssd.asset_amount
							when mi.CATEGORY_TYPE = 'ACCESSORIES' then ssd.accesories_amount
							when mi.CATEGORY_TYPE = 'KAROSERI' then ssd.karoseri_amount
							else 0
						end							like '%' + @p_keywords + '%'
					or	case
							when mi.CATEGORY_TYPE = 'ASSET' then ssd.ASSET_DISCOUNT_AMOUNT
							when mi.CATEGORY_TYPE = 'ACCESSORIES' then ssd.ACCESORIES_DISCOUNT_AMOUNT
							when mi.CATEGORY_TYPE = 'KAROSERI' then ssd.KAROSERI_DISCOUNT_AMOUNT
							else 0
						end							like '%' + @p_keywords + '%'
					or	ssd.bbn_name				like '%' + @p_keywords + '%'
					or	ssd.bbn_location			like '%' + @p_keywords + '%'
					or	ssd.bbn_address				like '%' + @p_keywords + '%'
					or	ssd.deliver_to_address		like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ssd.supplier_name
													 when 2 then ssd.item_name
													 when 3 then cast(ssd.quotation_quantity as sql_variant)
													 when 4 then cast(case
																		  when mi.CATEGORY_TYPE = 'ASSET' then ssd.asset_amount
																		  when mi.CATEGORY_TYPE = 'ACCESSORIES' then ssd.accesories_amount
																		  when mi.CATEGORY_TYPE = 'KAROSERI' then ssd.karoseri_amount
																		  else 0
																	  end as sql_variant)
													 when 5 then cast(ssd.amount as sql_variant)
													 when 6 then ssd.tax_name
													 when 7 then ssd.offering
													 when 8 then ssd.bbn_name
													 when 9 then ssd.deliver_to_address
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then ssd.supplier_name
													   when 2 then ssd.item_name
													   when 3 then cast(ssd.quotation_quantity as sql_variant)
													   when 4 then cast(case
													   					  when mi.CATEGORY_TYPE = 'ASSET' then ssd.asset_amount
													   					  when mi.CATEGORY_TYPE = 'ACCESSORIES' then ssd.accesories_amount
													   					  when mi.CATEGORY_TYPE = 'KAROSERI' then ssd.karoseri_amount
													   					  else 0
													   				  end as sql_variant)
													   when 5 then cast(ssd.amount as sql_variant)
													   when 6 then ssd.tax_name
													   when 7 then ssd.offering
													   when 8 then ssd.bbn_name
													   when 9 then ssd.deliver_to_address
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
