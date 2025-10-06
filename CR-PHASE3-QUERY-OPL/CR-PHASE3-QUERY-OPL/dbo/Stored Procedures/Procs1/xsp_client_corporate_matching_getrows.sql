CREATE PROCEDURE dbo.xsp_client_corporate_matching_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	----
	,@p_document_no	nvarchar(50) = ''
	,@p_full_name	nvarchar(250)
	,@p_est_date	DATETIME = null
)
as
BEGIN

	declare @rows_count int = 0  
			

	declare @checkingclient table
	(
		client_code				nvarchar(50)
		,client_type			nvarchar(50)
		,corporate_status_desc	nvarchar(20)
		,full_name				nvarchar(250)
		,est_date				datetime
		,tax_file_no			nvarchar(50)
		,check_status			nvarchar(50)
	)

	-- DATA CLIENT
	INSERT INTO	@checkingclient
	(
	    client_code,
	    client_type,
	    corporate_status_desc,
	    full_name,
	    est_date,
	    tax_file_no,
	    check_status
	)
	select cci.CLIENT_CODE
			,'CORPORATE'
			,sgs.description 'corporate_status_desc'	
			,cci.full_name	
			,cci.EST_DATE
			,cd.DOCUMENT_NO
			,'CLEAR'
	from client_corporate_info cci
	inner join dbo.client_main cm on (cm.code = cci.client_code and  cm.is_validate = '1')
	left join client_doc cd on cd.client_code = cci.client_code and cd.doc_type_code = 'TAXID'
	left join sys_general_subcode sgs on (sgs.code = cci.corporate_status_code)
	where	( cd.document_no	= @p_document_no and est_date	 = ISNULL(@p_est_date,est_date) )
			or ( full_name like '%' + cast(@p_full_name as nvarchar(10)) + '%' and est_date = ISNULL(@p_est_date,est_date) )
			or ( cd.document_no	= @p_document_no )
			or ( full_name like '%' + cast(@p_full_name as nvarchar(10)) + '%') 
			
	
	-- DATA BLACKKLIST
	INSERT INTO	@checkingclient
	(
	    client_code,
	    client_type,
	    corporate_status_desc,
	    full_name,
	    est_date,
	    tax_file_no,
	    check_status
	)
	select 'external'
			,'corporate'
			,'none'
			,corporate_name
			,corporate_est_date
			,corporate_tax_file_no
			,case	when	is_active = '0' then 'release'
					else	blacklist_type
			end 'blacklist_type'
  from dbo.client_blacklist
	where client_type = 'corporate'
	and	 (( corporate_name like '%' + cast(@p_full_name as nvarchar(10)) + '%')
	or	 ( corporate_tax_file_no like '%' + @p_document_no+ '%')
		)


	select	@rows_count = count(1)
	from	@checkingclient 
	where	 (
				client_code								like '%' + @p_keywords + '%'
				or	client_type							like '%' + @p_keywords + '%'
				or	corporate_status_desc				like '%' + @p_keywords + '%'
				or	full_name							like '%' + @p_keywords + '%'
				or	convert(varchar(30), est_date, 103)	like '%' + @p_keywords + '%'
			) ;
			 
		select		client_code
					,client_type	
					,corporate_status_desc	
					,full_name	
					,convert(varchar(30), est_date, 103)'est_date'
					,tax_file_no 'id_no'
					,check_status
					,@rows_count 'rowcount'
		from	@checkingclient 
		WHERE	 (
					client_code								like '%' + @p_keywords + '%'
					or	full_name							like '%' + @p_keywords + '%'
					or	tax_file_no							like '%' + @p_keywords + '%'
					or	corporate_status_desc				like '%' + @p_keywords + '%'
					or	convert(varchar(30), est_date, 103)	like '%' + @p_keywords + '%'
					or	check_status						like '%' + @p_keywords + '%'
				)  
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then client_code	
													when 2 then full_name							
													when 3 then tax_file_no							
													when 4 then corporate_status_desc							
													when 5 then cast(est_date as sql_variant)	
													when 6 then check_status
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then client_code	
													when 2 then full_name							
													when 3 then tax_file_no							
													when 4 then corporate_status_desc							
													when 5 then cast(est_date as sql_variant)	
													when 6 then check_status
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

