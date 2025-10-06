CREATE PROCEDURE dbo.xsp_agreement_main_getrows
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	,@p_branch_code		 nvarchar(50)
	,@p_agreement_status nvarchar(20)
	,@p_obligation_type	 nvarchar(20) = 'ALL'
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
	from	agreement_main am with (nolock)
			inner join dbo.agreement_information ai with (nolock) on (ai.agreement_no = am.agreement_no)
	where	branch_code			 = case @p_branch_code
									   when 'ALL' then branch_code
									   else @p_branch_code
								   end
			and agreement_status = case @p_agreement_status
									   when 'ALL' then agreement_status
									   else @p_agreement_status
								   end
			and
			(
				am.agreement_external_no												like '%' + @p_keywords + '%'
				or	am.client_name														like '%' + @p_keywords + '%'
				or	am.facility_name													like '%' + @p_keywords + '%'
				or	am.branch_name														like '%' + @p_keywords + '%'
				or	convert(varchar(30), am.agreement_date, 103)						like '%' + @p_keywords + '%'
				or	am.agreement_status													like '%' + @p_keywords + '%'
				or	case
						when am.agreement_sub_status <> '' then am.agreement_sub_status
						else am.opl_status
					end																	like '%' + @p_keywords + '%'
				or	convert(varchar(30), am.termination_date, 103)						like '%' + @p_keywords + '%'
				or	case @p_obligation_type
						when 'OVDP' then isnull(ai.ovd_days, 0)
						when 'LRAP' then isnull(ai.lra_days, 0)
					end																	like '%' + @p_keywords + '%'
				or	isnull(ai.ovd_days, 0)												like '%' + @p_keywords + '%'
				or	isnull(ai.lra_days, 0)												like '%' + @p_keywords + '%'
				or	isnull(ai.ovd_penalty_amount, 0)									like '%' + @p_keywords + '%'
				or	isnull(ai.lra_penalty_amount, 0)									like '%' + @p_keywords + '%'
				or	am.termination_status												like '%' + @p_keywords + '%'
			) ;

	select		am.agreement_no
				,am.agreement_external_no
				,am.client_name
				,am.facility_name
				,am.branch_name
				,convert(varchar(30), am.agreement_date, 103) 'agreement_date'
				,am.agreement_status
				,convert(varchar(30), am.termination_date, 103) 'termination_date'
				,case
					 when isnull(am.agreement_sub_status, '') <> '' then am.agreement_sub_status
					 else am.opl_status
				 end 'agreement_sub_status'
				,case @p_obligation_type
					 when 'OVDP' then isnull(ai.ovd_days, 0)
					 when 'LRAP' then isnull(ai.lra_days, 0)
				 end 'ovd_or_lra_day'
				,isnull(ai.ovd_days, 0) 'ovd_days'
				,isnull(ai.lra_days, 0) 'lra_days'
				,isnull(ai.ovd_penalty_amount, 0) 'ovd_penalty_amount'
				,isnull(ai.lra_penalty_amount, 0) 'lra_penalty_amount'
				,am.termination_status
				,@rows_count 'rowcount'
	from		agreement_main am with (nolock)
				inner join dbo.agreement_information ai with (nolock) ON (ai.agreement_no = am.agreement_no)
	where		branch_code			 = case @p_branch_code
										   when 'ALL' then branch_code
										   else @p_branch_code
									   end
				and agreement_status = case @p_agreement_status
										   when 'ALL' then agreement_status
										   else @p_agreement_status
									   end
				and
				(
					am.agreement_external_no												like '%' + @p_keywords + '%'
					or	am.client_name														like '%' + @p_keywords + '%'
					or	am.facility_name													like '%' + @p_keywords + '%'
					or	am.branch_name														like '%' + @p_keywords + '%'
					or	convert(varchar(30), am.agreement_date, 103)						like '%' + @p_keywords + '%'
					or	am.agreement_status													like '%' + @p_keywords + '%'
					or	case
							when am.agreement_sub_status <> '' then am.agreement_sub_status
							else am.opl_status
						end																	like '%' + @p_keywords + '%'
					or	convert(varchar(30), am.termination_date, 103)						like '%' + @p_keywords + '%'
					or	case @p_obligation_type
							when 'OVDP' then isnull(ai.ovd_days, 0)
							when 'LRAP' then isnull(ai.lra_days, 0)
						end																	like '%' + @p_keywords + '%'
					or	isnull(ai.ovd_days, 0)												like '%' + @p_keywords + '%'
					or	isnull(ai.lra_days, 0)												like '%' + @p_keywords + '%'
					or	isnull(ai.ovd_penalty_amount, 0)									like '%' + @p_keywords + '%'
					or	isnull(ai.lra_penalty_amount, 0)									like '%' + @p_keywords + '%'
					or	am.termination_status												like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then am.agreement_external_no
													 when 2 then am.branch_name
													 when 3 then cast(am.agreement_date as sql_variant)
													 when 4 then cast(am.termination_date as sql_variant) 
													 when 5 then cast(isnull(ai.ovd_days, 0) as sql_variant)
													 when 6 then cast(isnull(ai.lra_days, 0) as sql_variant)
													 when 7 then am.agreement_status
													 when 8 then am.termination_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then am.agreement_external_no
													 when 2 then am.branch_name
													 when 3 then cast(am.agreement_date as sql_variant)
													 when 4 then cast(am.termination_date as sql_variant) 
													 when 5 then cast(isnull(ai.ovd_days, 0) as sql_variant)
													 when 6 then cast(isnull(ai.lra_days, 0) as sql_variant)
													 when 7 then am.agreement_status
													 when 8 then am.termination_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
