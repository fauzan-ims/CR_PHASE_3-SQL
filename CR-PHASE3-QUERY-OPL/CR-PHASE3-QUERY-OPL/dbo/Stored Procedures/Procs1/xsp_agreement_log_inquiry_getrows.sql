CREATE PROCEDURE dbo.xsp_agreement_log_inquiry_getrows
(
	@p_keywords	     nvarchar(50)
	,@p_pagenumber   int
	,@p_rowspage     int
	,@p_order_by     int
	,@p_sort_by	     nvarchar(5)
	,@p_agreement_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.agreement_log
	where	agreement_no = @p_agreement_no
			and(
				id					                       like '%' + @p_keywords + '%'
				or	log_source_no					       like '%' + @p_keywords + '%'
				or	convert(varchar(10), log_date, 101) +' '+ convert(varchar, log_date,108)	   like '%' + @p_keywords + '%'
				or	log_remarks							   like '%' + @p_keywords + '%'
			) ;
		select		id
					,log_source_no
					,convert(varchar(10), log_date, 101) +' '+ convert(varchar, log_date,108) 'log_date'
					,log_remarks
					,@rows_count 'rowcount'
		from		dbo.agreement_log
		where	agreement_no = @p_agreement_no 
				and(
					id							     		   like '%' + @p_keywords + '%'
					or	log_source_no			               like '%' + @p_keywords + '%'
					or	convert(varchar(10), log_date, 101) +' '+ convert(varchar, log_date,108)	   like '%' + @p_keywords + '%'
					or	log_remarks							   like '%' + @p_keywords + '%'
				) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then log_source_no	                    
													when 2 then cast(log_date as sql_variant)
													when 3 then log_remarks	
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then log_source_no	                    
													when 2 then cast(log_date as sql_variant)
													when 3 then log_remarks	
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
