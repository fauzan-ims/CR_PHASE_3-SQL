
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_ap_invoice_registration_for_payment_selection_getrows]
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_company_code nvarchar(50))
as
begin
	declare @rows_count int = 0 ;

	--if exists
	--(
	--	select	1
	--	from	sys_global_param
	--	where	code	  = 'HO'
	--			and value = @p_branch_code
	--)
	--begin
	--	set @p_branch_code = 'ALL' ;
	--end ;

	select	@rows_count = count(1)
	from	ap_invoice_registration air
	where	air.company_code	= @p_company_code
			and air.status		IN ('APPROVE', 'POST')
			and air.code not in
				(
					select	aprd.invoice_register_code
					from	dbo.ap_payment_request_detail aprd
					inner join dbo.ap_payment_request apr on apr.code = aprd.payment_request_code
					where	apr.status in ('HOLD', 'ON PROCESS', 'APPROVE', 'PAID')
				)
			and (
					air.code										like '%' + @p_keywords + '%'
					or	convert(varchar(30), air.invoice_date, 103) like '%' + @p_keywords + '%'
					or	air.currency_code							like '%' + @p_keywords + '%'
					or	air.supplier_name							like '%' + @p_keywords + '%'
					or	convert(varchar(30), air.due_date, 103)		like '%' + @p_keywords + '%'
					or	air.branch_name								like '%' + @p_keywords + '%'
					or	air.division_name							like '%' + @p_keywords + '%'
					or	air.department_name							like '%' + @p_keywords + '%'
					or	air.remark									like '%' + @p_keywords + '%'
					or	air.invoice_amount							like '%' + @p_keywords + '%'
					or	air.purchase_order_code						like '%' + @p_keywords + '%'
				) ;

	select		air.code
				,air.company_code
				,convert(varchar(30), air.invoice_date, 103) 'invoice_date'
				,air.currency_code
				,air.supplier_code
				,air.supplier_name
				,convert(varchar(30), air.due_date, 103) 'due_date'
				,air.purchase_order_code
				,air.branch_code
				,air.branch_name
				,air.division_code
				,air.division_name
				,air.department_code
				,air.department_name
				,air.invoice_amount
				,air.remark
				,@rows_count 'rowcount'
	from		ap_invoice_registration air
	where		air.company_code	= @p_company_code
				and air.status		IN ('APPROVE', 'POST')
				and air.code not in
					(
						select	aprd.invoice_register_code
						from	dbo.ap_payment_request_detail aprd
						inner join dbo.ap_payment_request apr on apr.code = aprd.payment_request_code
						where	apr.status in ('HOLD', 'ON PROCESS', 'APPROVE', 'PAID')
					)
				and (
						air.code										like '%' + @p_keywords + '%'
						or	convert(varchar(30), air.invoice_date, 103) like '%' + @p_keywords + '%'
						or	air.currency_code							like '%' + @p_keywords + '%'
						or	air.supplier_name							like '%' + @p_keywords + '%'
						or	convert(varchar(30), air.due_date, 103)		like '%' + @p_keywords + '%'
						or	air.branch_name								like '%' + @p_keywords + '%'
						or	air.division_name							like '%' + @p_keywords + '%'
						or	air.department_name							like '%' + @p_keywords + '%'
						or	air.remark									like '%' + @p_keywords + '%'
						or	air.invoice_amount							like '%' + @p_keywords + '%'
						or	air.purchase_order_code						like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then air.code
													 when 2 then cast(air.invoice_date as sql_variant)
													 when 3 then air.supplier_name
													 when 4 then cast(air.invoice_amount as sql_variant)
													 when 5 then air.remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then air.code
													 when 2 then cast(air.invoice_date as sql_variant)
													 when 3 then air.supplier_name
													 when 4 then cast(air.invoice_amount as sql_variant)
													 when 5 then air.remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
