CREATE procedure [dbo].[xsp_supplier_selection_getrows]
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_company_code nvarchar(50)
	,@p_status		 nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	supplier_selection ss
			outer apply
	(
		select	top 1
				remark
				,ssd.item_name
				,ssd.asset_amount
				,ssd.quotation_amount
		from	dbo.supplier_selection_detail ssd
		where	ssd.selection_code = ss.code
	--and
	--(
	--	ssd.remark			like '%' + @p_keywords + '%'
	--	or	ssd.item_name	like '%' + @p_keywords + '%'
	--)
	)						   detail
			outer apply
	(
		select	top 1
				ssd.selection_code
		from	dbo.supplier_selection_detail	   ssd
				inner join ifinbam.dbo.master_item mi on mi.code = ssd.item_code
		where	ssd.selection_code	 = ss.code
				and ssd.total_amount > case
										   when mi.CATEGORY_TYPE = 'ASSET' then ssd.otr_amount
										   when mi.CATEGORY_TYPE = 'ACCESSORIES' then ssd.accesories_amount
										   when mi.CATEGORY_TYPE = 'KAROSERI' then ssd.karoseri_amount
									   end
	) selection_detail
	where	ss.company_code = @p_company_code
			and ss.status	= case @p_status
								  when 'ALL' then ss.status
								  else @p_status
							  end
			and
			(
				ss.code like '%' + @p_keywords + '%'
				or	ss.quotation_code like '%' + @p_keywords + '%'
				or	convert(varchar(30), ss.selection_date, 103) like '%' + @p_keywords + '%'
				or	ss.branch_name like '%' + @p_keywords + '%'
				or	ss.status like '%' + @p_keywords + '%'
				or	ss.remark like '%' + @p_keywords + '%'
				or	detail.remark like '%' + @p_keywords + '%'
				or	detail.item_name like '%' + @p_keywords + '%'
				or	case
						when detail.quotation_amount < detail.asset_amount then '1'
						else '0'
					end like '%' + @p_keywords + '%'
			) ;

	select		ss.code
				,ss.company_code
				,ss.quotation_code
				,convert(varchar(30), ss.selection_date, 103) 'selection_date'
				,ss.branch_code
				,ss.branch_name
				,ss.division_code
				,ss.division_name
				,ss.department_code
				,ss.department_name
				,ss.status
				,ss.remark
				--,detail.remark
				,detail.item_name
				,case
					 --when detail.quotation_amount < detail.asset_amount then '1'
					 when isnull(selection_detail.SELECTION_CODE, '') <> '' then '1'
					 else '0'
				 end										  'marketing_amount'
				,@rows_count								  'rowcount'
	from		supplier_selection ss
				outer apply
	(
		select	top 1
				remark
				,ssd.item_name
				,ssd.asset_amount
				,ssd.quotation_amount
				,ssd.total_amount
				,ssd.otr_amount
		from	dbo.supplier_selection_detail ssd
		where	ssd.selection_code = ss.code
	)							   detail
				outer apply
	(
		select	top 1
				ssd.selection_code
		from	dbo.supplier_selection_detail	   ssd
				inner join ifinbam.dbo.master_item mi on mi.code = ssd.item_code
		where	ssd.selection_code				   = ss.code
				and isnull(ssd.application_no, '') <> ''
				and ssd.total_amount			   > case
														 when mi.CATEGORY_TYPE = 'ASSET' then isnull(ssd.otr_amount, 0)
														 when mi.CATEGORY_TYPE = 'ACCESSORIES' then case
																										when ssd.item_code = 'DSFMIT240400001'
																											 and  isnull(ssd.accesories_amount, 0) = 0 then ssd.gps_amount
																										when ssd.item_code = 'DSFMIT240600002'
																											 and  isnull(ssd.accesories_amount, 0) = 0 then ssd.budget_amount
																										else isnull(ssd.accesories_amount,0)
																									end --then isnull(ssd.accesories_amount,0)
														 when mi.CATEGORY_TYPE = 'KAROSERI' then isnull(ssd.karoseri_amount, 0)
													 end
	) selection_detail
	where		ss.company_code = @p_company_code
				and ss.status	= case @p_status
									  when 'ALL' then ss.status
									  else @p_status
								  end
				and
				(
					ss.code like '%' + @p_keywords + '%'
					or	ss.quotation_code like '%' + @p_keywords + '%'
					or	convert(varchar(30), ss.selection_date, 103) like '%' + @p_keywords + '%'
					or	ss.branch_name like '%' + @p_keywords + '%'
					or	ss.status like '%' + @p_keywords + '%'
					or	ss.remark like '%' + @p_keywords + '%'
					or	detail.remark like '%' + @p_keywords + '%'
					or	detail.item_name like '%' + @p_keywords + '%'
					or	case
							when detail.quotation_amount < detail.asset_amount then '1'
							else '0'
						end like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ss.code
													 when 2 then ss.quotation_code
													 when 3 then ss.branch_name
													 when 4 then cast(selection_date as sql_variant)
													 when 5 then ss.remark
													 when 6 then ss.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then ss.code
													   when 2 then ss.quotation_code
													   when 3 then ss.branch_name
													   when 4 then cast(selection_date as sql_variant)
													   when 5 then ss.remark
													   when 6 then ss.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
