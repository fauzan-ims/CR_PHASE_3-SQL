CREATE PROCEDURE dbo.xsp_application_main_workflow_printing_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	declare @temp table
	(
		description nvarchar(4000)
	) ;

	insert into @temp
	(
		description
	)
	values ('PERJANJIAN')
		   ,('LAMPIRAN KENDARAAN')
		   ,('LAMPIRAN LAIN-LAIN')
		   ,('LAMPIRAN SCHEDULE')
		   ,('PERNYATAAN PENERIMAAN BARANG') 
		   ,('OFFERING LATER') ;

	select	@rows_count = count(1)
	from	@temp
	where	(description like '%' + @p_keywords + '%') ;

	select		 description 
				,@rows_count 'rowcount'
	from		@temp
	where		(description like '%' + @p_keywords + '%')
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then description
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

