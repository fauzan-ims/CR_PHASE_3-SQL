CREATE PROCEDURE dbo.xsp_fin_interface_cashier_received_request_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_request_status  nvarchar(10)
	,@p_status			nvarchar(10) = 'ALL'
 	,@p_job_status		nvarchar(10) = 'ALL'
)
as
begin
	declare @rows_count int = 0 ;

	if exists 	( 		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code	)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	fin_interface_cashier_received_request crr
	where	isnull(manual_upload_status, '') = case @p_status
												   when 'ALL' then isnull(manual_upload_status, '')
												   else @p_status
											   end
			and crr.branch_code		= case @p_branch_code
										  when 'ALL' then crr.branch_code
										  else @p_branch_code
									  end
			and crr.request_status = case @p_request_status
										  when 'ALL' then crr.request_status
										  else @p_request_status
									  end
			and  job_status = case @p_job_status
										when 'ALL' then job_status
										else @p_job_status
								   end
			and (
					crr.code									like '%' + @p_keywords + '%'
					or	crr.doc_ref_code						like '%' + @p_keywords + '%'
					or	crr.doc_ref_name						like '%' + @p_keywords + '%'
					or	crr.branch_name							like '%' + @p_keywords + '%'
					or	convert(varchar(30), request_date, 103) like '%' + @p_keywords + '%'
					or	convert(varchar(30), crr.mod_date, 103) like '%' + @p_keywords + '%'
					or	request_remarks							like '%' + @p_keywords + '%'
					or	request_currency_code					like '%' + @p_keywords + '%'
					or	request_amount							like '%' + @p_keywords + '%'
					or	request_status							like '%' + @p_keywords + '%'
					or	crr.job_status							like '%' + @p_keywords + '%'
				) ;

	select		id
				,crr.code
				,crr.doc_ref_code
				,crr.doc_ref_name
				,crr.branch_name
				,convert(varchar(30), request_date, 103) 'request_date'
				,convert(varchar(30), crr.mod_date, 103) 'mod_date'
				,request_remarks
				,request_currency_code
				,request_amount
				,request_status
				,crr.job_status
				,@rows_count 'rowcount'
	from		fin_interface_cashier_received_request crr
	where		isnull(manual_upload_status, '') = case @p_status
													   when 'ALL' then isnull(manual_upload_status, '')
													   else @p_status
												   end
				and crr.branch_code		= case @p_branch_code
											  when 'ALL' then crr.branch_code
											  else @p_branch_code
										  end
				and crr.request_status = case @p_request_status
											  when 'ALL' then crr.request_status
											  else @p_request_status
										  end
				and  job_status = case @p_job_status
										when 'ALL' then job_status
										else @p_job_status
								   end
				and (
						crr.code									like '%' + @p_keywords + '%'
						or	crr.doc_ref_code						like '%' + @p_keywords + '%'
						or	crr.doc_ref_name						like '%' + @p_keywords + '%'
						or	crr.branch_name							like '%' + @p_keywords + '%'
						or	convert(varchar(30), request_date, 103) like '%' + @p_keywords + '%'
						or	convert(varchar(30), crr.mod_date, 103) like '%' + @p_keywords + '%'
						or	request_remarks							like '%' + @p_keywords + '%'
						or	request_currency_code					like '%' + @p_keywords + '%'
						or	request_amount							like '%' + @p_keywords + '%'
						or	request_status							like '%' + @p_keywords + '%'
						or	crr.job_status							like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then crr.code
													 when 2 then crr.branch_name
													 when 3 then cast(request_date as sql_variant)
													 when 4 then crr.doc_ref_code + crr.doc_ref_name
													 when 5 then request_remarks
													 when 6 then cast(crr.request_amount as sql_variant)
													 when 7 then cast(crr.mod_date as sql_variant)
													 when 8 then request_status
													 when 9 then crr.job_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then crr.code
													 when 2 then crr.branch_name
													 when 3 then cast(request_date as sql_variant)
													 when 4 then crr.doc_ref_code + crr.doc_ref_name
													 when 5 then request_remarks
													 when 6 then cast(crr.request_amount as sql_variant)
													 when 7 then cast(crr.mod_date as sql_variant)
													 when 8 then request_status
													 when 9 then crr.job_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
