CREATE PROCEDURE dbo.xsp_ams_interface_document_request_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_request_status	nvarchar(10)
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
	from	ams_interface_document_request
	where	request_branch_code	   = case @p_branch_code
									 when 'ALL' then request_branch_code
									 else @p_branch_code
								 end
			and request_status = case @p_request_status
									 when 'ALL' then request_status
									 else @p_request_status
								 end
	and		(
				code											 like '%' + @p_keywords + '%'
				or	request_branch_name							 like '%' + @p_keywords + '%'
				or	convert(varchar(30), request_date, 103)		 like '%' + @p_keywords + '%'
				or	remarks										 like '%' + @p_keywords + '%'
				or	request_status								 like '%' + @p_keywords + '%'
			) ;

	select		id
				,code
				,request_branch_code
				,request_branch_name
				,request_type
				,request_location
				,request_from
				,request_to
				,request_to_branch_code
				,request_to_branch_name
				,request_to_agreement_no
				,request_to_client_name
				,request_from_dept_code
				,request_from_dept_name
				,request_to_dept_code
				,request_to_dept_name
				,request_to_thirdparty_type
				,agreement_no
				,collateral_no
				,asset_no
				,request_by
				,request_status
				,convert(varchar(30), request_date, 103) 'request_date'
				,remarks
				,document_code
				,process_date
				,process_reff_no
				,process_reff_name
				,job_status
				,failed_remark
				,@rows_count 'rowcount'
	from		ams_interface_document_request
	where	request_branch_code	   = case @p_branch_code
									 when 'ALL' then request_branch_code
									 else @p_branch_code
								 end
			and request_status = case @p_request_status
									 when 'ALL' then request_status
									 else @p_request_status
								 end	
	and		(
					code											 like '%' + @p_keywords + '%'
					or	request_branch_name							 like '%' + @p_keywords + '%'
					or	convert(varchar(30), request_date, 103)		 like '%' + @p_keywords + '%'
					or	remarks										 like '%' + @p_keywords + '%'
					or	request_status								 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then request_branch_name
													 when 3 then cast(request_date	as sql_variant)
													 when 4 then remarks
													 when 5 then request_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then code
														when 2 then request_branch_name
														when 3 then cast(request_date	as sql_variant)
														when 4 then remarks
														when 5 then request_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
