CREATE PROCEDURE dbo.xsp_application_document_request_getrows_aditional
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_application_no	   nvarchar(50) = 'ALL'
	,@p_request_status nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_document_request adr
			inner join dbo.application_main am on (am.application_no = adr.application_no)
			inner join dbo.client_main cm on (cm.code				 = am.client_code)
			inner join dbo.sys_general_document sgd on (sgd.code	 = adr.document_code)
	where	adr.application_no		   = case @p_application_no
									 when 'ALL' then adr.application_no
									 else @p_application_no
								 end
			and request_status = @p_request_status
			and (
					adr.code										like '%' + @p_keywords + '%'
					or  adr.application_no							like '%' + @p_keywords + '%'
					or	cm.client_name								like '%' + @p_keywords + '%'
					or	convert(varchar(30), adr.request_date, 103)	like '%' + @p_keywords + '%'
					or	adr.mod_by									like '%' + @p_keywords + '%'
					or	sgd.document_name							like '%' + @p_keywords + '%'
					or	adr.request_status							like '%' + @p_keywords + '%'
				) ;

		select		adr.code
					,adr.application_no
					,cm.client_name
					,convert(varchar(30), adr.request_date, 103) 'request_date'
					,adr.mod_by	
					,sgd.document_name
					,adr.request_status
					,adr.paths
					,@rows_count 'rowcount'
		from		application_document_request adr
					inner join dbo.application_main am on (am.application_no = adr.application_no)
					inner join dbo.client_main cm on (cm.code				 = am.client_code)
					inner join dbo.sys_general_document sgd on (sgd.code	 = adr.document_code)
		where		adr.application_no		   = case @p_application_no
											 when 'ALL' then adr.application_no
											 else @p_application_no
										 end
					and request_status = @p_request_status
					and (
							adr.code										like '%' + @p_keywords + '%'
							or  adr.application_no							like '%' + @p_keywords + '%'
							or	cm.client_name								like '%' + @p_keywords + '%'
							or	convert(varchar(30), adr.request_date, 103)	like '%' + @p_keywords + '%'
							or	adr.mod_by									like '%' + @p_keywords + '%'
							or	sgd.document_name							like '%' + @p_keywords + '%'
							or	adr.request_status							like '%' + @p_keywords + '%'
						)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then adr.code
													when 2 then adr.application_no + cm.client_name
													when 3 then cast(adr.request_date as sql_variant)
													when 4 then adr.mod_by
													when 5 then sgd.document_name
													when 6 then adr.request_status
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then adr.code
														when 2 then adr.application_no + cm.client_name
														when 3 then cast(adr.request_date as sql_variant)
														when 4 then adr.mod_by
														when 5 then sgd.document_name
														when 6 then adr.request_status
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

