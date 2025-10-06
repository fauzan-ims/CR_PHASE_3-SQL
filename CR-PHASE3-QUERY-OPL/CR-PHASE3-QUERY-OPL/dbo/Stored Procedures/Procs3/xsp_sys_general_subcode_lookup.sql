CREATE PROCEDURE dbo.xsp_sys_general_subcode_lookup
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_general_code  nvarchar(50)
	,@p_for_all		  nvarchar(1) = ''
	,@p_is_collateral nvarchar(1) = '1'
)
as
begin
	declare @rows_count int = 0 ;
	if (@p_for_all <> '')
	begin
		select	@rows_count = count(1)
		from
					(
						select	'ALL' as 'code'
								,'ALL' as 'description'
								,@rows_count 'rowcount'
						union
						select	code
								,description
								,@rows_count 'rowcount'
						from	sys_general_subcode
						where	general_code  = @p_general_code
								and is_active = '1'
					) as general
		where		code NOT IN ('RENTAL', 'PENALTY')
		and		(
					general.code like '%' + @p_keywords + '%'
					or	general.description like '%' + @p_keywords + '%'
				) ;

		select		*
		from
					(
						select	'ALL' as 'code'
								,'ALL' as 'description'
								,@rows_count 'rowcount'
						union
						select	code
								,description
								,@rows_count 'rowcount'
						from	sys_general_subcode
						where	general_code  = @p_general_code
								and is_active = '1'
					) as general
		where		code NOT IN ('RENTAL', 'PENALTY')
		and			(
						general.code like '%' + @p_keywords + '%'
						or	general.description like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then general.code
														when 2 then general.description
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then general.code
														when 2 then general.description
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
	end ;
	else if (@p_is_collateral = '1')
	begin
		select	@rows_count = count(1)
		from		dbo.sys_general_subcode
		where		code not in ('PENALTY','RENTAL')
		and			general_code  = @p_general_code
					and code	  <> case
										 when @p_is_collateral = '1' then 'other'
										 else 'none'
									 end
					and is_active = '1'
				and (
						code like '%' + @p_keywords + '%'
						or	description like '%' + @p_keywords + '%'
					) ;

		select		code
					,description
					,@rows_count 'rowcount'
		from		dbo.sys_general_subcode
		where		code not in ('PENALTY','RENTAL')
		and			general_code  = @p_general_code
					and code	  <> case
										 when @p_is_collateral = '1' then 'other'
										 else 'none'
									 end
					and is_active = '1'
					and (
							code like '%' + @p_keywords + '%'
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
	end
	else 
	begin
		select	@rows_count = count(1)
		from		sys_general_subcode
		where		code not in ('PENALTY','RENTAL')
		and			general_code = @p_general_code
					and is_active = '1'
				and (
						code							like '%' + @p_keywords + '%'
						or	description					like '%' + @p_keywords + '%'
					) ;

		select		code
					,description
					,@rows_count 'rowcount'
		from		sys_general_subcode
		where		code not in ('PENALTY','RENTAL')
		and			general_code = @p_general_code
					and is_active = '1'
					and (
							code							like '%' + @p_keywords + '%'
							or	description					like '%' + @p_keywords + '%'
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

end ;
