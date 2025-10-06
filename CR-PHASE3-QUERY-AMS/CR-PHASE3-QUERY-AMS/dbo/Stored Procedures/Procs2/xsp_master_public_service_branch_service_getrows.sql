CREATE PROCEDURE dbo.xsp_master_public_service_branch_service_getrows
(
	@p_keywords						nvarchar(50)
	,@p_pagenumber					int
	,@p_rowspage					int
	,@p_order_by					int
	,@p_sort_by						nvarchar(5)
	,@p_public_service_branch_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_public_service_branch_service mpsbs
			inner join dbo.sys_general_subcode sgs on (sgs.code collate latin1_general_ci_as = mpsbs.service_code) 
	where	public_service_branch_code = @p_public_service_branch_code 
	and		(
					sgs.description							like '%' + @p_keywords + '%'
					or	service_fee_amount					like '%' + @p_keywords + '%'
					or	mpsbs.estimate_finish_day			like '%' + @p_keywords + '%'
			) ;
 
		select		mpsbs.id
					,mpsbs.public_service_branch_code
					,sgs.description 'service'
					,mpsbs.service_fee_amount
					,mpsbs.estimate_finish_day
					,@rows_count 'rowcount'
		from		master_public_service_branch_service mpsbs
					inner join dbo.sys_general_subcode sgs on (sgs.code collate latin1_general_ci_as = mpsbs.service_code) 
		where		public_service_branch_code = @p_public_service_branch_code 
		and			(
							sgs.description							like '%' + @p_keywords + '%'
							or	service_fee_amount					like '%' + @p_keywords + '%'
							or	mpsbs.estimate_finish_day			like '%' + @p_keywords + '%'
					)
 
		Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then sgs.description
													when 2 then try_cast(service_fee_amount as nvarchar(20))
													when 3 then cast(mpsbs.estimate_finish_day as sql_variant)
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then sgs.description
													when 2 then try_cast(service_fee_amount as nvarchar(20))
													when 3 then cast(mpsbs.estimate_finish_day as sql_variant)
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
