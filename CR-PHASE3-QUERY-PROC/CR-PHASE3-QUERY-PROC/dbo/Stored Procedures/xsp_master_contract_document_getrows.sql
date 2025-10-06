CREATE PROCEDURE [dbo].[xsp_master_contract_document_getrows]
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	--
	,@p_main_contract_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.master_contract_document		mcd
			inner join dbo.sys_general_document sgd on sgd.code = mcd.document_code
	where	mcd.main_contract_no = @p_main_contract_no
			and
			(
				sgd.document_name									like '%' + @p_keywords + '%'
				or	mcd.remarks										like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), mcd.promise_date, 103)	like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), mcd.expired_date, 103)	like '%' + @p_keywords + '%'
			) ;

	select		id
				,sgd.document_name
				,mcd.remarks
				,convert(nvarchar(30), mcd.promise_date, 103) 'promise_date'
				,convert(nvarchar(30), mcd.expired_date, 103) 'expired_date'
				,@rows_count 'rowcount'
	from		dbo.master_contract_document		mcd
				inner join dbo.sys_general_document sgd on sgd.code = mcd.document_code
	where		mcd.main_contract_no = @p_main_contract_no
				and
				(
					sgd.document_name									like '%' + @p_keywords + '%'
					or	mcd.remarks										like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), mcd.promise_date, 103)	like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), mcd.expired_date, 103)	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then sgd.document_name
													 when 2 then mcd.remarks
													 when 3 then cast(mcd.promise_date as sql_variant)
													 when 4 then cast(mcd.expired_date as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then sgd.document_name
													   when 2 then mcd.remarks
													   when 3 then cast(mcd.promise_date as sql_variant)
													   when 4 then cast(mcd.expired_date as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
