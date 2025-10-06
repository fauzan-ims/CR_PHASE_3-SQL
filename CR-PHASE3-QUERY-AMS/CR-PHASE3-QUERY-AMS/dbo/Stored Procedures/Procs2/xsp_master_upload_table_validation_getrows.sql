CREATE procedure dbo.xsp_master_upload_table_validation_getrows
(
	@p_keywords					 nvarchar(50)
	,@p_pagenumber				 int
	,@p_rowspage				 int
	,@p_order_by				 int
	,@p_sort_by					 nvarchar(5)
	,@p_upload_table_column_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.master_upload_table_validation mutd
			left join dbo.master_upload_validation muv on (mutd.upload_validation_code = muv.code)
	where	mutd.upload_table_column_code = @p_upload_table_column_code
			and (muv.description like '%' + @p_keywords + '%') ;

	select		mutd.id
				,muv.description
				,@rows_count 'rowcount'
	from		dbo.master_upload_table_validation mutd
				left join dbo.master_upload_validation muv on (mutd.upload_validation_code = muv.code)
	where		mutd.upload_table_column_code = @p_upload_table_column_code
				and (muv.description like '%' + @p_keywords + '%')
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then muv.description
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then muv.description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
