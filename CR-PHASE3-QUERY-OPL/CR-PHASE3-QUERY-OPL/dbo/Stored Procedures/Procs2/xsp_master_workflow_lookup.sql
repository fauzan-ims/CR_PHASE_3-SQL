
CREATE PROCEDURE [dbo].[xsp_master_workflow_lookup]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_type	   nvarchar(20) = ''
)
as
begin
	declare @rows_count int	= 0 ;

	select	@rows_count = count(1)
	from	master_workflow mw
	where	is_active = '1'
			and exists
			(
				select	1
				from	dbo.master_workflow mw1
				where	mw.code	 = mw1.code
						and @p_type = 'APPROVAL'
						and mw1.code not in('ENTRY', 'GO LIVE')
			)
			or	exists
			(
				select	1
				from	dbo.master_workflow mw2
				where	mw.code	 = mw2.code
						and @p_type = 'INQUIRY'
			)
			and (
					code			like '%' + @p_keywords + '%'
					or	description like '%' + @p_keywords + '%'
				) ;

	select		code
				,description
				,@rows_count 'rowcount'
	from		master_workflow mw
	where		is_active = '1'
				AND exists
				(
					select	1
					from	dbo.master_workflow mw1
					where	mw.code	 = mw1.code
							and @p_type = 'APPROVAL'
							and mw1.code not in('ENTRY', 'GO LIVE')
				)
				or	exists
				(
					select	1
					from	dbo.master_workflow mw2
					where	mw.code	 = mw2.code
							and @p_type = 'INQUIRY'
				)
				and (
						code			like '%' + @p_keywords + '%'
						or	description like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then description
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then description
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
