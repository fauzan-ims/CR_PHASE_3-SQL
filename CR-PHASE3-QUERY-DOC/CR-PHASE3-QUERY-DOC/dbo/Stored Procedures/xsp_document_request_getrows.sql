CREATE procedure dbo.xsp_document_request_getrows
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	,@p_branch_code		 nvarchar(50)
	,@p_request_status	 nvarchar(10)
	--,@p_request_type   nvarchar(20)
	,@p_request_location nvarchar(20)
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
	from	document_request dr
			left join dbo.document_main dm on (dr.document_code = dm.code)
			left join dbo.fixed_asset_main fam on (fam.asset_no = dr.asset_no)
	where	dr.branch_code			= case @p_branch_code
										  when 'ALL' then dr.branch_code
										  else @p_branch_code
									  end
			and dr.request_status	= case @p_request_status
										  when 'ALL' then dr.request_status
										  else @p_request_status
									  end
			and dr.request_location = case @p_request_location
										  when 'ALL' then dr.request_location
										  else @p_request_location
									  end
			and (
					dr.branch_name												like '%' + @p_keywords + '%'
					or	dr.asset_no												like '%' + @p_keywords + '%'
					or	fam.asset_name											like '%' + @p_keywords + '%'
					or	fam.reff_no_1											like '%' + @p_keywords + '%'
					or	fam.reff_no_2											like '%' + @p_keywords + '%'
					or	fam.reff_no_3											like '%' + @p_keywords + '%' 
					or	convert(varchar(30), dr.request_date, 103)				like '%' + @p_keywords + '%'
					or	dr.request_type											like '%' + @p_keywords + '%'
					or	dr.request_location										like '%' + @p_keywords + '%'
					or	case dr.request_location
							when 'BRANCH' then dr.request_to_branch_name
							when 'DEPARTMENT' then dr.request_from_dept_name
							when 'THIRD PARTY' then dr.request_to
							when 'CUSTOMER' then dr.request_to_client_name
						end														like '%' + @p_keywords + '%'
					or	dr.request_status										like '%' + @p_keywords + '%'
				) ;

	select		dr.code
				,dr.branch_name
				,convert(varchar(30), dr.request_date, 103) 'request_date'
				,dr.request_type
				,dr.request_location
				,case dr.request_location
					 when 'BRANCH' then dr.request_to_branch_name
					 when 'DEPARTMENT' then dr.request_from_dept_name
					 when 'THIRD PARTY' then dr.request_to
					 when 'CUSTOMER' then dr.request_to_client_name
				 end 'to'
				,dr.request_status
				,dm.document_type
				,dr.asset_no
				,fam.asset_name
				,fam.reff_no_1
				,fam.reff_no_2
				,fam.reff_no_3
				,@rows_count 'rowcount'
	from		document_request dr
				left join dbo.document_main dm on (dr.document_code = dm.code)
				left join dbo.fixed_asset_main fam on (fam.asset_no = dr.asset_no)
	where		dr.branch_code			= case @p_branch_code
											  when 'ALL' then dr.branch_code
											  else @p_branch_code
										  end
				and dr.request_status	= case @p_request_status
											  when 'ALL' then dr.request_status
											  else @p_request_status
										  end
				and dr.request_location = case @p_request_location
											  when 'ALL' then dr.request_location
											  else @p_request_location
										  end
				and (
						dr.branch_name												like '%' + @p_keywords + '%'
						or	dr.asset_no												like '%' + @p_keywords + '%'
						or	fam.asset_name											like '%' + @p_keywords + '%'
						or	fam.reff_no_1											like '%' + @p_keywords + '%'
						or	fam.reff_no_2											like '%' + @p_keywords + '%'
						or	fam.reff_no_3											like '%' + @p_keywords + '%' 
						or	convert(varchar(30), dr.request_date, 103)				like '%' + @p_keywords + '%'
						or	dr.request_type											like '%' + @p_keywords + '%'
						or	dr.request_location										like '%' + @p_keywords + '%'
						or	case dr.request_location
								when 'BRANCH' then dr.request_to_branch_name
								when 'DEPARTMENT' then dr.request_from_dept_name
								when 'THIRD PARTY' then dr.request_to
								when 'CUSTOMER' then dr.request_to_client_name
							end														like '%' + @p_keywords + '%'
						or	dr.request_status										like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then dr.branch_name
													 when 2 then case dr.request_location
																	 when 'BRANCH' then dr.request_to_branch_name
																	 when 'DEPARTMENT' then dr.request_to_dept_name
																	 when 'THIRD PARTY' then dr.request_to
																	 when 'CUSTOMER' then dr.request_to_client_name
																 end
													 when 3 then dr.asset_no		
													 when 4 then fam.reff_no_1
													 when 5 then dr.request_type
													 when 6 then cast(dr.request_date as sql_variant)
													 when 7 then dr.request_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then dr.branch_name
													 when 2 then case dr.request_location
																	 when 'BRANCH' then dr.request_to_branch_name
																	 when 'DEPARTMENT' then dr.request_to_dept_name
																	 when 'THIRD PARTY' then dr.request_to
																	 when 'CUSTOMER' then dr.request_to_client_name
																 end
													 when 3 then dr.asset_no		
													 when 4 then fam.reff_no_1
													 when 5 then dr.request_type
													 when 6 then cast(dr.request_date as sql_variant)
													 when 7 then dr.request_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
