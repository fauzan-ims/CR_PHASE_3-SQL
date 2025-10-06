CREATE PROCEDURE dbo.xsp_journal_gl_link_lookup_report
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_for_all		nvarchar(1)	= ''
)
as
begin
	declare @rows_count int = 0 ;

	if (@p_for_all <> '')
	begin
		select	@rows_count = count(1)
		from
				(
					select 	'ALL' as 'code'
							,'ALL' as 'name'
					union all
					select  code
							,gl_link_name
					from	dbo.journal_gl_link
					where	is_bank		= '1'
					and		is_active	= '1'
				) as gl
		where	(
					gl.code like '%' + @p_keywords + '%'
					or	gl.name like '%' + @p_keywords + '%'
				) ;

		if @p_sort_by = 'asc'
		begin
			select		*
			from
						(
							select	'ALL' as 'code'
									,'ALL' as 'name'
									,@rows_count 'rowcount'
							union all
							select  code
									,gl_link_name
									,@rows_count 'rowcount'
							from	dbo.journal_gl_link
							where	is_bank		= '1'
							and		is_active	= '1'
						) as gl
			where		(
							gl.code like '%' + @p_keywords + '%'
							or	gl.name like '%' + @p_keywords + '%'
						)
			order by	case @p_order_by
							when 1 then gl.code
							when 2 then gl.name
						end asc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
		end ;
		else
		begin
			select		*
			from
						(
							select	'ALL' as 'code'
									,'ALL' as 'name'
									,@rows_count 'rowcount'
							union all
							select	code
									,gl_link_name
									,@rows_count 'rowcount'
							from	dbo.journal_gl_link
							where	is_bank   = '1'
							and		is_active = '1'
						) as gl
			where		(
							gl.code like '%' + @p_keywords + '%'
							or	gl.name like '%' + @p_keywords + '%'
						)
			order by	case @p_order_by
							when 1 then gl.code
							when 2 then gl.name
						end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
		end ;
	end ;
	else
	begin

			select	@rows_count = count(1)
			from	dbo.journal_gl_link
			where	(
						code							like '%' + @p_keywords + '%'
						or	gl_link_name				like '%' + @p_keywords + '%'
					) ;

			if @p_sort_by = 'asc'
			begin
				select		code
							,gl_link_name
							,@rows_count 'rowcount'
				from		dbo.journal_gl_link
				where		is_bank   = '1'
				and			is_active = '1'
				and			(
								code					like '%' + @p_keywords + '%'
								or	gl_link_name		like '%' + @p_keywords + '%'
							)
				order by	case @p_order_by
								when 1 then code
								when 2 then gl_link_name
							end asc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
			end ;
			else
			begin
				select      code
							,gl_link_name
							,@rows_count 'rowcount'
				from		dbo.journal_gl_link
				where		is_bank   = '1'
				and			is_active = '1'
				and			(
								code					like '%' + @p_keywords + '%'
								or	gl_link_name		like '%' + @p_keywords + '%'
							)
				order by	case @p_order_by
								when 1 then code
								when 2 then gl_link_name
							end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
			end ;
	end ;
end ;
