CREATE PROCEDURE dbo.xsp_master_locker_lookup_report
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
							,'ALL' as 'description'
					union all
					select  code
							,locker_name
					from	dbo.master_locker
					where	is_active = '1'
				) as locker
		where	(
					locker.code like '%' + @p_keywords + '%'
					or	locker.description like '%' + @p_keywords + '%'
				) ;

		if @p_sort_by = 'asc'
		begin
			select		*
			from
						(
							select	'ALL' as 'code'
									,'ALL' as 'description'
									,@rows_count 'rowcount'
							union all
							select  code
									,locker_name
									,@rows_count 'rowcount'
							from	dbo.master_locker
							where	is_active	= '1'
						) as locker
			where		(
							locker.code like '%' + @p_keywords + '%'
							or	locker.description like '%' + @p_keywords + '%'
						)
			order by	case @p_order_by
							when 1 then locker.code
							when 2 then locker.description
						end asc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
		end ;
		else
		begin
			select		*
			from
						(
							select	'ALL' as 'code'
									,'ALL' as 'description'
									,@rows_count 'rowcount'
							union all
							select	code
									,locker_name
									,@rows_count 'rowcount'
							from	dbo.master_locker
							where	is_active	= '1'
						) as locker
			where		(
							locker.code like '%' + @p_keywords + '%'
							or	locker.description like '%' + @p_keywords + '%'
						)
			order by	case @p_order_by
							when 1 then locker.code
							when 2 then locker.description
						end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
		end ;
	end ;
	else
	begin

			select	@rows_count = count(1)
			from	dbo.master_locker
			where	is_active	= '1'
			and		(
						code						like '%' + @p_keywords + '%'
						or	locker_name				like '%' + @p_keywords + '%'
					) ;

			if @p_sort_by = 'asc'
			begin
				select		code
							,locker_name
							,@rows_count 'rowcount'
				from		dbo.master_locker
				where		is_active = '1'
				and			(
								code						like '%' + @p_keywords + '%'
								or	locker_name		    	like '%' + @p_keywords + '%'
							)
				order by	case @p_order_by
								when 1 then code
								when 2 then locker_name
							end asc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
			end ;
			else
			begin
				select      code
							,locker_name
							,@rows_count 'rowcount'
				from		dbo.master_locker
				where		is_active = '1'
				and			(
								code						like '%' + @p_keywords + '%'
								or	locker_name		    	like '%' + @p_keywords + '%'
							)
				order by	case @p_order_by
								when 1 then code
								when 2 then locker_name
							end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
			end ;
	end ;
end ;
