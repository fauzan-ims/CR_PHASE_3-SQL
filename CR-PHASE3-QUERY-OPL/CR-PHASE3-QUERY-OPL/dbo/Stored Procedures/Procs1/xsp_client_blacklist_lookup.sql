CREATE PROCEDURE dbo.xsp_client_blacklist_lookup
(
	@p_keywords	    nvarchar(50)
	,@p_pagenumber  int
	,@p_rowspage    int
	,@p_order_by    int
	,@p_sort_by	    nvarchar(5)
	,@p_client_type nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	client_blacklist cb
			left join dbo.sys_general_subcode sgs on (sgs.code = cb.personal_doc_type_code)
	where	client_type = @p_client_type
			and cb.is_active = '1'
			and (
					isnull(cb.personal_name,cb.corporate_name)	like '%' + @p_keywords + '%'
					or	cb.client_type							like '%' + @p_keywords + '%'
					or	cb.blacklist_type						like '%' + @p_keywords + '%'
				) ;
				 
		select		cb.code
					,cb.client_type
					,cb.blacklist_type	
					,isnull(cb.personal_name,cb.corporate_name) 'client_name'
					,cb.personal_name
					,cb.personal_alias_name
					,cb.personal_nationality_type_code
					,cb.personal_doc_type_code
					,personal_dob
					,cb.personal_mother_maiden_name
					,cb.personal_id_no		
					,cb.corporate_name
					,cb.corporate_tax_file_no	
					,cb.corporate_est_date
					,sgs.description 'personal_doc_type_desc'
					,@rows_count 'rowcount'
		from		client_blacklist cb
					left join dbo.sys_general_subcode sgs on (sgs.code = cb.personal_doc_type_code)
		where		client_type = @p_client_type
					and cb.is_active = '1'
					and (
							isnull(cb.personal_name,cb.corporate_name)	like '%' + @p_keywords + '%'
							or	cb.client_type							like '%' + @p_keywords + '%'
							or	cb.blacklist_type						like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then isnull(cb.personal_name,cb.corporate_name)
													when 2 then cb.client_type
													when 3 then cb.blacklist_type 
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then isnull(cb.personal_name,cb.corporate_name)
													when 2 then cb.client_type
													when 3 then cb.blacklist_type 
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;



