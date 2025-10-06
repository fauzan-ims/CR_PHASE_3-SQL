CREATE PROCEDURE dbo.xsp_sys_dimension_value_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_dimension_code  nvarchar(50) 
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	sys_dimension_value
	where	dimension_code	= case @p_dimension_code
											when 'ALL' then dimension_code
											else @p_dimension_code
									  END
			and (
				description			like 	'%'+@p_keywords+'%'
				or	value			like 	'%'+@p_keywords+'%'
			); 
		select	code
				,description
				,value
				,@rows_count	 'rowcount'
		from	sys_dimension_value
		where	dimension_code	= case @p_dimension_code
											when 'ALL' then dimension_code
											else @p_dimension_code
									  END
				and (
					description		like 	'%'+@p_keywords+'%'
					or	value		like 	'%'+@p_keywords+'%'
				) 
		Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1	then description
													when 2	then case when isnumeric(value) = 1 then cast(value as int) else 0 end --untuk shorting type nvarchar tapi value nya angka
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1	then description
													when 2	then case when isnumeric(value) = 1 then cast(value as int) else 0 end --untuk shorting type nvarchar tapi value nya angka
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end
