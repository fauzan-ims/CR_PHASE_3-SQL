CREATE PROCEDURE dbo.xsp_master_approval_dimension_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_approval_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_approval_dimension mad
			left join dbo.sys_dimension sdm on sdm.code = mad.dimension_code
	where	approval_code = @p_approval_code
			and (
					mad.id						like '%' + @p_keywords + '%'
					or	mad.approval_code		like '%' + @p_keywords + '%'
					or	mad.reff_dimension_code like '%' + @p_keywords + '%'
					or	mad.reff_dimension_name like '%' + @p_keywords + '%'
					or	mad.dimension_code		like '%' + @p_keywords + '%'
					or	sdm.description			like '%' + @p_keywords + '%'
				) ;
				 
		select		mad.id
					,mad.approval_code
					,mad.reff_dimension_code
					,mad.reff_dimension_name
					,mad.dimension_code
					,sdm.description
					,@rows_count 'rowcount'
		from		master_approval_dimension mad
					left join dbo.sys_dimension sdm on sdm.code = mad.dimension_code
		where		approval_code = @p_approval_code
					and (
							mad.id						like '%' + @p_keywords + '%'
							or	mad.approval_code		like '%' + @p_keywords + '%'
							or	mad.reff_dimension_code like '%' + @p_keywords + '%'
							or	mad.reff_dimension_name like '%' + @p_keywords + '%'
							or	mad.dimension_code		like '%' + @p_keywords + '%'
							or	sdm.description			like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mad.reff_dimension_code
													when 2 then mad.reff_dimension_name
													when 3 then sdm.description
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then mad.reff_dimension_code
													when 2 then mad.reff_dimension_name
													when 3 then sdm.description
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
