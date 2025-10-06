
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_good_receipt_note_getrows_for_lookup]
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_purchase_order_code nvarchar(50)
	,@p_invoice_register_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	good_receipt_note					  grn
	where	grn.purchase_order_code = @p_purchase_order_code
			and grn.reff_no is null
			and grn.status			  IN('APPROVE', 'POST')
			and grn.code not in
				(
					select	ird.grn_code
					from	dbo.ap_invoice_registration_detail	   ird
							inner join dbo.ap_invoice_registration ir on ir.code = ird.invoice_register_code
					where	ir.purchase_order_code		  = @p_purchase_order_code
							and ird.invoice_register_code = @p_invoice_register_code
				)
			and (
					grn.code										like '%' + @p_keywords + '%'
					or	convert(varchar(30), grn.receive_date, 103) like '%' + @p_keywords + '%'
					or	grn.branch_code								like '%' + @p_keywords + '%'
					or	grn.supplier_name							like '%' + @p_keywords + '%'
				) ;

	select		grn.code
				,grn.company_code
				,grn.purchase_order_code
				,convert(varchar(30), grn.receive_date, 103) 'receive_date'
				,grn.supplier_code
				,grn.supplier_name
				,grn.branch_code
				,grn.branch_name
				,grn.division_code
				,grn.division_name
				,grn.department_code
				,grn.department_name
				,grn.remark
				,grn.status
				,@rows_count								 'rowcount'
	from		good_receipt_note					  grn
	where		grn.purchase_order_code = @p_purchase_order_code
				and grn.reff_no is null
				and grn.status			  IN('APPROVE', 'POST')
				and grn.code not in
					(
						select	ird.grn_code
						from	dbo.ap_invoice_registration_detail	   ird
								inner join dbo.ap_invoice_registration ir on ir.code = ird.invoice_register_code
						where	ir.purchase_order_code		  = @p_purchase_order_code
								and ird.invoice_register_code = @p_invoice_register_code
					)
				and (
						grn.code										like '%' + @p_keywords + '%'
						or	convert(varchar(30), grn.receive_date, 103) like '%' + @p_keywords + '%'
						or	grn.branch_code								like '%' + @p_keywords + '%'
						or	grn.supplier_name							like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then grn.code
													 when 2 then cast(grn.receive_date as sql_variant)
													 when 3 then grn.branch_name
													 when 4 then grn.supplier_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then grn.code
													 when 2 then cast(grn.receive_date as sql_variant)
													 when 3 then grn.branch_name
													 when 4 then grn.supplier_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
