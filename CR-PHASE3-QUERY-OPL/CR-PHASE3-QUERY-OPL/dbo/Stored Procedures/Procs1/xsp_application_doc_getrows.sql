CREATE PROCEDURE dbo.xsp_application_doc_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_application_no nvarchar(50)
	,@p_is_tbo		   nvarchar(1) = '0'
)
as
begin
	declare @rows_count int = 0 ;
	
	if (@p_is_tbo = '0')
	begin
		select	@rows_count = count(1)
		from	application_doc ad
				inner join dbo.sys_general_document sgd on (sgd.code = ad.document_code)
		where	application_no = @p_application_no
				and (
						sgd.document_name								like '%' + @p_keywords + '%'
						or	ad.filename									like '%' + @p_keywords + '%'
						or	convert(varchar(30), ad.expired_date, 103)	like '%' + @p_keywords + '%'
						or	convert(varchar(30), ad.promise_date, 103)	like '%' + @p_keywords + '%'
						or	ad.expired_date								like '%' + @p_keywords + '%'
						or	ad.promise_date								like '%' + @p_keywords + '%'
						or	case ad.is_required
								when '1' then '*'
								else ''
							end											like '%' + @p_keywords + '%'
					) ;

		select		id
					,sgd.document_name
					,ad.filename
					,ad.paths
					,convert(varchar(30), ad.expired_date, 103) 'expired_date'
					,convert(varchar(30), ad.promise_date, 103) 'promise_date'
					,case ad.is_required
							when '1' then '*'
							else ''
						end 'is_required'
					,ad.waive_status
					,ad.is_valid
					,ad.remarks
					,ad.is_received
					,@rows_count 'rowcount'
		from		application_doc ad
					inner join dbo.sys_general_document sgd on (sgd.code = ad.document_code)
		where		application_no = @p_application_no
					and (
							sgd.document_name								like '%' + @p_keywords + '%'
							or	ad.filename									like '%' + @p_keywords + '%'
							or	ad.remarks									like '%' + @p_keywords + '%'
							or	convert(varchar(30), ad.expired_date, 103)	like '%' + @p_keywords + '%'
							or	convert(varchar(30), ad.promise_date, 103)	like '%' + @p_keywords + '%'
							or	case ad.is_required
									when '1' then '*'
									else ''
								end											like '%' + @p_keywords + '%'
						)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
															when 1 then sgd.document_name
															when 2 then ad.remarks
															when 3 then cast(ad.expired_date as sql_variant)
															when 4 then cast(ad.promise_date as sql_variant)
														end
					end asc
					,case
							when @p_sort_by = 'desc' then case @p_order_by
															when 1 then sgd.document_name
															when 2 then ad.remarks
															when 3 then cast(ad.expired_date as sql_variant)
															when 4 then cast(ad.promise_date as sql_variant)
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;   
	end
	else
	begin
		select	@rows_count = count(1)
		from	application_doc ad
				inner join dbo.sys_general_document sgd on (sgd.code = ad.document_code)
		where	application_no = @p_application_no
				and ad.promise_date is not null
				and (
						sgd.document_name								like '%' + @p_keywords + '%'
						or	ad.filename									like '%' + @p_keywords + '%'
						or	ad.remarks									like '%' + @p_keywords + '%'
						or	convert(varchar(30), ad.expired_date, 103)	like '%' + @p_keywords + '%'
						or	convert(varchar(30), ad.promise_date, 103)	like '%' + @p_keywords + '%'
						or	ad.expired_date								like '%' + @p_keywords + '%'
						or	ad.promise_date								like '%' + @p_keywords + '%'
						or	case ad.is_required
								when '1' then '*'
								else ''
							end											like '%' + @p_keywords + '%'
					) ;

		select		id
					,sgd.document_name
					,ad.filename
					,ad.paths
					,convert(varchar(30), ad.expired_date, 103) 'expired_date'
					,convert(varchar(30), ad.promise_date, 103) 'promise_date'
					,case ad.is_required
							when '1' then '*'
							else ''
						end 'is_required'
					,isnull(ad.waive_status, 'HOLD') 'waive_status'
					,ad.is_valid
					,ad.remarks
					,ad.is_received
					,@rows_count 'rowcount'
		from		application_doc ad
					inner join dbo.sys_general_document sgd on (sgd.code = ad.document_code)
		where		application_no = @p_application_no
					and ad.promise_date is not null
					and (
							sgd.document_name								like '%' + @p_keywords + '%'
							or	ad.remarks									like '%' + @p_keywords + '%'
							or	ad.filename									like '%' + @p_keywords + '%'
							or	convert(varchar(30), ad.expired_date, 103)	like '%' + @p_keywords + '%'
							or	convert(varchar(30), ad.promise_date, 103)	like '%' + @p_keywords + '%'
							or	case ad.is_required
									when '1' then '*'
									else ''
								end											like '%' + @p_keywords + '%'
						)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
															when 1 then sgd.document_name
															when 2 then ad.remarks
															when 3 then cast(ad.expired_date as sql_variant)
															when 4 then cast(ad.promise_date as sql_variant)
														
														end
					end asc
					,case
							when @p_sort_by = 'desc' then case @p_order_by
															when 1 then sgd.document_name
															when 2 then ad.remarks
															when 3 then cast(ad.expired_date as sql_variant)
															when 4 then cast(ad.promise_date as sql_variant)
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
	end
end ;

