CREATE PROCEDURE dbo.xsp_insurance_policy_main_lookup_for_manual_register
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_branch_code	   nvarchar(50)
	,@p_is_existing	   nvarchar(1) = ''
	,@p_insurance_code nvarchar(50)
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
	from	insurance_policy_main		   ipm
			left join dbo.master_insurance mi on (mi.code = ipm.insurance_code)
	where	ipm.branch_code			   = case @p_branch_code
											 when 'ALL' then ipm.branch_code
											 else @p_branch_code
										 end
			and ipm.policy_status	   = 'ACTIVE'
			and ipm.policy_payment_status = 'PAID'
			and ISNULL(ipm.policy_process_status,'') = ''
			and ipm.is_policy_existing = case @p_is_existing
											 when '' then ipm.is_policy_existing
											 else @p_is_existing
										 end
			and ipm.insurance_code	   = @p_insurance_code
			and
			(
				ipm.policy_no										like '%' + @p_keywords + '%'
				or	mi.insurance_name								like '%' + @p_keywords + '%'
				or	convert(varchar(30), ipm.policy_exp_date, 103)	like '%' + @p_keywords + '%'
				or	convert(varchar(30), ipm.policy_eff_date, 103)	like '%' + @p_keywords + '%'
			) ;

	select		ipm.code
				,ipm.policy_no
				,insurance_name
				,ipm.insurance_type
				,convert(varchar(30), ipm.policy_exp_date, 103)			   'policy_exp_date'
				,convert(varchar(30), ipm.policy_eff_date, 103)			   'policy_eff_date'
				,ipm.currency_code
				,ipm.insured_qq_name
				,datediff(month, ipm.policy_eff_date, ipm.policy_exp_date) 'to_year'
				,@rows_count											   'rowcount'
	from		insurance_policy_main		   ipm
				left join dbo.master_insurance mi on (mi.code = ipm.insurance_code)
	where		ipm.branch_code			   = case @p_branch_code
												 when 'ALL' then ipm.branch_code
												 else @p_branch_code
											 end
				and ipm.policy_status	   = 'ACTIVE'
				and ipm.policy_payment_status = 'PAID'
				and ISNULL(ipm.policy_process_status,'') = ''
				and ipm.is_policy_existing = case @p_is_existing
												 when '' then ipm.is_policy_existing
												 else @p_is_existing
											 end
				and ipm.insurance_code	   = @p_insurance_code
				and
				(
					ipm.policy_no										like '%' + @p_keywords + '%'
					or	mi.insurance_name								like '%' + @p_keywords + '%'
					or	convert(varchar(30), ipm.policy_exp_date, 103)	like '%' + @p_keywords + '%'
					or	convert(varchar(30), ipm.policy_eff_date, 103)	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ipm.policy_no
													 when 2 then cast(ipm.policy_eff_date as sql_variant)
													 when 3 then cast(ipm.policy_exp_date as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then ipm.policy_no
														when 2 then cast(ipm.policy_eff_date as sql_variant)
														when 3 then cast(ipm.policy_exp_date as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
