CREATE procedure [dbo].[xsp_master_insurance_coverage_getrows]
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
	from	master_insurance_coverage mic
			inner join dbo.master_coverage mc on (mc.code = mic.coverage_code)
	where	mic.insurance_code = @p_insurance_code
			and (
					mic.code				like '%' + @p_keywords + '%'
					or	mc.coverage_name	like '%' + @p_keywords + '%'
				) ;

	if @p_sort_by = 'asc'
	begin
		select		mic.code
					,mc.coverage_name
					,@rows_count 'rowcount'
		from		master_insurance_coverage mic
					inner join dbo.master_coverage mc on (mc.code = mic.coverage_code)
		where		mic.insurance_code = @p_insurance_code
					and (
							mic.code				like '%' + @p_keywords + '%'
							or	mc.coverage_name	like '%' + @p_keywords + '%'
						)
		order by	case @p_order_by
						when 1 then mic.code
						when 2 then mc.coverage_name
					end asc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
	else
	begin
		select		mic.code
					,mc.coverage_name
					,@rows_count 'rowcount'
		from		master_insurance_coverage mic
					inner join dbo.master_coverage mc on (mc.code = mic.coverage_code)
		where		mic.insurance_code = @p_insurance_code
					and (
							mic.code				like '%' + @p_keywords + '%'
							or	mc.coverage_name	like '%' + @p_keywords + '%'
						)
		order by	case @p_order_by
						when 1 then mic.code
						when 2 then mc.coverage_name
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
end ;


