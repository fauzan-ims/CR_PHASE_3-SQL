CREATE PROCEDURE dbo.xsp_withholding_tax_history_lookup
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(distinct tax_file_no)
	from	withholding_tax_history 
	where	(
					tax_file_no					like '%' + @p_keywords + '%'
					or	tax_file_name			like '%' + @p_keywords + '%'
			) ;

	select	npwp.tax_file_no
			,npwp.tax_file_name
			,@rows_count 'rowcount'
	from	(
				select		distinct							
							tax_file_no								
							,name.tax_file_name							
				from		withholding_tax_history tno
							outer apply (select top 1 tax_file_name from withholding_tax_history tna where tna.tax_file_no = tno.tax_file_no) name
			) npwp
	where		(
					tax_file_no					like '%' + @p_keywords + '%'
					or	tax_file_name			like '%' + @p_keywords + '%'
				)
	order by	case
				when @p_sort_by = 'asc' then case @p_order_by
													when 1 then tax_file_no
													when 2 then tax_file_name 
											 end
				end asc
				,case
				 when @p_sort_by = 'desc' then case @p_order_by
													when 1 then tax_file_no
													when 2 then tax_file_name 
											   end
			 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
