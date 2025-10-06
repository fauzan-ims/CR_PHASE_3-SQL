CREATE PROCEDURE dbo.xsp_master_public_service_branch_service_lookup
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.master_public_service_branch_service mpss
	inner join dbo.master_public_service_branch mpsb on (mpsb.code = mpss.public_service_branch_code)
	inner join dbo.sys_general_subcode sgs on (sgs.code = mpss.service_code)
	where	mpsb.branch_code = @p_branch_code
	and		(
				mpss.service_code					like '%' + @p_keywords + '%'
				or	sgs.description					like '%' + @p_keywords + '%'
			) ;

	select		mpss.service_code
				,sgs.description
				,mpss.service_fee_amount
				,@rows_count 'rowcount'
	from	dbo.master_public_service_branch_service mpss
	inner join dbo.master_public_service_branch mpsb on (mpsb.code = mpss.public_service_branch_code)
	inner join dbo.sys_general_subcode sgs on (sgs.code = mpss.service_code)
	where	mpsb.branch_code = @p_branch_code
	and		(
				mpss.service_code					like '%' + @p_keywords + '%'
				or	sgs.description					like '%' + @p_keywords + '%'
			)
	order by	case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mpss.service_code
													when 2 then sgs.description
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then mpss.service_code
														when 2 then sgs.description
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
