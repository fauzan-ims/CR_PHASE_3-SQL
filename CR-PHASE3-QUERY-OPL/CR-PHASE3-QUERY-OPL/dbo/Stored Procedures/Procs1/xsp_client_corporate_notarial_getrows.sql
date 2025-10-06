CREATE PROCEDURE dbo.xsp_client_corporate_notarial_getrows
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
	from	client_corporate_notarial ccn
			inner join dbo.sys_general_subcode sgs on (sgs.code = ccn.notarial_document_code)
	where	client_code = @p_client_code
			and (
					sgs.description										like '%' + @p_keywords + '%'
					or	ccn.document_no									like '%' + @p_keywords + '%'
					or	convert(varchar(30), ccn.document_date, 103)	like '%' + @p_keywords + '%'
					or	ccn.modal_dasar									like '%' + @p_keywords + '%'
					or	ccn.modal_setor									like '%' + @p_keywords + '%'
				) ;
				 
		select		ccn.code
					,sgs.description 'notarial_document'
					,ccn.document_no		
					,convert(varchar(30), ccn.document_date, 103) 'document_date'
					,ccn.modal_dasar		
					,ccn.modal_setor		
					,@rows_count 'rowcount'
		from		client_corporate_notarial ccn
					inner join dbo.sys_general_subcode sgs on (sgs.code = ccn.notarial_document_code)
		where		client_code = @p_client_code
					and (
							sgs.description										like '%' + @p_keywords + '%'
							or	ccn.document_no									like '%' + @p_keywords + '%'
							or	convert(varchar(30), ccn.document_date, 103)	like '%' + @p_keywords + '%'
							or	ccn.modal_dasar									like '%' + @p_keywords + '%'
							or	ccn.modal_setor									like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then sgs.description
													when 2 then ccn.document_no		
													when 3 then convert(varchar(30), ccn.document_date, 103)	
													when 4 then try_cast(ccn.modal_dasar as nvarchar(20))		
													when 5 then try_cast(ccn.modal_setor as nvarchar(20))
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then sgs.description
													when 2 then ccn.document_no		
													when 3 then convert(varchar(30), ccn.document_date, 103)	
													when 4 then try_cast(ccn.modal_dasar as nvarchar(20))		
													when 5 then try_cast(ccn.modal_setor as nvarchar(20))
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

