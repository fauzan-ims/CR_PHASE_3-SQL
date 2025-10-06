CREATE PROCEDURE dbo.xsp_settlement_agreement_getrows
(
	@p_keywords	    nvarchar(50)
	,@p_pagenumber  int
	,@p_rowspage    int
	,@p_order_by    int
	,@p_sort_by	    nvarchar(5)
	,@p_branch_code	nvarchar(50)
	,@p_status		nvarchar(20)
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
	from	settlement_agreement sa
			inner join dbo.agreement_main am on (am.agreement_no = sa.agreement_no)
			outer apply
	(
		select	datediff(day, max(due_date), dbo.xfn_get_system_date()) 'maturity_days'
				,max(due_date) 'maturity_date'
		from	dbo.agreement_asset_amortization
		where	agreement_no = am.agreement_no
	) aaa
	where	sa.branch_code	= case @p_branch_code
								when 'ALL' then sa.branch_code
								else @p_branch_code
						  end 
	and		sa.status = case @p_status
						  		when 'ALL' then sa.status
						  		else @p_status
						  end 
	and		(
				am.agreement_external_no							like '%' + @p_keywords + '%'
				or	am.client_name									like '%' + @p_keywords + '%'
				or	convert(nvarchar(15), am.agreement_date, 103)	like '%' + @p_keywords + '%'
				or	am.branch_name									like '%' + @p_keywords + '%'
				or	am.agreement_status								like '%' + @p_keywords + '%'
				or	aaa.maturity_days								like '%' + @p_keywords + '%'
				or	convert(nvarchar(15), aaa.maturity_date, 103)	like '%' + @p_keywords + '%'
			) ;

	select		id
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
	from		settlement_agreement sa
				inner join dbo.agreement_main am on (am.agreement_no = sa.agreement_no)
				outer apply
	(
		select	datediff(day, max(due_date), dbo.xfn_get_system_date()) 'maturity_days'
				,max(due_date) 'maturity_date'
		from	dbo.agreement_asset_amortization
		where	agreement_no = am.agreement_no
	) aaa
	where		sa.branch_code	= case @p_branch_code
									when 'ALL' then sa.branch_code
									else @p_branch_code
							  end 
	and			sa.status = case @p_status
							  		when 'ALL' then sa.status
							  		else @p_status
							  end 
	and			(
					am.agreement_external_no							like '%' + @p_keywords + '%'
					or	am.client_name									like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), am.agreement_date, 103)	like '%' + @p_keywords + '%'
					or	am.branch_name									like '%' + @p_keywords + '%'
					or	am.agreement_status								like '%' + @p_keywords + '%'
					or	aaa.maturity_days								like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), aaa.maturity_date, 103)	like '%' + @p_keywords + '%'
				) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then am.agreement_external_no + am.client_name
													 when 2 then convert(nvarchar(15), am.agreement_date, 103)
													 when 3 then am.branch_name
													 when 4 then am.agreement_status
													 when 5 then cast(aaa.maturity_days as sql_variant)
													 when 6 then convert(nvarchar(15), aaa.maturity_date, 103)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then am.agreement_external_no + am.client_name
													   when 2 then convert(nvarchar(15), am.agreement_date, 103)
													   when 3 then am.branch_name
													   when 4 then am.agreement_status
													   when 5 then cast(aaa.maturity_days as sql_variant)
													   when 6 then convert(nvarchar(15), aaa.maturity_date, 103)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
