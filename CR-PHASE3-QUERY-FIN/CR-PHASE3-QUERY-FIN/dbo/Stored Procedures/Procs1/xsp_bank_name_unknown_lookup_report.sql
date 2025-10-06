CREATE PROCEDURE dbo.xsp_bank_name_unknown_lookup_report
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
							,description
					from	ifinsys.dbo.sys_bank
					where	is_active	= '1'
				) as bank
		where	(
					bank.code like '%' + @p_keywords + '%'
					or	bank.name like '%' + @p_keywords + '%'
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
									,description
									,@rows_count 'rowcount'
							from	ifinsys.dbo.sys_bank
							where	is_active	= '1'
						) as bank
			where		(
							bank.code like '%' + @p_keywords + '%'
							or	bank.name like '%' + @p_keywords + '%'
						)
			order by	case @p_order_by
							when 1 then bank.code
							when 2 then bank.name
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
									,description
									,@rows_count 'rowcount'
							from	ifinsys.dbo.sys_bank
							where	is_active = '1'
						) as bank
			where		(
							bank.code like '%' + @p_keywords + '%'
							or	bank.name like '%' + @p_keywords + '%'
						)
			order by	case @p_order_by
							when 1 then bank.code
							when 2 then bank.name
						end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
		end ;
	end ;
	else
	begin

			select	@rows_count = count(1)
			from	ifinsys.dbo.sys_bank
			where	(
						code							like '%' + @p_keywords + '%'
						or	description					like '%' + @p_keywords + '%'
					) ;

			if @p_sort_by = 'asc'
			begin
				select		code
							,description
							,@rows_count 'rowcount'
				from		ifinsys.dbo.sys_bank
				where		is_active = '1'
				and			(
								code					like '%' + @p_keywords + '%'
								or	description			like '%' + @p_keywords + '%'
							)
				order by	case @p_order_by
								when 1 then code
								when 2 then description
							end asc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
			end ;
			else
			begin
				select      code
							,description
							,@rows_count 'rowcount'
				from		ifinsys.dbo.sys_bank
				where		is_active = '1'
				and			(
								code					like '%' + @p_keywords + '%'
								or	description			like '%' + @p_keywords + '%'
							)
				order by	case @p_order_by
								when 1 then code
								when 2 then description
							end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
			end ;
	end ;
end ;
