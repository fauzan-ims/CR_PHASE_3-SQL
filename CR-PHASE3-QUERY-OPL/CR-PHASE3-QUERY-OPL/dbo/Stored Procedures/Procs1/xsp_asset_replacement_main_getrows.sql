CREATE PROCEDURE dbo.xsp_asset_replacement_main_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	--
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
	from	asset_replacement arm
			inner join dbo.agreement_main am on (am.agreement_no = arm.agreement_no)
	where	arm.branch_code = case @p_branch_code
								  when 'ALL' then arm.branch_code
								  else @p_branch_code
							  end
			and arm.status	= case @p_status
								  when 'ALL' then arm.status
								  else @p_status
							  end
			and (
					arm.code				like 	'%'+@p_keywords+'%'
					or	arm.agreement_no	like 	'%'+@p_keywords+'%'
					or	am.client_name		like 	'%'+@p_keywords+'%'
					or	arm.date			like 	'%'+@p_keywords+'%'
					or	arm.branch_code		like 	'%'+@p_keywords+'%'
					or	arm.branch_name		like 	'%'+@p_keywords+'%'
					or	arm.remark			like 	'%'+@p_keywords+'%'
					or	arm.status			like 	'%'+@p_keywords+'%'
				) ;

	select		arm.code
				,arm.agreement_no
				,am.client_name
				,arm.date
				,arm.branch_code
				,arm.branch_name
				,arm.remark
				,arm.status
				,@rows_count 'rowcount'
	from		asset_replacement arm
				inner join dbo.agreement_main am on (am.agreement_no = arm.agreement_no)
	where		arm.branch_code = case @p_branch_code
									  when 'ALL' then arm.branch_code
									  else @p_branch_code
								  end
				and arm.status	= case @p_status
									  when 'ALL' then arm.status
									  else @p_status
								  end
				and (
						arm.code				like 	'%'+@p_keywords+'%'
						or	arm.agreement_no	like 	'%'+@p_keywords+'%'
						or	am.client_name		like 	'%'+@p_keywords+'%'
						or	arm.date			like 	'%'+@p_keywords+'%'
						or	arm.branch_code		like 	'%'+@p_keywords+'%'
						or	arm.branch_name		like 	'%'+@p_keywords+'%'
						or	arm.remark			like 	'%'+@p_keywords+'%'
						or	arm.status			like 	'%'+@p_keywords+'%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then arm.code
													 when 2 then arm.agreement_no
													 when 3 then arm.branch_code
													 when 4 then arm.branch_name
													 when 5 then arm.remark
													 when 6 then status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then arm.code
													   when 2 then arm.agreement_no
													   when 3 then arm.branch_code
													   when 4 then arm.branch_name
													   when 5 then arm.remark
													   when 6 then status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
