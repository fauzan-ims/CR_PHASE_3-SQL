CREATE PROCEDURE dbo.xsp_credit_note_detail_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5) 
	--
	,@p_code	   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	credit_note_detail cnd
			inner join dbo.invoice_detail ivd on (ivd.invoice_no = cnd.invoice_no and cnd.invoice_detail_id = ivd.id)
			inner join dbo.agreement_asset aa on (aa.asset_no = ivd.asset_no and aa.agreement_no = ivd.agreement_no)
			inner join dbo.agreement_main am on (am.agreement_no = ivd.agreement_no)
	where	cnd.credit_note_code = @p_code
			and (
					ivd.agreement_no											like '%' + @p_keywords + '%'
					or	ivd.asset_no											like '%' + @p_keywords + '%'
					or	am.client_name											like '%' + @p_keywords + '%'
					or	ivd.description											like '%' + @p_keywords + '%'
					or	ivd.quantity											like '%' + @p_keywords + '%'
					or	ivd.billing_amount										like '%' + @p_keywords + '%'
					or	ivd.pph_amount											like '%' + @p_keywords + '%'
					or	ivd.ppn_amount											like '%' + @p_keywords + '%'
					or	ivd.total_amount										like '%' + @p_keywords + '%'
					or	cnd.adjustment_amount									like '%' + @p_keywords + '%'
					or	am.agreement_external_no								like '%' + @p_keywords + '%'
					or	isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01)	like '%' + @p_keywords + '%'
				) ;

	select		cnd.id
				,cnd.invoice_no
				,ivd.agreement_no			 
				,ivd.asset_no + ' - ' + isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01) 'asset_no'
				,am.client_name			 
				,ivd.description			 
				,ivd.quantity			 
				,ivd.billing_amount	-ivd.discount_amount 'billing_amount'
				,ivd.pph_amount
				,ivd.ppn_amount
				,ivd.total_amount		 
				,cnd.adjustment_amount
				,am.agreement_external_no 
				,@rows_count 'rowcount'
	from		credit_note_detail cnd
				inner join dbo.invoice_detail ivd on (ivd.invoice_no = cnd.invoice_no and cnd.invoice_detail_id = ivd.id)
				inner join dbo.agreement_asset aa on (aa.asset_no = ivd.asset_no and aa.agreement_no = ivd.agreement_no)
				inner join dbo.agreement_main am on (am.agreement_no = ivd.agreement_no)
	where		cnd.credit_note_code = @p_code
				and (
						ivd.agreement_no											like '%' + @p_keywords + '%'
						or	ivd.asset_no											like '%' + @p_keywords + '%'
						or	am.client_name											like '%' + @p_keywords + '%'
						or	ivd.description											like '%' + @p_keywords + '%'
						or	ivd.quantity											like '%' + @p_keywords + '%'
						or	ivd.billing_amount										like '%' + @p_keywords + '%'
						or	ivd.pph_amount											like '%' + @p_keywords + '%'
						or	ivd.ppn_amount											like '%' + @p_keywords + '%'
						or	ivd.total_amount										like '%' + @p_keywords + '%'
						or	cnd.adjustment_amount									like '%' + @p_keywords + '%'
						or	am.agreement_external_no								like '%' + @p_keywords + '%'
						or	isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01)	like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then am.agreement_external_no
													 when 2 then ivd.asset_no
													 when 3 then ivd.description
													 when 4 then cast(ivd.quantity as sql_variant)
													 when 5 then cast(ivd.billing_amount as sql_variant)
													 when 6 then cast(ivd.total_amount as sql_variant)
													 when 7 then cast(adjustment_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then am.agreement_external_no
													   when 2 then ivd.asset_no
													   when 3 then ivd.description
													   when 4 then cast(ivd.quantity as sql_variant)
													   when 5 then cast(ivd.billing_amount as sql_variant)
													   when 6 then cast(ivd.total_amount as sql_variant)
													   when 7 then cast(adjustment_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
