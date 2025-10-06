CREATE PROCEDURE dbo.xsp_efam_interface_journal_gl_link_transaction_detail_getrows
(
	@p_keywords					 nvarchar(50)
	,@p_pagenumber				 int
	,@p_rowspage				 int
	,@p_order_by				 int
	,@p_sort_by					 nvarchar(5)
	,@p_company_code			 nvarchar(50)
	,@p_gl_link_transaction_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	efam_interface_journal_gl_link_transaction_detail jglt
			left join dbo.master_category mc on (mc.transaction_depre_code = jglt.gl_link_code)
			left join dbo.master_category mc2 on (mc2.transaction_accum_depre_code = jglt.gl_link_code)
			left join dbo.master_category mc3 on (mc3.transaction_gain_loss_code = jglt.gl_link_code)
			left join dbo.master_category mc4 on (mc4.transaction_loss_sell_code = jglt.gl_link_code)
	where	jglt.company_code			 = @p_company_code
			and gl_link_transaction_code = @p_gl_link_transaction_code
			and
			(
				branch_code										like '%' + @p_keywords + '%'
				or	remarks										like '%' + @p_keywords + '%'
				or	orig_currency_code							like '%' + @p_keywords + '%'
				or	convert(varchar(30), base_amount_db, 103)	like '%' + @p_keywords + '%'
				or	convert(varchar(30), base_amount_cr, 103)	like '%' + @p_keywords + '%'
				or	division_name								like '%' + @p_keywords + '%'
				or	department_name								like '%' + @p_keywords + '%'
				or	mc.transaction_depre_name					like '%' + @p_keywords + '%'
				or	mc2.transaction_accum_depre_name			like '%' + @p_keywords + '%'
				or	mc3.transaction_gain_loss_name				like '%' + @p_keywords + '%'
				or	mc4.transaction_loss_sell_name				like '%' + @p_keywords + '%'
			) ;

	select		id
				,gl_link_transaction_code
				,jglt.company_code
				,branch_code
				,branch_name
				,jglt.cost_center_code
				,jglt.cost_center_name
				,jglt.gl_link_code
				,mc.transaction_depre_name
				,mc2.transaction_accum_depre_name
				,mc3.transaction_gain_loss_name
				,mc4.transaction_loss_sell_name
				,contra_gl_link_code
				,agreement_no
				,facility_code
				,facility_name
				,purpose_loan_code
				,purpose_loan_name
				,purpose_loan_detail_code
				,purpose_loan_detail_name
				,orig_currency_code
				,orig_amount_db
				,orig_amount_cr
				,exch_rate
				,base_amount_db
				,base_amount_cr
				,division_code
				,division_name
				,department_code
				,department_name
				,remarks
				,@rows_count			 'rowcount'
	from		efam_interface_journal_gl_link_transaction_detail jglt
	left join dbo.master_category mc on (mc.transaction_depre_code = jglt.gl_link_code)
	left join dbo.master_category mc2 on (mc2.transaction_accum_depre_code = jglt.gl_link_code)
	left join dbo.master_category mc3 on (mc3.transaction_gain_loss_code = jglt.gl_link_code)
	left join dbo.master_category mc4 on (mc4.transaction_loss_sell_code = jglt.gl_link_code)
	where		jglt.company_code			 = @p_company_code
				and gl_link_transaction_code = @p_gl_link_transaction_code
				and
				(
					branch_code										like '%' + @p_keywords + '%'
					or	remarks										like '%' + @p_keywords + '%'
					or	orig_currency_code							like '%' + @p_keywords + '%'
					or	convert(varchar(30), base_amount_db, 103)	like '%' + @p_keywords + '%'
					or	convert(varchar(30), base_amount_cr, 103)	like '%' + @p_keywords + '%'
					or	division_name								like '%' + @p_keywords + '%'
					or	department_name								like '%' + @p_keywords + '%'
					or	mc.transaction_depre_name					like '%' + @p_keywords + '%'
					or	mc2.transaction_accum_depre_name			like '%' + @p_keywords + '%'
					or	mc3.transaction_gain_loss_name				like '%' + @p_keywords + '%'
					or	mc4.transaction_loss_sell_name				like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then branch_name
													 when 2 then mc.transaction_depre_name + mc2.transaction_accum_depre_name + mc3.transaction_gain_loss_name + mc4.transaction_loss_sell_name
													 when 3 then remarks
													 when 4 then orig_currency_code
													 when 5 then cast(base_amount_db as sql_variant)
													 when 6 then cast(base_amount_cr as sql_variant)
													 when 7 then division_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then branch_name
													   when 2 then mc.transaction_depre_name + mc2.transaction_accum_depre_name + mc3.transaction_gain_loss_name + mc4.transaction_loss_sell_name
													   when 3 then remarks
													   when 4 then orig_currency_code
													   when 5 then cast(base_amount_db as sql_variant)
													   when 6 then cast(base_amount_cr as sql_variant)
													   when 7 then division_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
