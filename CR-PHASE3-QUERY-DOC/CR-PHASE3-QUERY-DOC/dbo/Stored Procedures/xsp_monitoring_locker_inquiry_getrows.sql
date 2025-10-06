CREATE PROCEDURE dbo.xsp_monitoring_locker_inquiry_getrows
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
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	master_locker ml
			left join dbo.document_main dm on (
												  ml.code				  = dm.locker_code
												  and  dm.locker_position = 'IN LOCKER'
											  )
	where	ml.branch_code	 = case @p_branch_code
								   when 'ALL' then ml.branch_code
								   else @p_branch_code
							   end
			and ml.IS_ACTIVE = '1'
			and (
					ml.branch_name			like '%' + @p_keywords + '%'
					or	ml.locker_name		like '%' + @p_keywords + '%'
					or	dm.document_type	like '%' + @p_keywords + '%'
				) ;

	select		ml.branch_name
				,ml.locker_name
				,isnull(dm.document_type, '') 'document_type'
				,count(dm.code) 'quantity'
				,@rows_count 'rowcount'
	from		master_locker ml
				left join dbo.document_main dm on (
													  ml.code				  = dm.locker_code
													  and  dm.locker_position = 'IN LOCKER'
												  )
	where		ml.branch_code	 = case @p_branch_code
									   when 'ALL' then ml.branch_code
									   else @p_branch_code
								   end
				and ml.IS_ACTIVE = '1'
				and (
						ml.branch_name			like '%' + @p_keywords + '%'
						or	ml.locker_name		like '%' + @p_keywords + '%'
						or	dm.document_type	like '%' + @p_keywords + '%'
					)
	group by	ml.branch_name
				,ml.locker_name
				,isnull(dm.document_type, '')
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ml.branch_name
													 when 2 then ml.locker_name
													 when 3 then isnull(dm.document_type, '')
													 when 4 then cast(count(dm.code) as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then ml.branch_name
													   when 2 then ml.locker_name
													   when 3 then isnull(dm.document_type, '')
													   when 4 then cast(count(dm.code) as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
