--created by, Rian at 08/05/2023 

CREATE PROCEDURE [dbo].[xsp_due_date_change_amortization_history_getrows]
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_asset_no				nvarchar(50)
	,@p_due_date_change_code	nvarchar(50)

)
as
begin
	
	declare @rows_count			int = 0 

	select	@rows_count = count(1)
	from		dbo.due_date_change_amortization_history ddc
	inner join	dbo.agreement_asset aa on (aa.asset_no = ddc.asset_no)
	where		ddc.asset_no				= @p_asset_no
	and			ddc.due_date_change_code	= @p_due_date_change_code
	and			ddc.old_or_new				= 'NEW'
	and			(
					ddc.asset_no										like '%' + @p_keywords + '%'
					or	ddc.installment_no								like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), ddc.due_date, 103)		like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), ddc.billing_date, 103)	like '%' + @p_keywords + '%'
					or	ddc.description									like '%' + @p_keywords + '%'
					or	ddc.billing_amount								like '%' + @p_keywords + '%'
				) ;

	select		ddc.due_date_change_code
				,ddc.installment_no
				,ddc.asset_no								 
				,convert(nvarchar(15), ddc.due_date, 103) 'due_date'									 
				,convert(nvarchar(15), ddc.billing_date, 103) 'billing_date'
				,ddc.billing_amount
				,ddc.description
				,aa.asset_name
				,ddc.old_or_new
				,@rows_count 'rowcount'
	from		dbo.due_date_change_amortization_history ddc
	inner join	dbo.agreement_asset aa on (aa.asset_no = ddc.asset_no)
	where		ddc.asset_no				= @p_asset_no
	and			ddc.due_date_change_code	= @p_due_date_change_code
	and			ddc.old_or_new				= 'NEW'
	and			(
					ddc.asset_no										like '%' + @p_keywords + '%'
					or	ddc.installment_no								like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), ddc.due_date, 103)		like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), ddc.billing_date, 103)	like '%' + @p_keywords + '%'
					or	ddc.description									like '%' + @p_keywords + '%'
					or	ddc.billing_amount								like '%' + @p_keywords + '%'
				) 
	order by ddc.installment_no asc
end ;
