CREATE PROCEDURE dbo.xsp_maturity_getrows
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

	DECLARE  @agreement_asset_amortization table
	(
		maturity_days		int				
		,max_due_date		datetime		
		,agreement_no		NVARCHAR(50)	
	)
    
	INSERT INTO @agreement_asset_amortization
	(
	    maturity_days,
	    max_due_date,
		agreement_no
	)
	select	datediff(day, max(due_date), dbo.xfn_get_system_date()) 'maturity_days'
					,max(due_date) 'maturity_date'
					,AGREEMENT_NO
	from	dbo.agreement_asset_amortization
	GROUP BY AGREEMENT_NO


	select	@rows_count = count(1)
	from	maturity ma
			inner join dbo.agreement_main am on (am.agreement_no = ma.agreement_no)
			INNER JOIN @agreement_asset_amortization aaa ON aaa.agreement_no = ma.AGREEMENT_NO
			--outer apply
			--(
			--	select	datediff(day, max(due_date), dbo.xfn_get_system_date()) 'maturity_days'
			--			,max(due_date) 'maturity_date'
			--	from	dbo.agreement_asset_amortization
			--	where	agreement_no = am.agreement_no
			--) aaa
	where	ma.branch_code	= case @p_branch_code
								when 'ALL' then ma.branch_code
								else @p_branch_code
						  end
	and		ma.status = case @p_status
						  		when 'ALL' then ma.status
						  		else @p_status
						  end 
	and		(
				am.agreement_external_no																	like '%' + @p_keywords + '%'
				or	am.client_name																			like '%' + @p_keywords + '%'
				or	convert(nvarchar(15), ma.date, 103)														like '%' + @p_keywords + '%'
				or	am.branch_name																			like '%' + @p_keywords + '%'
				--or	am.agreement_status																		like '%' + @p_keywords + '%'
				or	ma.status																				like '%' + @p_keywords + '%'
				or	aaa.maturity_days																		like '%' + @p_keywords + '%'
				or	convert(nvarchar(15), aaa.max_due_date, 103)											like '%' + @p_keywords + '%'
				--or	dbo.xfn_agreement_get_os_principal(am.agreement_no, dbo.xfn_get_system_date(), null)	like '%' + @p_keywords + '%'
				--or	dbo.xfn_agreement_get_ovd_rental_amount(am.agreement_no, null)							like '%' + @p_keywords + '%'
			) ;

	select		ma.code
				--,dbo.xfn_agreement_get_os_principal(am.agreement_no, dbo.xfn_get_system_date(), null) 'outstanding_rental'
				--,dbo.xfn_agreement_get_ovd_rental_amount(am.agreement_no, null) 'overdue_invice'
				,0 'outstanding_rental'
				,0 'overdue_invice'
				,am.agreement_external_no
				,ma.agreement_no
				,am.client_name
				,convert(nvarchar(15), ma.date, 103) 'agreement_date'
				,ma.branch_code
				,ma.branch_name
				,ma.status
				,aaa.maturity_days
				,convert(nvarchar(15), aaa.max_due_date, 103) 'maturity_date'
				,@rows_count 'rowcount'
	from		maturity ma
				inner join dbo.agreement_main am on (am.agreement_no = ma.agreement_no)
				INNER JOIN @agreement_asset_amortization aaa ON aaa.agreement_no = ma.AGREEMENT_NO
				--outer apply
				--(
				--	select	datediff(day, max(due_date), dbo.xfn_get_system_date()) 'maturity_days'
				--			,max(due_date) 'maturity_date'
				--	from	dbo.agreement_asset_amortization
				--	where	agreement_no = am.agreement_no
				--) aaa
	where		ma.branch_code	= case @p_branch_code
									when 'ALL' then ma.branch_code
									else @p_branch_code
							  end 
	and			ma.status = case @p_status
							  		when 'ALL' then ma.status
							  		else @p_status
							  end 
	and			(
					am.agreement_external_no																	like '%' + @p_keywords + '%'
					or	am.client_name																			like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), ma.date, 103)														like '%' + @p_keywords + '%'
					or	am.branch_name																			like '%' + @p_keywords + '%'
					--or	am.agreement_status																		like '%' + @p_keywords + '%'
					or	ma.status																				like '%' + @p_keywords + '%'
					or	aaa.maturity_days																		like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), aaa.max_due_date, 103)											like '%' + @p_keywords + '%'
					--or	dbo.xfn_agreement_get_os_principal(am.agreement_no, dbo.xfn_get_system_date(), null)	like '%' + @p_keywords + '%'
					--or	dbo.xfn_agreement_get_ovd_rental_amount(am.agreement_no, null)							like '%' + @p_keywords + '%'
				) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then am.agreement_external_no + am.client_name
													 when 2 then ma.branch_name
													 when 3 then cast(ma.date as sql_variant)
													 when 4 then cast(dbo.xfn_agreement_get_ovd_rental_amount(am.agreement_no, null) as sql_variant)
													 when 5 then cast(dbo.xfn_agreement_get_os_principal(am.agreement_no, dbo.xfn_get_system_date(), null) as sql_variant)
													 when 6 then cast(aaa.maturity_days as sql_variant)
													 when 7 then cast(aaa.max_due_date as sql_variant)
													 when 8 then ma.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then am.agreement_external_no + am.client_name
													 when 2 then ma.branch_name
													 when 3 then cast(ma.date as sql_variant)
													 when 4 then cast(dbo.xfn_agreement_get_ovd_rental_amount(am.agreement_no, null) as sql_variant)
													 when 5 then cast(dbo.xfn_agreement_get_os_principal(am.agreement_no, dbo.xfn_get_system_date(), null) as sql_variant)
													 when 6 then cast(aaa.maturity_days as sql_variant)
													 when 7 then cast(aaa.max_due_date as sql_variant)
													 when 8 then ma.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
