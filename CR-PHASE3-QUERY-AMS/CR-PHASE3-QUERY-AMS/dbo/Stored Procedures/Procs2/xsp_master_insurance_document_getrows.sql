CREATE procedure dbo.xsp_master_insurance_document_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_insurance_code  nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_insurance_document mid
			inner join dbo.sys_general_document sgd on (mid.document_code = sgd.code)
	where	insurance_code = @p_insurance_code
			and (
					sgd.document_name							like '%' + @p_keywords + '%'
					or	file_name								like '%' + @p_keywords + '%'
					or	convert(varchar(30), expired_date, 103)	like '%' + @p_keywords + '%'
				) ;

		select		id
					,document_code
					,sgd.document_name	
					,isnull(file_name,'') 'file_name'
					,isnull(paths,'') 'paths'
					,convert(varchar(30), expired_date, 103) 'expired_date'
					,@rows_count 'rowcount'
		from	master_insurance_document mid
				inner join dbo.sys_general_document sgd on (mid.document_code = sgd.code)
		where	insurance_code = @p_insurance_code
					and (
							sgd.document_name							like '%' + @p_keywords + '%'
							or	file_name								like '%' + @p_keywords + '%'
							or	convert(varchar(30), expired_date, 103)	like '%' + @p_keywords + '%'
						)
		order by case 
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then sgd.document_name
													when 2 then file_name
													when 3 then cast(expired_date as sql_variant)	
												 end
					end asc 
					,case when @p_sort_by = 'desc' then case @p_order_by
															when 1 then sgd.document_name
															when 2 then file_name
															when 3 then cast(expired_date as sql_variant)
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;


