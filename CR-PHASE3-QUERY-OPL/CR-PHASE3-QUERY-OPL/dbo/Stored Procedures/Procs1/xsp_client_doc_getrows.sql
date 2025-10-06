CREATE PROCEDURE [dbo].[xsp_client_doc_getrows]
(
	@p_keywords	    nvarchar(50)
	,@p_pagenumber  int
	,@p_rowspage    int
	,@p_order_by    int
	,@p_sort_by	    nvarchar(5)
	,@p_client_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	client_doc cd
			inner join dbo.client_main cm on (cm.code			= cd.client_code)
			inner join dbo.sys_general_subcode sgs on (sgs.code = cd.doc_type_code)
	where	client_code = @p_client_code
			and (
					sgs.description								like '%' + @p_keywords + '%'
					or	cd.document_no							like '%' + @p_keywords + '%'
					or	cd.doc_status							like '%' + @p_keywords + '%'
					or	convert(varchar(30), cd.eff_date, 103)	like '%' + @p_keywords + '%'
					or	case cd.is_default
							when '1' then 'Yes'
							else 'No'
						end										like '%' + @p_keywords + '%'
				) ;

	select		id
				,sgs.description 'doc_type_desc'
				,cd.document_no							
				,cd.doc_status							
				,convert(varchar(30), cd.eff_date, 103)	'eff_date'
				,case cd.is_default
					when '1' then 'Yes'
					else 'No'
					end 'is_default'	
				,is_existing_client			
				,@rows_count 'rowcount'
	from		client_doc cd
				inner join dbo.client_main cm on (cm.code			= cd.client_code)
				inner join dbo.sys_general_subcode sgs on (sgs.code = cd.doc_type_code)
	where		client_code = @p_client_code
				and (
						sgs.description								like '%' + @p_keywords + '%'
						or	cd.document_no							like '%' + @p_keywords + '%'
						or	cd.doc_status							like '%' + @p_keywords + '%'
						or	convert(varchar(30), cd.eff_date, 103)	like '%' + @p_keywords + '%'
						or	case cd.is_default
								when '1' then 'Yes'
								else 'No'
							end										like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then sgs.description	
														when 2 then cd.document_no							
														when 3 then cd.doc_status							
														when 4 then cast(cd.eff_date as sql_variant)
														when 5 then cd.is_default
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then sgs.description	
														when 2 then cd.document_no							
														when 3 then cd.doc_status							
														when 4 then cast(cd.eff_date as sql_variant)
														when 5 then cd.is_default
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

