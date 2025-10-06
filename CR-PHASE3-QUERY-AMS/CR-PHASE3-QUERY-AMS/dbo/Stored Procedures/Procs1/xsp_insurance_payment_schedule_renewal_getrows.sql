CREATE PROCEDURE dbo.xsp_insurance_payment_schedule_renewal_getrows
(
	@p_keywords				  nvarchar(50)
	,@p_pagenumber			  int
	,@p_rowspage			  int
	,@p_order_by			  int
	,@p_sort_by				  nvarchar(5)
	,@p_branch_code			  nvarchar(50)
	,@p_payment_renual_status nvarchar(10)
	,@p_from_date			  datetime
	,@p_to_date				  datetime
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
	from	insurance_payment_schedule_renewal ipsr
			inner join dbo.insurance_policy_main ipm on (ipm.code = ipsr.policy_code)
			--inner join dbo.asset aa on (aa.code					  = ipm.fa_code)
			left join dbo.master_insurance mi on (mi.code		  = ipm.insurance_code)
	where	ipm.branch_code				   = case @p_branch_code
												 when 'ALL' then ipm.branch_code
												 else @p_branch_code
											 end
			and ipsr.payment_renual_status = case @p_payment_renual_status
												 when 'ALL' then ipsr.payment_renual_status
												 else @p_payment_renual_status
											 end
			and cast(ipsr.policy_eff_date as date)
			between cast(@p_from_date as date) and cast(@p_to_date as date)
			and (
					ipm.branch_name										like '%' + @p_keywords + '%'
					or	ipm.insurance_type								like '%' + @p_keywords + '%'
					or	insurance_name									like '%' + @p_keywords + '%'
					or	ipsr.year_period								like '%' + @p_keywords + '%'
					or	convert(varchar(30), ipsr.policy_eff_date, 103) like '%' + @p_keywords + '%'
					or	ipsr.total_payment_amount						like '%' + @p_keywords + '%'
					or	ipsr.payment_renual_status						like '%' + @p_keywords + '%'
					--or	ipm.fa_code										like '%' + @p_keywords + '%'
					--or	aa.item_name									like '%' + @p_keywords + '%'
				) ;

	select		ipsr.code
				,ipm.branch_name
				,ipm.insurance_type
				,insurance_name
				,ipsr.year_period
				,convert(varchar(30), ipsr.policy_eff_date, 103) 'policy_eff_date'
				,ipsr.total_payment_amount
				,ipsr.payment_renual_status
				,dbo.xfn_get_system_date() 'system_date'
				--,ipm.fa_code 'asset_no'
				--,aa.item_name 'asset_name'
				,@rows_count 'rowcount'
	from		insurance_payment_schedule_renewal ipsr
				inner join dbo.insurance_policy_main ipm on (ipm.code = ipsr.policy_code)
				--inner join dbo.asset aa on (aa.code					  = ipm.fa_code)
				left join dbo.master_insurance mi on (mi.code		  = ipm.insurance_code)
	where		ipm.branch_code				   = case @p_branch_code
													 when 'ALL' then ipm.branch_code
													 else @p_branch_code
												 end
				and ipsr.payment_renual_status = case @p_payment_renual_status
													 when 'ALL' then ipsr.payment_renual_status
													 else @p_payment_renual_status
												 end
				and cast(ipsr.policy_eff_date as date)
				between cast(@p_from_date as date) and cast(@p_to_date as date)
				and (
						ipm.branch_name										like '%' + @p_keywords + '%'
						or	ipm.insurance_type								like '%' + @p_keywords + '%'
						or	insurance_name									like '%' + @p_keywords + '%'
						or	ipsr.year_period								like '%' + @p_keywords + '%'
						or	convert(varchar(30), ipsr.policy_eff_date, 103) like '%' + @p_keywords + '%'
						or	ipsr.total_payment_amount						like '%' + @p_keywords + '%'
						or	ipsr.payment_renual_status						like '%' + @p_keywords + '%'
						--or	ipm.fa_code										like '%' + @p_keywords + '%'
						--or	aa.item_name									like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ipm.branch_name
													 --when 2 then ipm.fa_code + aa.item_name
													 when 3 then ipm.insurance_type + insurance_name
													 when 4 then cast(ipsr.year_period as sql_variant)
													 when 5 then cast(ipsr.policy_eff_date as sql_variant)
													 when 6 then cast(ipsr.total_payment_amount as sql_variant)
													 when 7 then ipsr.payment_renual_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then ipm.branch_name
													   --when 2 then ipm.fa_code + aa.item_name
													   when 3 then ipm.insurance_type + insurance_name
													   when 4 then cast(ipsr.year_period as sql_variant)
													   when 5 then cast(ipsr.policy_eff_date as sql_variant)
													   when 6 then cast(ipsr.total_payment_amount as sql_variant)
													   when 7 then ipsr.payment_renual_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
