CREATE PROCEDURE dbo.xsp_application_main_lookup_for_report_application
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_main am
			inner join dbo.client_main cm on (cm.code = am.client_code)
	where	(
				application_external_no like '%' + @p_keywords + '%'
				or	client_name			like '%' + @p_keywords + '%'
			) ;
		select	am.application_no
				,am.application_external_no
				,cm.client_name
				,am.agreement_no
				,am.agreement_external_no
				,@rows_count 'rowcount'
		from	application_main am
				inner join dbo.client_main cm on (cm.code = am.client_code)
		where	am.agreement_no is not null
		and		(
					application_external_no like '%' + @p_keywords + '%'
					or	client_name			like '%' + @p_keywords + '%'
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

