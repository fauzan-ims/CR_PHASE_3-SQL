CREATE PROCEDURE [dbo].[xsp_realization_doc_getrows]
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_realization_code	nvarchar(50)
)
AS
BEGIN
	DECLARE @rows_count int = 0 ;
	
	begin
		select	@rows_count = count(1)
		from	dbo.REALIZATION_DOC rd
				inner join dbo.sys_general_document sgd on (sgd.code = rd.document_code)
		where	rd.realization_code = @p_realization_code
				--and rd.promise_date is not null
				and (
						sgd.document_name								like '%' + @p_keywords + '%'
						or	convert(varchar(30), rd.promise_date, 103)	like '%' + @p_keywords + '%' 
						or	case rd.is_required
								when '1' then '*'
								else ''
							end											like '%' + @p_keywords + '%'
					) ;

		select		id
					,sgd.document_name'document_name'
					,convert(varchar(30), rd.promise_date, 103) 'promise_date'
					,case rd.is_required
							when '1' then '*'
							else ''
						end 'is_required'
					,rd.is_valid'is_valid'
					,rd.is_received 'is_received'
					,rd.remarks 'remarks'
					,@rows_count 'rowcount'
		from		dbo.realization_doc rd
					inner join dbo.sys_general_document sgd on (sgd.code = rd.document_code)
		where		rd.realization_code = @p_realization_code
					--and rd.promise_date is not null
					and (
							sgd.document_name								like '%' + @p_keywords + '%'
							or	rd.remarks									like '%' + @p_keywords + '%'
							or	convert(varchar(30), rd.promise_date, 103)	like '%' + @p_keywords + '%'
							or	case rd.is_required
									when '1' then '*'
									else ''
								end											like '%' + @p_keywords + '%'
						)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
															when 1 then sgd.document_name
															when 2 then cast(rd.promise_date as sql_variant)
															when 3 then rd.remarks
															--when 3 then cast(rd.expired_date as sql_variant)
															--when 4 then cast(rd.promise_date as sql_variant)
														
														end
					end asc
					,case
							when @p_sort_by = 'desc' then case @p_order_by
															when 1 then sgd.document_name
															when 2 then cast(rd.promise_date as sql_variant)
															when 3 then rd.remarks
															--when 3 then cast(rd.expired_date as sql_variant)
															--when 4 then cast(rd.promise_date as sql_variant)
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
	end
end ;

