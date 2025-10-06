CREATE PROCEDURE dbo.xsp_agreement_invoice_detail_getrows
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_invoice_no nvarchar(50)
)
as
begin

	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.agreement_invoice_detail aid
			inner join dbo.agreement_main am on (am.agreement_no = aid.agreement_no)
			left join dbo.agreement_asset ast on (ast.asset_no = aid.asset_no)
	where	invoice_no = @p_invoice_no
	and		(
				aid.agreement_no					like '%' + @p_keywords + '%'
				or	am.client_name					like '%' + @p_keywords + '%'
				or	aid.description					like '%' + @p_keywords + '%'
				or	aid.quantity					like '%' + @p_keywords + '%'
				or	aid.billing_amount				like '%' + @p_keywords + '%'
				or	aid.total_amount				like '%' + @p_keywords + '%'
			) ;

	select	aid.id
			,aid.invoice_no
			,aid.agreement_no
			,am.client_name
			,aid.asset_no
			,aid.billing_no
			,aid.description
			,aid.quantity
			,aid.billing_amount
			,aid.discount_amount
			,aid.ppn_amount
			,aid.pph_amount
			,aid.ppn_bm_amount
			,aid.total_amount
			,@rows_count 'rowcount'
	from	dbo.agreement_invoice_detail aid
			inner join dbo.agreement_main am on (am.agreement_no = aid.agreement_no)
			left join dbo.agreement_asset ast on (ast.asset_no = aid.asset_no)
	where	invoice_no = @p_invoice_no
	and		(
				aid.agreement_no					like '%' + @p_keywords + '%'
				or	am.client_name					like '%' + @p_keywords + '%'
				or	aid.description					like '%' + @p_keywords + '%'
				or	aid.quantity					like '%' + @p_keywords + '%'
				or	aid.billing_amount				like '%' + @p_keywords + '%'
				or	aid.total_amount				like '%' + @p_keywords + '%'
			)
	order by	case 
					when @p_sort_by='asc' then case @p_order_by
													when 1 then aid.agreement_no
													when 2 then aid.description
													when 3 then cast(aid.quantity as sql_variant)
													when 4 then aid.billing_amount
													when 5 then aid.total_amount
												end
					end asc,
				case 
					when @p_sort_by='desc' then case @p_order_by 
													when 1 then aid.agreement_no
													when 2 then aid.description
													when 3 then cast(aid.quantity as sql_variant)
													when 4 then aid.billing_amount
													when 5 then aid.total_amount
												end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only;
end ;
