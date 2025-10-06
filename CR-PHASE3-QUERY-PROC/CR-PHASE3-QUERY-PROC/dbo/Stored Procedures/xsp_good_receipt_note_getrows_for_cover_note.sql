
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_good_receipt_note_getrows_for_cover_note]
(
	@p_keywords			  nvarchar(50)
	,@p_pagenumber		  int
	,@p_rowspage		  int
	,@p_order_by		  int
	,@p_sort_by			  nvarchar(5)
	,@p_cover_note_status nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	create table #temp_table
	(
		code				 nvarchar(50)
		,company_code		 nvarchar(50)
		,purchase_order_code nvarchar(50)
		,receive_date		 nvarchar(50)
		,supplier_code		 nvarchar(50)
		,supplier_name		 nvarchar(250)
		,branch_code		 nvarchar(50)
		,branch_name		 nvarchar(250)
		,division_code		 nvarchar(50)
		,division_name		 nvarchar(250)
		,department_code	 nvarchar(50)
		,department_name	 nvarchar(250)
		,remark				 nvarchar(4000)
		,status				 nvarchar(50)
		,cover_note_status	 nvarchar(50)
	) ;

	insert into #temp_table
	(
		code
		,company_code
		,purchase_order_code
		,receive_date
		,supplier_code
		,supplier_name
		,branch_code
		,branch_name
		,division_code
		,division_name
		,department_code
		,department_name
		,remark
		,status
		,cover_note_status
	)
	select	distinct
			grn.code
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
			,grn.cover_note_status
	from	good_receipt_note						 grn
			inner join dbo.good_receipt_note_detail	 grnd on (grn.code							   = grnd.good_receipt_note_code)
			inner join dbo.purchase_order			 po on (po.code								   = grn.purchase_order_code)
			inner join dbo.purchase_order_detail	 pod on (
																pod.po_code						   = po.code
																and pod.id						   = grnd.purchase_order_detail_id
															)
			inner join dbo.supplier_selection_detail ssd on (ssd.id								   = pod.supplier_selection_detail_id)
			left join dbo.quotation_review_detail	 qrd on (qrd.id								   = ssd.quotation_detail_id)
			inner join dbo.procurement				 prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
			inner join dbo.procurement_request		 pr on (prc.procurement_request_code		   = pr.code)
			inner join dbo.procurement_request_item	 pri on (
																pr.code							   = pri.procurement_request_code
																and pri.item_code				   = grnd.item_code
															)
	where	grn.status				    IN('APPROVE', 'POST')
			and pri.category_type	  = 'ASSET'
			and pr.procurement_type	  = 'PURCHASE'
			and grnd.receive_quantity <> 0 ;

	select	@rows_count = count(1)
	from	#temp_table
	where	cover_note_status = case @p_cover_note_status
									when 'ALL' then cover_note_status
									else @p_cover_note_status
								end
			and
			(
				code											like '%' + @p_keywords + '%'
				or	purchase_order_code							like '%' + @p_keywords + '%'
				or	convert(varchar(30), receive_date, 103)		like '%' + @p_keywords + '%'
				or	supplier_name								like '%' + @p_keywords + '%'
				or	branch_name									like '%' + @p_keywords + '%'
				or	cover_note_status							like '%' + @p_keywords + '%'
				or	remark										like '%' + @p_keywords + '%'
			) ;

	select		code
				,company_code
				,purchase_order_code
				,receive_date
				,supplier_code
				,supplier_name
				,branch_code
				,branch_name
				,division_code
				,division_name
				,department_code
				,department_name
				,remark
				,status
				,cover_note_status
				,@rows_count 'rowcount'
	from		#temp_table
	where		cover_note_status = case @p_cover_note_status
										when 'ALL' then cover_note_status
										else @p_cover_note_status
									end
				and
				(
					code											like '%' + @p_keywords + '%'
					or	purchase_order_code							like '%' + @p_keywords + '%'
					or	convert(varchar(30), receive_date, 103)		like '%' + @p_keywords + '%'
					or	supplier_name								like '%' + @p_keywords + '%'
					or	branch_name									like '%' + @p_keywords + '%'
					or	cover_note_status							like '%' + @p_keywords + '%'
					or	remark										like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then purchase_order_code collate sql_latin1_general_cp1_ci_as
													 when 3 then cast(receive_date as sql_variant)
													 when 4 then supplier_name
													 when 5 then remark
													 when 6 then cover_note_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then purchase_order_code collate sql_latin1_general_cp1_ci_as
													   when 3 then cast(receive_date as sql_variant)
													   when 4 then supplier_name
													   when 5 then remark
													   when 6 then cover_note_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
