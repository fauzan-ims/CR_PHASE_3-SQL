CREATE PROCEDURE dbo.xsp_asset_upload_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
	,@p_status			nvarchar(50)
	,@p_asset_type		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	asset_upload au
			inner join dbo.sys_company_user_main scum on (scum.code = au.cre_by) and (scum.company_code = au.company_code)
			inner join dbo.sys_general_subcode sgs on (sgs.code = au.type_code and au.company_code = sgs.company_code)
	where	au.company_code = @p_company_code
	and		au.status_upload = case @p_status
										when 'ALL' then au.status_upload
										else @p_status
									end
	and		au.type_code = @p_asset_type
	and			(
					upload_no				 like '%' + @p_keywords + '%'
					or  au.file_name		 like '%' + @p_keywords + '%'
					or	au.status_upload	 like '%' + @p_keywords + '%'
					or	sgs.description		 like '%' + @p_keywords + '%'
					or	au.cre_by			 like '%' + @p_keywords + '%'
					or	au.cre_date			 like '%' + @p_keywords + '%'
				) ;

	select		id
				,au.upload_no
				,au.file_name
				,au.status_upload
				,au.type_code
				,sgs.description 'type_name'
				,convert(nvarchar(30), au.cre_date ,103) 'cre_date'
				,au.cre_by
				,scum.name
				,@rows_count 'rowcount'
	from	asset_upload au
			inner join dbo.sys_company_user_main scum on (scum.code = au.cre_by) and (scum.company_code = au.company_code)
			inner join dbo.sys_general_subcode sgs on (sgs.code = au.type_code and au.company_code = sgs.company_code)
	where	au.company_code = @p_company_code
	and		au.status_upload = case @p_status
										when 'ALL' then au.status_upload
										else @p_status
									end
	and		au.type_code = @p_asset_type
	and			(
					upload_no				 like '%' + @p_keywords + '%'
					or  au.file_name		 like '%' + @p_keywords + '%'
					or	au.status_upload	 like '%' + @p_keywords + '%'
					or	sgs.description		 like '%' + @p_keywords + '%'
					or	au.cre_by			 like '%' + @p_keywords + '%'
					or	au.cre_date			 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then au.upload_no
													 when 2 then au.file_name
													 when 3 then sgs.description
													 when 4 then cast(au.cre_date as sql_variant)
													 when 5 then scum.name
													 when 6 then au.status_upload
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													  when 1 then upload_no
													 when 2 then au.file_name
													 when 3 then sgs.description
													 when 4 then cast(au.cre_date as sql_variant)
													 when 5 then scum.name
													 when 6 then au.status_upload
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
