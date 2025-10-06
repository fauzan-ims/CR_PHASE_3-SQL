CREATE PROCEDURE [dbo].[xsp_document_tbo_document_tbo_getrows]
(
	@p_keywords			  nvarchar(50)
	,@p_pagenumber		  int
	,@p_rowspage		  int
	,@p_order_by		  int
	,@p_sort_by			  nvarchar(5)
	--
	,@p_document_tbo_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.document_tbo_document_tbo		dtdt
			inner join dbo.sys_general_document sgd on sgd.code = dtdt.document_code
	where	document_tbo_code = @p_document_tbo_code
			and
			(
				sgd.document_name								like '%' + @p_keywords + '%'
				or	dtdt.remarks								like '%' + @p_keywords + '%'
				or	convert(varchar(15), promise_date, 103)		like '%' + @p_keywords + '%'
				or	convert(varchar(15), expired_date, 103)		like '%' + @p_keywords + '%'
			) ;

	select		id
				,sgd.document_name
				,dtdt.remarks
				,dtdt.is_valid
				,convert(varchar(30), promise_date, 103) 'promise_date'
				,convert(varchar(30), expired_date, 103) 'expired_date'
				,@rows_count							 'rowcount'
	from		dbo.document_tbo_document_tbo		dtdt
				inner join dbo.sys_general_document sgd on sgd.code = dtdt.document_code
	where		document_tbo_code = @p_document_tbo_code
				and
				(
					sgd.document_name							like '%' + @p_keywords + '%'
					or	dtdt.remarks							like '%' + @p_keywords + '%'
					or	convert(varchar(15), promise_date, 103) like '%' + @p_keywords + '%'
					or	convert(varchar(15), expired_date, 103) like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then sgd.document_name
													 when 2 then dtdt.remarks
													 when 3 then cast(promise_date as sql_variant)
													 when 4 then cast(expired_date as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then sgd.document_name
													   when 2 then dtdt.remarks
													   when 3 then cast(promise_date as sql_variant)
													   when 4 then cast(expired_date as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
