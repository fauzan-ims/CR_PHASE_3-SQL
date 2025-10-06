CREATE procedure dbo.xsp_monitoring_document_expired_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_branch_code	  nvarchar(50)	= 'ALL'
	,@p_document_code nvarchar(50)	= 'ALL'
	,@p_exp_date_from datetime
	,@p_exp_date_to	  datetime
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
	from	document_main dm
			left join dbo.fixed_asset_main fam on (fam.asset_no	 = dm.asset_no)
			left join dbo.document_detail dd on dd.document_code = dm.code
	where	dm.branch_code		 = case @p_branch_code
									   when 'ALL' then dm.branch_code
									   else @p_branch_code
								   end
			and dm.mutation_type <> 'RELEASE'
			and dm.document_type	 = case @p_document_code
										   when '' then dm.document_type
										   else @p_document_code
									   end
			and dd.expired_date
			between @p_exp_date_from and @p_exp_date_to
			and
			(
				dm.branch_name									like '%' + @p_keywords + '%'
				or	dm.asset_no									like '%' + @p_keywords + '%'
				or	dm.asset_name								like '%' + @p_keywords + '%' 
				or	fam.reff_no_1								like '%' + @p_keywords + '%'
				or	fam.reff_no_2								like '%' + @p_keywords + '%'
				or	fam.reff_no_3								like '%' + @p_keywords + '%'
				or	dm.document_type							like '%' + @p_keywords + '%'
				or	convert(varchar(30), dd.expired_date, 103)	like '%' + @p_keywords + '%'
				or	dm.document_status							like '%' + @p_keywords + '%'
			) ;

	select		dm.branch_name
				,dm.asset_no
				,dm.asset_name
				,fam.reff_no_1
				,fam.reff_no_2
				,fam.reff_no_3
				,dm.document_type
				,convert(varchar(30), dd.expired_date, 103) 'document_expired_date'
				,dm.document_status
				,@rows_count 'rowcount'
	from		document_main dm
				left join dbo.fixed_asset_main fam on (fam.asset_no	 = dm.asset_no)
				left join dbo.document_detail dd on dd.document_code = dm.code
	where		dm.branch_code		 = case @p_branch_code
										   when 'ALL' then dm.branch_code
										   else @p_branch_code
									   end
				and dm.mutation_type <> 'RELEASE'
				and dm.document_type	 = case @p_document_code
											   when '' then dm.document_type
											   else @p_document_code
										   end
				and dd.expired_date
				between @p_exp_date_from and @p_exp_date_to
				and
				(
					dm.branch_name									like '%' + @p_keywords + '%'
					or	dm.asset_no									like '%' + @p_keywords + '%'
					or	dm.asset_name								like '%' + @p_keywords + '%' 
					or	fam.reff_no_1								like '%' + @p_keywords + '%'
					or	fam.reff_no_2								like '%' + @p_keywords + '%'
					or	fam.reff_no_3								like '%' + @p_keywords + '%'
					or	dm.document_type							like '%' + @p_keywords + '%'
					or	convert(varchar(30), dd.expired_date, 103)	like '%' + @p_keywords + '%'
					or	dm.document_status							like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then dm.branch_name
													 when 2 then dm.asset_no
													 when 3 then fam.reff_no_1
													 when 4 then dm.document_type
													 when 5 then cast(dd.expired_date as sql_variant)
													 when 6 then dm.document_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then dm.branch_name
													   when 2 then dm.asset_no
													   when 3 then fam.reff_no_1
													   when 4 then dm.document_type
													   when 5 then cast(dd.expired_date as sql_variant)
													   when 6 then dm.document_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
