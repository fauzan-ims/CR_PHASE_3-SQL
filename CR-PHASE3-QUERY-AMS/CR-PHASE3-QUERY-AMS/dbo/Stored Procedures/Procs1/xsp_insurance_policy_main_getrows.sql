CREATE PROCEDURE [dbo].[xsp_insurance_policy_main_getrows]
(
	@p_keywords				   nvarchar(50)
	,@p_pagenumber			   int
	,@p_rowspage			   int
	,@p_order_by			   int
	,@p_sort_by				   nvarchar(5)
	,@p_branch_code			   nvarchar(50)
	,@p_insurance_code		   nvarchar(50)
	,@p_policy_status		   nvarchar(10)
	,@p_policy_payment_status  nvarchar(10)
	,@p_insurance_payment_type nvarchar(10)
	,@p_from_date			   datetime = ''
	,@p_to_date				   datetime = ''
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
	--inner join dbo.asset ass on (ipm.fa_code = ass.code)
	where	ipm.branch_code				  = case @p_branch_code
												when 'ALL' then ipm.branch_code
												else @p_branch_code
											end
			and ipm.insurance_code		  = case @p_insurance_code
												when 'ALL' then ipm.insurance_code
												else @p_insurance_code
											end
			and ipm.policy_status		  = case @p_policy_status
												when 'ALL' then ipm.policy_status
												else @p_policy_status
											end
			and ipm.policy_payment_status = case @p_policy_payment_status
												when 'ALL' then ipm.policy_payment_status
												else @p_policy_payment_status
											end
			and ipm.policy_payment_type	  = case @p_insurance_payment_type
												when 'ALL' then policy_payment_type
												else @p_insurance_payment_type
											end
			and isnull(cast(ipm.policy_exp_date as date), '')
			between case cast(@p_from_date as date)
						when '' then isnull(cast(ipm.policy_exp_date as date), '')
						else cast(@p_from_date as date)
					end and case cast(@p_to_date as date)
								when '' then isnull(cast(ipm.policy_exp_date as date), '')
								else cast(@p_to_date as date)
							end
			and
			(
				ipm.policy_no											like '%' + @p_keywords + '%'
				or	ipm.branch_name										like '%' + @p_keywords + '%'
				or	mi.insurance_name									like '%' + @p_keywords + '%'
				or	ipm.policy_status									like '%' + @p_keywords + '%'
				or	ipm.policy_payment_status							like '%' + @p_keywords + '%'
				or	convert(varchar(30), ipm.policy_eff_date, 103)		like '%' + @p_keywords + '%'
				or	convert(varchar(30), ipm.policy_exp_date, 103)		like '%' + @p_keywords + '%'
			) ;

	select		ipm.code
				,ipm.policy_no
				,ipm.branch_name
				,mi.insurance_name
				,ipm.policy_status
				,ipm.policy_payment_status
				,ipm.print_count
				,convert(varchar(30), ipm.policy_eff_date, 103) 'policy_eff_date'
				,convert(varchar(30), ipm.policy_exp_date, 103) 'policy_exp_date'
				,@rows_count									'rowcount'
	from		insurance_policy_main		   ipm
				left join dbo.master_insurance mi on (mi.code = ipm.insurance_code)
	--inner join dbo.asset ass on (ipm.fa_code = ass.code)
	where		ipm.branch_code				  = case @p_branch_code
													when 'ALL' then ipm.branch_code
													else @p_branch_code
												end
				and ipm.insurance_code		  = case @p_insurance_code
													when 'ALL' then ipm.insurance_code
													else @p_insurance_code
												end
				and ipm.policy_status		  = case @p_policy_status
													when 'ALL' then ipm.policy_status
													else @p_policy_status
												end
				and ipm.policy_payment_status = case @p_policy_payment_status
													when 'ALL' then ipm.policy_payment_status
													else @p_policy_payment_status
												end
				and ipm.policy_payment_type	  = case @p_insurance_payment_type
													when 'ALL' then policy_payment_type
													else @p_insurance_payment_type
												end
				and isnull(cast(ipm.policy_exp_date as date), '')
				between case cast(@p_from_date as date)
							when '' then isnull(cast(ipm.policy_exp_date as date), '')
							else cast(@p_from_date as date)
						end and case cast(@p_to_date as date)
									when '' then isnull(cast(ipm.policy_exp_date as date), '')
									else cast(@p_to_date as date)
								end
				and
				(
					ipm.policy_no											like '%' + @p_keywords + '%'
					or	ipm.branch_name										like '%' + @p_keywords + '%'
					or	mi.insurance_name									like '%' + @p_keywords + '%'
					or	ipm.policy_status									like '%' + @p_keywords + '%'
					or	ipm.policy_payment_status							like '%' + @p_keywords + '%'
					or	convert(varchar(30), ipm.policy_eff_date, 103)		like '%' + @p_keywords + '%'
					or	convert(varchar(30), ipm.policy_exp_date, 103)		like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 WHEN 1 THEN ipm.POLICY_STATUS
													 when 2 then ipm.policy_no
													 when 3 then ipm.branch_name
													 when 4 then cast(ipm.policy_eff_date as sql_variant)
													 when 5 then mi.insurance_name
													 when 6 then ipm.policy_payment_status
													 when 7 then cast(ipm.print_count as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ipm.policy_status
													 when 2 then ipm.policy_no
													 when 3 then ipm.branch_name
													 when 4 then cast(ipm.policy_eff_date as sql_variant)
													 when 5 then mi.insurance_name
													 when 6 then ipm.policy_payment_status
													 when 7 then cast(ipm.print_count as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
