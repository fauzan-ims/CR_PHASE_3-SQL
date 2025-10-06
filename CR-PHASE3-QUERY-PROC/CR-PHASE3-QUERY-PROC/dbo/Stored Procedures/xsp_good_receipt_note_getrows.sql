CREATE PROCEDURE [dbo].[xsp_good_receipt_note_getrows]
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_company_code nvarchar(50)
	,@p_status		 nvarchar(50)
--,@p_branch_code		nvarchar(50)
)
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
	from	good_receipt_note grn
	--		outer apply
	--(
	--	select	top 1
	--			grnd.spesification
	--	from	dbo.good_receipt_note_detail grnd
	--	where	grn.code = grnd.good_receipt_note_code
	--			and (grnd.spesification like '%' + @p_keywords + '%')
	--)						  detail
	where	grn.company_code = @p_company_code
			and grn.status	 = case @p_status
								   when 'ALL' then grn.status
								   else @p_status
							   end
			and
			(
				grn.code											like '%' + @p_keywords + '%'
				or	grn.purchase_order_code							like '%' + @p_keywords + '%'
				or	convert(varchar(30), grn.receive_date, 103)		like '%' + @p_keywords + '%'
				or	grn.supplier_name								like '%' + @p_keywords + '%'
				or	grn.branch_name									like '%' + @p_keywords + '%'
				or	grn.status										like '%' + @p_keywords + '%'
				or	grn.remark										like '%' + @p_keywords + '%'
				--or	detail.spesification							like '%' + @p_keywords + '%'
				-- (+) Ari 2024-03-26 ket : search plat no, engine no, chassis no
				or	grn.new_spesification							like '%' + @p_keywords + '%'
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
				--,detail.spesification
				--(+) Ari 2024-03-22 ket : add 
				,grnd.total_receive_quantity
				,grnd.total_unit_price
				,grnd.total_ppn
				,grnd.total_pph
				,grnd.total_amount 'total_grn_amount' --grnd2.total_grn_amount
				--(+) Ari 2024-03-22
				,@rows_count								 'rowcount'
	from		good_receipt_note grn
	--			outer apply
	--(
	--	select	top 1
	--			grnd.spesification
	--	from	dbo.good_receipt_note_detail grnd
	--	where	grn.code = grnd.good_receipt_note_code
	--			and (grnd.spesification like '%' + @p_keywords + '%')
	--)							  detail
				--(+) Ari 2024-03-22 ket : add cr total qty, price, ppn, pph
				outer apply
	(
		select	isnull(sum(receive_quantity), 0) 'total_receive_quantity'
				,isnull(sum(price_amount), 0)	 'total_unit_price'
				,isnull(sum(ppn_amount), 0)		 'total_ppn'
				,isnull(sum(pph_amount), 0)		 'total_pph'
				,isnull(sum(total_amount), 0)   'total_amount'
		from	dbo.good_receipt_note_detail
		where	good_receipt_note_code = grn.code
		and receive_quantity <> 0
	) grnd
	--			outer apply
	--(
	--	select	isnull(sum(price_amount), 0) + isnull(sum(ppn_amount), 0) + isnull(sum(pph_amount), 0) 'total_grn_amount'
	--	from	dbo.good_receipt_note_detail
	--	where	good_receipt_note_code = grn.code
	--			and receive_quantity   <> '1'
	--) grnd2
	--(+) Ari 2024-03-22 
	where		grn.company_code = @p_company_code
				and grn.status	 = case @p_status
									   when 'ALL' then grn.status
									   else @p_status
								   end
				and
				(
					grn.code											like '%' + @p_keywords + '%'
					or	grn.purchase_order_code							like '%' + @p_keywords + '%'
					or	convert(varchar(30), grn.receive_date, 103)		like '%' + @p_keywords + '%'
					or	grn.supplier_name								like '%' + @p_keywords + '%'
					or	grn.branch_name									like '%' + @p_keywords + '%'
					or	grn.status										like '%' + @p_keywords + '%'
					or	grn.remark										like '%' + @p_keywords + '%'
					--or	detail.spesification							like '%' + @p_keywords + '%'
					-- (+) Ari 2024-03-26 ket : search plat no, engine no, chassis no
					or	grn.new_spesification							like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then grn.code
													 when 2 then grn.purchase_order_code collate sql_latin1_general_cp1_ci_as
													 when 3 then cast(grn.receive_date as sql_variant)
													 when 4 then grn.supplier_name
													 when 5 then grnd.total_receive_quantity
													 when 6 then cast(grnd.total_ppn as sql_variant)
													 when 7 then grn.remark
													 when 8 then grn.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then grn.code
													   when 2 then grn.purchase_order_code collate sql_latin1_general_cp1_ci_as
													   when 3 then cast(grn.receive_date as sql_variant)
													   when 4 then grn.supplier_name
													   when 5 then grnd.total_receive_quantity
													   when 6 then cast(grnd.total_ppn as sql_variant)
													   when 7 then grn.remark
													   when 8 then grn.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
