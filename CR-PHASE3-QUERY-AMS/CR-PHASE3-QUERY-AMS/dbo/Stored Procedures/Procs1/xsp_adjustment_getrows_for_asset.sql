CREATE PROCEDURE [dbo].[xsp_adjustment_getrows_for_asset]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_asset_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.asset				  ass
			inner join dbo.adjustment adj on (adj.asset_code = ass.code)
			inner join dbo.adjustment_detail adl on (adl.adjustment_code = adj.code)
			left join dbo.sys_general_subcode sgs on (sgs.code = adl.adjusment_transaction_code)
	where	ass.code	   = @p_asset_code
			and adj.status = 'POST'
			and
			(
				adj.code												like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), adj.date, 103)				like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), new_purchase_date, 103)		like '%' + @p_keywords + '%'
				or	old_netbook_value_fiscal							like '%' + @p_keywords + '%'
				or	new_netbook_value_fiscal							like '%' + @p_keywords + '%'
				or	total_adjustment									like '%' + @p_keywords + '%'
				or	remark												like '%' + @p_keywords + '%'
				or	adl.uom												like '%' + @p_keywords + '%'
				or	adl.quantity										like '%' + @p_keywords + '%'
			) ;

	select		adj.code
				,adj.branch_code
				,adj.company_code
				,convert(nvarchar(30), new_purchase_date, 103) 'new_date'
				,adj.description
				,adj.asset_code
				,payment_by
				,isnull(sgs.description, adl.adjustment_description) 'remark'
				,convert(nvarchar(30), adj.date, 103)		   'adjustment_date'
				,adj.status
				,adj.branch_name
				,adj.old_netbook_value_comm					   'old_netbook_value_fiscal'
				,new_netbook_value_comm
				,old_total_depre_comm						   'old_netbook_value'
				,total_adjustment
				,new_netbook_value_fiscal
				,total_adjustment
				,adl.uom
				,adl.quantity
				,@rows_count								   'rowcount'
	from		dbo.asset				  ass
				inner join dbo.adjustment adj on (adj.asset_code = ass.code)
				inner join dbo.adjustment_detail adl on (adl.adjustment_code = adj.code)
				left join dbo.sys_general_subcode sgs on (sgs.code = adl.adjusment_transaction_code)
	where		ass.code	   = @p_asset_code
				and adj.status = 'POST'
				and
				(
					adj.code												like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), adj.date, 103)				like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), new_purchase_date, 103)		like '%' + @p_keywords + '%'
					or	old_netbook_value_fiscal							like '%' + @p_keywords + '%'
					or	new_netbook_value_fiscal							like '%' + @p_keywords + '%'
					or	total_adjustment									like '%' + @p_keywords + '%'
					or	remark												like '%' + @p_keywords + '%'
					or	adl.uom												like '%' + @p_keywords + '%'
					or	adl.quantity										like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then adj.code
													 when 2 then cast(adj.date as sql_variant)
													 when 3 then cast(new_purchase_date as sql_variant)
													 when 4 then cast(new_netbook_value_fiscal as sql_variant)
													 when 5 then cast(new_netbook_value_comm as sql_variant)
													 when 6 then cast(total_adjustment as sql_variant)
													 when 7 then isnull(sgs.description, adl.adjustment_description)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then adj.code
													   when 2 then cast(adj.date as sql_variant)
													   when 3 then cast(new_purchase_date as sql_variant)
													   when 4 then cast(new_netbook_value_fiscal as sql_variant)
													   when 5 then cast(new_netbook_value_comm as sql_variant)
													   when 6 then cast(total_adjustment as sql_variant)
													   when 7 then isnull(sgs.description, adl.adjustment_description)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
