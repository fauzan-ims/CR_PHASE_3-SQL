CREATE PROCEDURE dbo.xsp_eproc_interface_asset_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_branch_code	  nvarchar(50)
	,@p_status		  nvarchar(20)
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	eproc_interface_asset ass
			left join ifinams.dbo.sys_general_subcode sgs on (ass.type_code			 = sgs.code)
	where	ass.branch_code		  = case @p_branch_code
										when 'ALL' then ass.branch_code
										else @p_branch_code
									end
			and ass.job_status	  = case @p_status
										when 'ALL' then ass.job_status
										else @p_status
									end
			and (
					ass.code										like '%' + @p_keywords + '%'
					or	ass.barcode									like '%' + @p_keywords + '%'
					or	ass.item_code								like '%' + @p_keywords + '%'
					or	ass.item_name								like '%' + @p_keywords + '%'
					or	sgs.description								like '%' + @p_keywords + '%'
					or	ass.branch_name								like '%' + @p_keywords + '%'
					or	ass.job_status								like '%' + @p_keywords + '%'
					or	convert(varchar(30), purchase_date, 103)	like '%' + @p_keywords + '%'
				) ;

	select		ass.code
				,ass.company_code
				,item_code
				,item_name
				,barcode
				,status
				,po_no
				,requestor_code
				,requestor_name
				,vendor_code
				,vendor_name
				,type_code
				,sgs.description 'description_type'
				,category_code
				,convert(varchar(30), purchase_date, 103) 'purchase_date'
				,purchase_price
				,invoice_no
				,invoice_date
				,original_price
				,ass.branch_code
				,ass.branch_name
				,division_code
				,division_name
				,department_code
				,department_name
				,ass.job_status
				,@rows_count 'rowcount'
	from		eproc_interface_asset ass
				left join ifinams.dbo.sys_general_subcode sgs on (ass.type_code			 = sgs.code)
	where		ass.branch_code		  = case @p_branch_code
											when 'ALL' then ass.branch_code
											else @p_branch_code
										end
				and ass.job_status	  = case @p_status
										when 'ALL' then ass.job_status
										else @p_status
									end
				and (
						ass.code										like '%' + @p_keywords + '%'
						or	ass.barcode									like '%' + @p_keywords + '%'
						or	ass.item_code								like '%' + @p_keywords + '%'
						or	ass.item_name								like '%' + @p_keywords + '%'
						or	sgs.description								like '%' + @p_keywords + '%'
						or	ass.branch_name								like '%' + @p_keywords + '%'
						or	ass.job_status								like '%' + @p_keywords + '%'
						or	convert(varchar(30), purchase_date, 103)	like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ass.code
													 when 2 then ass.branch_name
													 when 3 then cast(ass.purchase_date as sql_variant)
													 when 4 then ass.item_code + ass.item_name
													 when 5 then sgs.description
													 when 6 then ass.job_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ass.code
													 when 2 then ass.branch_name
													 when 3 then cast(ass.purchase_date as sql_variant)
													 when 4 then ass.item_code + ass.item_name
													 when 5 then sgs.description
													 when 6 then ass.job_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
