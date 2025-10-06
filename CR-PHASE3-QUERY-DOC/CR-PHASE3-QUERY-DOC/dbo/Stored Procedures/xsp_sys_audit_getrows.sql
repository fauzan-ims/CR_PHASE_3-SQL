CREATE procedure dbo.xsp_sys_audit_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
	,@p_status		nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	sys_audit sa
			inner join dbo.sys_general_subcode sgs on sgs.code				= sa.type_code
													  and  sgs.general_code = 'TYAUD'
	where	branch_code = case @p_branch_code
							  when 'ALL' then branch_code
							  else @p_branch_code
						  end
			and status	= case @p_status
							  when 'ALL' then status
							  else @p_status
						  end
			and (
					sa.code								like '%' + @p_keywords + '%'
					or	branch_name						like '%' + @p_keywords + '%'
					or	convert(varchar(30), date, 103) like '%' + @p_keywords + '%'
					or	sgs.description					like '%' + @p_keywords + '%'
					or	sa.description					like '%' + @p_keywords + '%'
					or	status							like '%' + @p_keywords + '%'
				) ;

	select		sa.code
				,branch_code
				,branch_name
				,date
				,type_code
				,sgs.description 'type_name'
				,sa.description
				,status
				,@rows_count 'rowcount'
	from		sys_audit sa
				inner join dbo.sys_general_subcode sgs on sgs.code				= sa.type_code
														  and  sgs.general_code = 'TYAUD'
	where		branch_code = case @p_branch_code
								  when 'ALL' then branch_code
								  else @p_branch_code
							  end
				and status	= case @p_status
								  when 'ALL' then status
								  else @p_status
							  end
				and (
						sa.code								like '%' + @p_keywords + '%'
						or	branch_name						like '%' + @p_keywords + '%'
						or	convert(varchar(30), date, 103) like '%' + @p_keywords + '%'
						or	sgs.description					like '%' + @p_keywords + '%'
						or	sa.description					like '%' + @p_keywords + '%'
						or	status							like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then sa.code
													 when 2 then branch_name
													 when 3 then cast(date as sql_variant)
													 when 4 then sgs.description
													 when 5 then sa.description
													 when 6 then status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then sa.code
													   when 2 then branch_name
													   when 3 then cast(date as sql_variant)
													   when 4 then sgs.description
													   when 5 then sa.description
													   when 6 then status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
