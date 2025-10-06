--Created by, Rian at 16/06/2023 

create PROCEDURE dbo.xsp_settlement_agreement_for_maturity_dashboard_getrows
(
	@p_keywords	      nvarchar(50)
	,@p_pagenumber    int
	,@p_rowspage      int
	,@p_order_by      int
	,@p_sort_by	      nvarchar(5)
	,@p_branch_code	  nvarchar(50) 
	,@p_maturity_days int
)
as
begin
	declare @rows_count				int = 0 
			,@outstanding_rental	decimal(18, 2)
			,@maturity_days			int;

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
	from	agreement_main am
			left join dbo.settlement_agreement sa on (sa.agreement_no = am.agreement_no and sa.status <> 'CANCEL') 
			outer apply
	(
		select	datediff(day, dbo.xfn_get_system_date(), max(due_date)) 'maturity_days'
				,max(due_date) 'maturity_date'
		from	dbo.agreement_asset_amortization
		where	agreement_no = am.agreement_no
	) aaa
	where	am.branch_code	= case @p_branch_code
								when 'ALL' then am.branch_code
								else @p_branch_code
						  end 
	and		am.maturity_code is null
	and		sa.id is null
	and		aaa.maturity_days <= @p_maturity_days
	and		(
				am.agreement_external_no																		like '%' + @p_keywords + '%'
				or	am.client_name																				like '%' + @p_keywords + '%'
				or	convert(nvarchar(15), am.agreement_date, 103)												like '%' + @p_keywords + '%'
				or	am.branch_name																				like '%' + @p_keywords + '%'
				or	am.agreement_status																			like '%' + @p_keywords + '%'
				or	dbo.xfn_agreement_get_os_principal(am.agreement_no, dbo.xfn_get_system_date(), null)		like '%' + @p_keywords + '%'
				or	dbo.xfn_agreement_get_ovd_rental_amount(am.agreement_no, null)								like '%' + @p_keywords + '%'
				or	aaa.maturity_days																			like '%' + @p_keywords + '%'
				or	convert(nvarchar(15), aaa.maturity_date, 103)												like '%' + @p_keywords + '%'
			) ;

	select		id
				,dbo.xfn_agreement_get_os_principal(am.agreement_no, dbo.xfn_get_system_date(), null) 'outstanding_rental'
				,dbo.xfn_agreement_get_ovd_rental_amount(am.agreement_no, null) 'overdue_invice'
				,am.agreement_no
				,am.agreement_external_no
				,am.client_name
				,convert(nvarchar(15), am.agreement_date, 103) 'agreement_date'
				,am.branch_code
				,am.branch_name
				,am.agreement_status
				,aaa.maturity_days
				,convert(nvarchar(15), aaa.maturity_date, 103) 'maturity_date'
				,@rows_count 'rowcount'
	from	agreement_main am
			left join dbo.settlement_agreement sa on (sa.agreement_no = am.agreement_no and sa.status <> 'CANCEL')
			outer apply
	(
		select	datediff(day, dbo.xfn_get_system_date(), max(due_date)) 'maturity_days'
				,max(due_date) 'maturity_date'
		from	dbo.agreement_asset_amortization
		where	agreement_no = am.agreement_no
	) aaa
	where	am.branch_code	= case @p_branch_code
								when 'ALL' then am.branch_code
								else @p_branch_code
						  end  
	and		am.maturity_code is null
	and		sa.id is null
	and			aaa.maturity_days <= @p_maturity_days
	and			(
					am.agreement_external_no																		like '%' + @p_keywords + '%'
					or	am.client_name																				like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), am.agreement_date, 103)												like '%' + @p_keywords + '%'
					or	am.branch_name																				like '%' + @p_keywords + '%'
					or	am.agreement_status																			like '%' + @p_keywords + '%'
					or	dbo.xfn_agreement_get_os_principal(am.agreement_no, dbo.xfn_get_system_date(), null)		like '%' + @p_keywords + '%'
					or	dbo.xfn_agreement_get_ovd_rental_amount(am.agreement_no, null)								like '%' + @p_keywords + '%'
					or	aaa.maturity_days																			like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), aaa.maturity_date, 103)												like '%' + @p_keywords + '%'
				) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then am.agreement_external_no + am.client_name
													 when 2 then am.branch_name
													 when 3 then convert(nvarchar(15), am.agreement_date, 103)
													 when 4 then am.agreement_status
													 when 5 then cast(dbo.xfn_agreement_get_ovd_rental_amount(am.agreement_no, null) as sql_variant)
													 when 6 then cast(dbo.xfn_agreement_get_os_principal(am.agreement_no, dbo.xfn_get_system_date(), null) as sql_variant)
													 when 7 then cast(aaa.maturity_days as sql_variant)
													 when 8 then convert(nvarchar(15), aaa.maturity_date, 103)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then am.agreement_external_no + am.client_name
													 when 2 then am.branch_name
													 when 3 then convert(nvarchar(15), am.agreement_date, 103)
													 when 4 then am.agreement_status
													 when 5 then cast(dbo.xfn_agreement_get_ovd_rental_amount(am.agreement_no, null) as sql_variant)
													 when 6 then cast(dbo.xfn_agreement_get_os_principal(am.agreement_no, dbo.xfn_get_system_date(), null) as sql_variant)
													 when 7 then cast(aaa.maturity_days as sql_variant)
													 when 8 then convert(nvarchar(15), aaa.maturity_date, 103)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
