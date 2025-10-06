CREATE PROCEDURE dbo.xsp_master_coverage_lookup_for_coverage
(
	@p_keywords	       nvarchar(50)
	,@p_pagenumber     int
	,@p_rowspage       int
	,@p_order_by       int
	,@p_sort_by	       nvarchar(5)
	,@p_insurance_type nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.master_coverage mc
				inner join dbo.master_insurance_coverage mic on (mic.coverage_code = mc.code)
				inner join dbo.master_insurance mi on (mi.code = mic.insurance_code)
	where	is_active = '1'
			and	mi.insurance_type = @p_insurance_type
			and (
						mc.code							like '%' + @p_keywords + '%'
						or	coverage_name				like '%' + @p_keywords + '%'
					) ;

		select		mc.code
					,coverage_name
					,mi.insurance_type
					,@rows_count 'rowcount'
		from	dbo.master_coverage mc
				inner join dbo.master_insurance_coverage mic on (mic.coverage_code = mc.code)
				inner join dbo.master_insurance mi on (mi.code = mic.insurance_code)
		where		is_active = '1'
					and	mi.insurance_type = @p_insurance_type
					and (
									mc.code							like '%' + @p_keywords + '%'
									or	coverage_name				like '%' + @p_keywords + '%'
						)
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mc.code
													when 2 then coverage_name
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then mc.code
													when 2 then coverage_name
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;


