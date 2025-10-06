CREATE PROCEDURE [dbo].[xsp_claim_main_getrows]
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_branch_code	   nvarchar(50)
	,@p_claim_status   nvarchar(10)
	,@p_insurance_type nvarchar(10)
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
	from	claim_main cm
			inner join dbo.insurance_policy_main ipm on (ipm.code = cm.policy_code)
			left join dbo.master_insurance mi on (mi.code		  = ipm.insurance_code)
			--inner join dbo.asset ass on (ass.code				  = ipm.fa_code)
	where	cm.branch_code		   = case @p_branch_code
										 when 'ALL' then cm.branch_code
										 else @p_branch_code
									 end
			and cm.claim_status	   = case @p_claim_status
										 when 'ALL' then cm.claim_status
										 else @p_claim_status
									 end
			and ipm.insurance_type = case @p_insurance_type
										 when 'ALL' then ipm.insurance_type
										 else @p_insurance_type
									 end
			and (
					cm.code														like '%' + @p_keywords + '%'
					or	cm.claim_request_code									like '%' + @p_keywords + '%'
					or	cm.branch_name											like '%' + @p_keywords + '%'
					or	ipm.policy_no											like '%' + @p_keywords + '%'
					or	mi.insurance_name										like '%' + @p_keywords + '%'
					or	convert(varchar(30), cm.customer_report_date, 103)		like '%' + @p_keywords + '%'
					or	cm.claim_status											like '%' + @p_keywords + '%'
					or	case ipm.insurance_type
							when 'LIFE' then 'LIFE'
							when 'CREDIT' then 'CREDIT'
							else 'COLLATERAL'
						end														like '%' + @p_keywords + '%'
					--or ipm.fa_code												like '%' + @p_keywords + '%'
					--or ass.item_name											like '%' + @p_keywords + '%'
					or	cm.asset_info											like '%' + @p_keywords + '%'
				) ;

	select		cm.code
				,cm.claim_request_code
				,cm.branch_name
				,ipm.policy_no
				,mi.insurance_name
				,convert(varchar(30), cm.customer_report_date, 103) 'customer_report_date'
				,cm.claim_status
				,case ipm.insurance_type
					 when 'LIFE' then 'LIFE'
					 when 'CREDIT' then 'CREDIT'
					 else 'COLLATERAL'
				 end 'insurance_type'
				--,ipm.fa_code
				--,ass.item_name 'fa_name'
				,cm.asset_info
				,@rows_count 'rowcount'
	from		claim_main cm
				inner join dbo.insurance_policy_main ipm on (ipm.code = cm.policy_code)
				left join dbo.master_insurance mi on (mi.code		  = ipm.insurance_code)
				--inner join dbo.asset ass on (ass.code				  = ipm.fa_code)
	where		cm.branch_code		   = case @p_branch_code
											 when 'ALL' then cm.branch_code
											 else @p_branch_code
										 end
				and cm.claim_status	   = case @p_claim_status
											 when 'ALL' then cm.claim_status
											 else @p_claim_status
										 end
				and ipm.insurance_type = case @p_insurance_type
											 when 'ALL' then ipm.insurance_type
											 else @p_insurance_type
										 end
				and (
						cm.code														like '%' + @p_keywords + '%'
						or	cm.claim_request_code									like '%' + @p_keywords + '%'
						or	cm.branch_name											like '%' + @p_keywords + '%'
						or	ipm.policy_no											like '%' + @p_keywords + '%'
						or	mi.insurance_name										like '%' + @p_keywords + '%'
						or	convert(varchar(30), cm.customer_report_date, 103)		like '%' + @p_keywords + '%'
						or	cm.claim_status											like '%' + @p_keywords + '%'
						or	case ipm.insurance_type
								when 'LIFE' then 'LIFE'
								when 'CREDIT' then 'CREDIT'
								else 'COLLATERAL'
							end														like '%' + @p_keywords + '%'
						--or ipm.fa_code												like '%' + @p_keywords + '%'
						--or ass.item_name											like '%' + @p_keywords + '%'
						or	cm.asset_info											like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then cm.code
													 when 2 then ipm.policy_no
													 when 3 then cm.branch_name
													 --when 3 then ipm.fa_code + ass.item_name
													 when 4 then mi.insurance_name
													 when 5 then cast(cm.customer_report_date as sql_variant)
													 when 6 then cm.claim_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then cm.code
													 when 2 then ipm.policy_no
													 when 3 then cm.branch_name
													 --when 3 then ipm.fa_code + ass.item_name
													 when 4 then mi.insurance_name
													 when 5 then cast(cm.customer_report_date as sql_variant)
													 when 6 then cm.claim_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
