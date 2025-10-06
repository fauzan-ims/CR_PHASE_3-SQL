CREATE PROCEDURE dbo.xsp_application_asset_doc_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_asset_no	  nvarchar(50)
	,@p_is_tbo		  nvarchar(1) = '0'
)
as
begin
	declare @rows_count int = 0 ;
	if (@p_is_tbo = '0')
	begin
		select	@rows_count = count(1)
		from	application_asset_doc pcd
				inner join dbo.sys_general_document sgd on (sgd.code = pcd.document_code)
		where	pcd.asset_no = @p_asset_no
				and (
						sgd.document_name								like '%' + @p_keywords + '%'
						or	pcd.filename								like '%' + @p_keywords + '%'
						or	convert(varchar(30), pcd.expired_date, 103)	like '%' + @p_keywords + '%'
						or	convert(varchar(30), pcd.promise_date, 103)	like '%' + @p_keywords + '%'
						or	case pcd.is_required
								when '1' then '*'
								else ''
							end											like '%' + @p_keywords + '%'
					) ;

		select		pcd.id
					,sgd.document_name
					,pcd.filename	
					,pcd.paths			
					,convert(varchar(30), pcd.expired_date, 103) 'expired_date'			
					,convert(varchar(30), pcd.promise_date, 103) 'promise_date'			
					,case pcd.is_required
						when '1' then '*'
						else ''
						end 'is_required'			
					,@rows_count 'rowcount'
		from		application_asset_doc pcd
					inner join dbo.sys_general_document sgd on (sgd.code = pcd.document_code)
		where		pcd.asset_no = @p_asset_no
					and (
							sgd.document_name								like '%' + @p_keywords + '%'
							or	pcd.filename								like '%' + @p_keywords + '%'
							or	convert(varchar(30), pcd.expired_date, 103)	like '%' + @p_keywords + '%'
							or	convert(varchar(30), pcd.promise_date, 103)	like '%' + @p_keywords + '%'
							or	case pcd.is_required
									when '1' then '*'
									else ''
								end											like '%' + @p_keywords + '%'
						)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
															when 1 then sgd.document_name
															when 2 then pcd.filename		
															when 3 then cast(pcd.expired_date as sql_variant)
															when 4 then cast(pcd.promise_date as sql_variant)
															
														end
					end asc
					,case
							when @p_sort_by = 'desc' then case @p_order_by
															when 1 then sgd.document_name
															when 2 then pcd.filename		
															when 3 then cast(pcd.expired_date as sql_variant)
															when 4 then cast(pcd.promise_date as sql_variant)
																	
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
	end
	else
	begin
		select	@rows_count = count(1)
		from	application_asset_doc pcd
				inner join dbo.sys_general_document sgd on (sgd.code = pcd.document_code)
		where	pcd.asset_no = @p_asset_no
				and pcd.promise_date is not null
				and (
						sgd.document_name								like '%' + @p_keywords + '%'
						or	pcd.filename								like '%' + @p_keywords + '%'
						or	convert(varchar(30), pcd.expired_date, 103)	like '%' + @p_keywords + '%'
						or	convert(varchar(30), pcd.promise_date, 103)	like '%' + @p_keywords + '%'
						or	case pcd.is_required
								when '1' then '*'
								else ''
							end											like '%' + @p_keywords + '%'
					) ;

		select		pcd.id
					,sgd.document_name
					,pcd.filename	
					,pcd.paths			
					,convert(varchar(30), pcd.expired_date, 103) 'expired_date'			
					,convert(varchar(30), pcd.promise_date, 103) 'promise_date'			
					,case pcd.is_required
						when '1' then '*'
						else ''
						end 'is_required'			
					,@rows_count 'rowcount'
		from		application_asset_doc pcd
					inner join dbo.sys_general_document sgd on (sgd.code = pcd.document_code)
		where		pcd.asset_no = @p_asset_no
					and pcd.promise_date is not null
					and (
							sgd.document_name								like '%' + @p_keywords + '%'
							or	pcd.filename								like '%' + @p_keywords + '%'
							or	convert(varchar(30), pcd.expired_date, 103)	like '%' + @p_keywords + '%'
							or	convert(varchar(30), pcd.promise_date, 103)	like '%' + @p_keywords + '%'
							or	case pcd.is_required
									when '1' then '*'
									else ''
								end											like '%' + @p_keywords + '%'
						)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
															when 1 then sgd.document_name
															when 2 then cast(pcd.expired_date as sql_variant)
															when 3 then cast(pcd.promise_date as sql_variant)
															when 4 then pcd.filename		
														end
					end asc
					,case
							when @p_sort_by = 'desc' then case @p_order_by
															when 1 then sgd.document_name
															when 2 then cast(pcd.expired_date as sql_variant)
															when 3 then cast(pcd.promise_date as sql_variant)
															when 4 then pcd.filename		
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
	end
end ;

