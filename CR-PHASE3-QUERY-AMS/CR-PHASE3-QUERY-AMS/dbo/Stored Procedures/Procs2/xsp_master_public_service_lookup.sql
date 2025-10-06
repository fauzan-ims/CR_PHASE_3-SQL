CREATE PROCEDURE dbo.xsp_master_public_service_lookup
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;
	if exists
	(
		select	*
		from	sys_global_param
		where	code	  = 'HO'
		and		value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;


	select	@rows_count = count(1)
	from	master_public_service mps
			left join dbo.master_public_service_branch mpsb on (mpsb.public_service_code = mps.code)
	where	is_validate			 = '1'
			--and mpsb.branch_code = case @p_branch_code
			--							when 'ALL' then mpsb.branch_code
			--							else @p_branch_code
			--					   end
			and
			(
				mps.code			like '%' + @p_keywords + '%'
				or	public_service_name like '%' + @p_keywords + '%'
			) ;

	select		mps.code
				,public_service_name
				,@rows_count 'rowcount'
	from		master_public_service mps
				left join dbo.master_public_service_branch mpsb on (mpsb.public_service_code = mps.code)
	where		is_validate			 = '1'
				--and mpsb.branch_code = case @p_branch_code
				--						   when 'ALL' then mpsb.branch_code
				--						   else @p_branch_code
				--					   end
				and
				(
					mps.code				like '%' + @p_keywords + '%'
					or	public_service_name like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mps.code
													 when 2 then public_service_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then mps.code
													   when 2 then public_service_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
