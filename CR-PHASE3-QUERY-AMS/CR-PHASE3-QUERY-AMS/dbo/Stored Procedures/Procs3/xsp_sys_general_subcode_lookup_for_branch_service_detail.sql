CREATE procedure dbo.xsp_sys_general_subcode_lookup_for_branch_service_detail
(
	@p_keywords					   nvarchar(50)
	,@p_pagenumber				   int
	,@p_rowspage				   int
	,@p_order_by				   int
	,@p_sort_by					   nvarchar(5)
	,@p_public_service_branch_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sys_general_subcode sgs
	where	sgs.is_active		 = '1'
			and not exists
	(
		select	1
		from	dbo.master_public_service_branch_service mpsbs
		where	mpsbs.SERVICE_CODE					 = sgs.code
				and mpsbs.public_service_branch_code = @p_public_service_branch_code
	)
			and sgs.general_code = 'PBSSVC'
			and (description like '%' + @p_keywords + '%') ;

	select		code
				,description
				,is_active
				,@rows_count 'rowcount'
	from		sys_general_subcode sgs
	where		sgs.is_active		 = '1'
				and not exists
	(
		select	1
		from	dbo.master_public_service_branch_service mpsbs
		where	mpsbs.SERVICE_CODE					 = sgs.code
				and mpsbs.public_service_branch_code = @p_public_service_branch_code
	)
				and sgs.general_code = 'PBSSVC'
				and (description like '%' + @p_keywords + '%')
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then description
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
