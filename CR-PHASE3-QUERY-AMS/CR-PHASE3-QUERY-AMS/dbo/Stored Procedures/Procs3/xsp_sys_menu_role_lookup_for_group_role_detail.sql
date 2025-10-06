CREATE PROCEDURE dbo.xsp_sys_menu_role_lookup_for_group_role_detail
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_menu_code		nvarchar(50)
	,@p_role_access		nvarchar(1)
	,@p_role_group_code nvarchar(50)
	,@p_source_module	nvarchar(10) = ''
)
as
begin
	declare @rows_count int = 0 ;
	if @p_source_module = ''
	begin
		select	@rows_count = count(1)
		from	sys_menu_role smr
				left join	dbo.sys_menu menu on menu.code = smr.menu_code
				left join	dbo.sys_menu sub on sub.code = menu.parent_menu_code
				left join   dbo.sys_menu module on module.code = sub.parent_menu_code
		where	smr.menu_code = @p_menu_code
				and smr.role_access =  case @p_role_access
												when 'L' then smr.role_access
												else @p_role_access
										   end
				and smr.role_code not in
				(
						select  rgd.role_code
						from	dbo.sys_role_group_detail rgd
						where	rgd.role_code = smr.role_code
								and rgd.role_group_code = @p_role_group_code
				)
				and (
						smr.role_code					like '%' + @p_keywords + '%'
						or smr.role_name				like '%' + @p_keywords + '%'
					) ;

		if @p_sort_by = 'asc'
		begin
			select		smr.role_code
						,smr.role_name
						,@rows_count 'rowcount'
			from		sys_menu_role smr
						left join	dbo.sys_menu menu on menu.code = smr.menu_code
						left join	dbo.sys_menu sub on sub.code = menu.parent_menu_code
						left join   dbo.sys_menu module on module.code = sub.parent_menu_code
			where	smr.menu_code = @p_menu_code
					and smr.role_access =  case @p_role_access
													when 'L' then smr.role_access
													else @p_role_access
											   end
					and smr.role_code not in
					(
							select  rgd.role_code
							from	dbo.sys_role_group_detail rgd
							where	rgd.role_code = smr.role_code
									and rgd.role_group_code = @p_role_group_code
					)
					and (
							smr.role_code					like '%' + @p_keywords + '%'
							or smr.role_name				like '%' + @p_keywords + '%'
						)
			order by	case @p_order_by
							when 1 then smr.role_code
							when 2 then smr.role_name
						end asc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
		end ;
		else
		begin
			select		smr.role_code
						,smr.role_name
						,@rows_count 'rowcount'
			from		sys_menu_role smr
						left join	dbo.sys_menu menu on menu.code = smr.menu_code
						left join	dbo.sys_menu sub on sub.code = menu.parent_menu_code
						left join   dbo.sys_menu module on module.code = sub.parent_menu_code
			where	smr.menu_code = @p_menu_code
					and smr.role_access =  case @p_role_access
													when 'L' then smr.role_access
													else @p_role_access
											   end
					and smr.role_code not in
					(
							select  rgd.role_code
							from	dbo.sys_role_group_detail rgd
							where	rgd.role_code = smr.role_code
									and rgd.role_group_code = @p_role_group_code
					)
					and (
							smr.role_code					like '%' + @p_keywords + '%'
							or smr.role_name				like '%' + @p_keywords + '%'
						)
			order by	case @p_order_by
							when 1 then smr.role_code
							when 2 then smr.role_name
						end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
		end ;
	end
	else -- from icas
	begin
		select	@rows_count = count(1) 
		from	sys_menu_role smr 
				left join	dbo.sys_menu menu on menu.code = smr.menu_code 
				left join	dbo.sys_menu sub on sub.code = menu.parent_menu_code
				left join   dbo.sys_menu module on module.code = sub.parent_menu_code
		where	smr.menu_code = @p_menu_code 
		and		smr.role_access =  case @p_role_access 
											when 'L' then smr.role_access
											else @p_role_access
										end
		and		smr.role_code not in 
				(
					select  rgd.role_code collate latin1_general_ci_as
					from	icas.dbo.sys_role_group_detail rgd
					where	rgd.role_code = smr.role_code collate SQL_Latin1_General_CP1_CI_AS
							and rgd.role_group_code = @p_role_group_code
				)
		and		(
					smr.role_code					like '%' + @p_keywords + '%'
					or smr.role_name				like '%' + @p_keywords + '%'
				) ;

		select		smr.role_code
					,smr.role_name
					,@rows_count 'rowcount'
		from		sys_menu_role smr
					left join	dbo.sys_menu menu on menu.code = smr.menu_code
					left join	dbo.sys_menu sub on sub.code = menu.parent_menu_code
					left join   dbo.sys_menu module on module.code = sub.parent_menu_code
		where	smr.menu_code = @p_menu_code
		and		smr.role_access =  case @p_role_access
											when 'L' then smr.role_access
											else @p_role_access
										end
		and		smr.role_code not in
				(
					select  rgd.role_code collate latin1_general_ci_as
					from	icas.dbo.sys_role_group_detail rgd 
					where	rgd.role_code = smr.role_code collate SQL_Latin1_General_CP1_CI_AS
							and rgd.role_group_code = @p_role_group_code
				)
		and		(
					smr.role_code					like '%' + @p_keywords + '%'
					or smr.role_name				like '%' + @p_keywords + '%'
				)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														when 1 then smr.role_code 
														when 2 then smr.role_name
						 								end
					end asc
					,case
						when @p_sort_by = 'desc' then case @p_order_by				
														when 1 then smr.role_code
														when 2 then smr.role_name
						 								end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end;

end ;

