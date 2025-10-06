CREATE PROCEDURE dbo.xsp_application_main_lookup_for_application_document_request
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.application_main dm
			inner join dbo.client_main cm on (cm.code = dm.client_code)
			outer apply ( select top 1 request_status from dbo.application_document_request where request_status = 'REQUEST' and application_no = dm.application_no) ddr
	where	ddr.request_status is not null
			and (
					dm.application_external_no			like '%' + @p_keywords + '%'
					or client_name					like '%' + @p_keywords + '%'
				) ;

 
		select		dm.application_no
					,dm.application_external_no
					,client_name
					,@rows_count 'rowcount'
		from		dbo.application_main dm
					inner join dbo.client_main cm on (cm.code = dm.client_code)
					outer apply ( select top 1 request_status from dbo.application_document_request where request_status = 'REQUEST' and application_no = dm.application_no) ddr
		where		ddr.request_status is not null
					and (
							dm.application_external_no			like '%' + @p_keywords + '%'
							or client_name					like '%' + @p_keywords + '%'
						)  
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then application_external_no
													when 2 then client_name
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then application_external_no
													when 2 then client_name
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;


