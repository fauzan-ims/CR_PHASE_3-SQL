
CREATE procedure xsp_asset_replacement_return_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
)
as
begin

	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	asset_replacement_return
	where	(
					replacement_code	like 	'%'+@p_keywords+'%'
				or	new_asset_code		like 	'%'+@p_keywords+'%'
				or	reason_code			like 	'%'+@p_keywords+'%'
				or	estimate_date		like 	'%'+@p_keywords+'%'
				or	remark				like 	'%'+@p_keywords+'%'
				or	status				like 	'%'+@p_keywords+'%'
			);

	select	id
			,replacement_code
			,new_asset_code
			,reason_code
			,estimate_date
			,remark
			,status
			,@rows_count	 'rowcount'
	from	asset_replacement_return
	where	(
					replacement_code		like 	'%'+@p_keywords+'%'
				or	new_asset_code		like 	'%'+@p_keywords+'%'
				or	reason_code		like 	'%'+@p_keywords+'%'
				or	estimate_date		like 	'%'+@p_keywords+'%'
				or	remark		like 	'%'+@p_keywords+'%'
				or	status		like 	'%'+@p_keywords+'%'
			)
	order by	 case
					when @p_sort_by = 'asc' then case @p_order_by
							when 1	then replacement_code
							when 2	then new_asset_code
							when 3	then reason_code
							when 4	then remark
							when 5	then status
					end
				end asc
				,case
					when @p_sort_by = 'desc' then case @p_order_by
							when 1	then replacement_code
							when 2	then new_asset_code
							when 3	then reason_code
							when 4	then remark
							when 5	then status
				end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end
