CREATE PROCEDURE dbo.xsp_upload_error_log_lookup
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	--
	,@p_tabel_name				nvarchar(50)
	,@p_cre_by					nvarchar(15)
	,@p_primary_column_name		nvarchar(250)
)
as
BEGIN

	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	upload_error_log
	where	tabel_name				= @p_tabel_name	
	and		cre_by					= @p_cre_by	
	and		primary_column_name		= @p_primary_column_name
	and		(
				error				                    like '%' + @p_keywords + '%'
			) ;

		select	id
				,error   
				,@rows_count 'rowcount'
		from	upload_error_log
		where	tabel_name				= @p_tabel_name	
		and		cre_by					= @p_cre_by	
		and		primary_column_name		= @p_primary_column_name
		and		(
					error				                    like '%' + @p_keywords + '%'
				)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then error
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then error
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
