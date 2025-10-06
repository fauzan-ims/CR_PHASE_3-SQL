CREATE PROCEDURE dbo.xsp_doc_interface_document_request_getrows
(
	@p_keywords	       nvarchar(50)
	,@p_pagenumber     int
	,@p_rowspage       int
	,@p_order_by       int
	,@p_sort_by	       nvarchar(5)
	,@p_branch_code	   nvarchar(50)
	,@p_request_status nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		SELECT	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	dbo.doc_interface_document_request didr
			--left join dbo.agreement_main am on (am.agreement_no = didr.agreement_no)
	where	didr.request_branch_code = case @p_branch_code
										 when 'ALL' then didr.request_branch_code
										 else @p_branch_code
									   end
			and request_status = case @p_request_status
									 when 'ALL' then request_status
									 else @p_request_status
								 end
			and (
					didr.code										 like '%' + @p_keywords + '%'
					--or	am.agreement_external_no					 like '%' + @p_keywords + '%'
					--or	am.client_name								 like '%' + @p_keywords + '%'
					or	didr.request_branch_code					 like '%' + @p_keywords + '%'
					or	didr.request_branch_name					 like '%' + @p_keywords + '%'
					or	convert(varchar(30), didr.request_date, 103) like '%' + @p_keywords + '%'
					or	didr.remarks								 like '%' + @p_keywords + '%'
					or	didr.request_status							 like '%' + @p_keywords + '%'
			) ;

		select		didr.code
					--,am.agreement_external_no					
					--,am.client_name		
					,didr.request_branch_code						
					,didr.request_branch_name					
					,convert(varchar(30), didr.request_date, 103) 'request_date'
					,didr.remarks								
					,didr.request_status
					,@rows_count 'rowcount'
		from		doc_interface_document_request didr
					--left join dbo.agreement_main am on (am.agreement_no = didr.agreement_no)
		where		didr.request_branch_code = case @p_branch_code
										 when 'ALL' then didr.request_branch_code
										 else @p_branch_code
									   end
			and request_status = case @p_request_status
									 when 'ALL' then request_status
									 else @p_request_status
								 end
			and (
						didr.code										 like '%' + @p_keywords + '%'
						--or	am.agreement_external_no					 like '%' + @p_keywords + '%'
						--or	am.client_name								 like '%' + @p_keywords + '%'
						or	didr.request_branch_code					 like '%' + @p_keywords + '%'
						or	didr.request_branch_name					 like '%' + @p_keywords + '%'
						or	convert(varchar(30), didr.request_date, 103) like '%' + @p_keywords + '%'
						or	didr.remarks								 like '%' + @p_keywords + '%'
						or	didr.request_status							 like '%' + @p_keywords + '%'
					)
		order by case	
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then didr.code
													when 2 then didr.request_branch_code + didr.request_branch_name
													--when 3 then am.agreement_external_no + am.client_name
													when 4 then cast(didr.request_date	as sql_variant)
													when 5 then didr.remarks
													when 6 then didr.request_status
												  end
					end asc,  
					case when @p_sort_by = 'desc' then case @p_order_by
															when 1 then didr.code
															when 2 then didr.request_branch_code + didr.request_branch_name
															--when 3 then am.agreement_external_no + am.client_name
															when 4 then cast(didr.request_date	as sql_variant)
															when 5 then didr.remarks
															when 6 then didr.request_status
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
