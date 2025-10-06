CREATE PROCEDURE dbo.xsp_ifinproc_interface_document_pending_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
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
	from	dbo.ifinproc_interface_document_pending
	where	branch_code = case @p_branch_code
									 when 'ALL' then branch_code
									 else @p_branch_code
								 end
	and		(
				branch_name									like '%' + @p_keywords + '%'
				or	document_type							like '%' + @p_keywords + '%'
				or	asset_no								like '%' + @p_keywords + '%'
				or	asset_name								like '%' + @p_keywords + '%'
				or	plat_no									like '%' + @p_keywords + '%'
				or	engine_no								like '%' + @p_keywords + '%'
				or	chasis_no								like '%' + @p_keywords + '%'
				or	vendor_name								like '%' + @p_keywords + '%'
				or	convert(varchar(30), entry_date, 103)	like '%' + @p_keywords + '%'
			) ;

	select		id
				,code
				,branch_code
				,branch_name
				,initial_branch_code
				,initial_branch_name
				,document_type
				,document_status
				,client_no
				,client_name
				,plafond_no
				,agreement_no
				,collateral_no
				,collateral_name
				,plafond_collateral_no
				,plafond_collateral_name
				,asset_no
				,asset_name
				,plat_no
				,chasis_no
				,engine_no
				,vendor_code
				,vendor_name
				,convert(varchar(30), entry_date, 103) 'entry_date'
				,@rows_count 'rowcount'
	from		dbo.ifinproc_interface_document_pending
	where		branch_code = case @p_branch_code
									 when 'ALL' then branch_code
									 else @p_branch_code
								 end
	and			(
					branch_name									like '%' + @p_keywords + '%'
					or	document_type							like '%' + @p_keywords + '%'
					or	asset_no								like '%' + @p_keywords + '%'
					or	asset_name								like '%' + @p_keywords + '%'
					or	plat_no									like '%' + @p_keywords + '%'
					or	engine_no								like '%' + @p_keywords + '%'
					or	chasis_no								like '%' + @p_keywords + '%'
					or	vendor_name								like '%' + @p_keywords + '%'
					or	convert(varchar(30), entry_date, 103)	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asset_no
													 when 2 then plat_no
													 when 3 then branch_name
													 when 4 then cast(entry_date as sql_variant)
													 when 5 then document_type
													 when 6 then vendor_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then asset_no
													   when 2 then plat_no
													   when 3 then branch_name
													   when 4 then cast(entry_date as sql_variant)
													   when 5 then document_type
													   when 6 then vendor_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
