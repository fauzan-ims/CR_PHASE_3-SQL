--Alter, Rian 15/12/2022 menambahkan where condition 	FROM dbo.AGREEMENT_MAIN  WHERE MATURITY_CODE IS NULL

CREATE PROCEDURE dbo.xsp_settlement_agreement_for_maturity_request_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_branch_code	  nvarchar(50)
	,@p_maturity_days int
)
as
begin
	declare @rows_count			 int = 0
			,@outstanding_rental decimal(18, 2)
			,@maturity_days		 int ;

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

	declare @maturity_request table
	(
		id							bigint
		,outstanding_rental			decimal(18, 2)
		,overdue_invice				decimal(18, 2)
		,agreement_no				nvarchar(50)
		,agreement_external_no		nvarchar(50)
		,client_name				nvarchar(250)
		,agreement_date				nvarchar(50)
		,branch_code				nvarchar(50)
		,branch_name				nvarchar(250)
		,agreement_status			nvarchar(50)
		,maturity_days				bigint 
		,maturity_date				nvarchar(50)
		,count_extend				int
	)  

	insert into @maturity_request
	(
	    outstanding_rental,
	    overdue_invice,
	    agreement_no,
	    agreement_external_no,
	    client_name,
	    agreement_date,
	    branch_code,
	    branch_name,
	    agreement_status,
	    maturity_days,
	    maturity_date,
	    count_extend
	)

	select	dbo.xfn_agreement_get_os_principal(am.agreement_no, dbo.xfn_get_system_date(), null) 'outstanding_rental'
			,dbo.xfn_agreement_get_ovd_rental_amount(am.agreement_no, null) 'overdue_invice'
			,am.agreement_no
			,am.agreement_external_no
			,am.client_name
			,convert(nvarchar(15), am.agreement_date, 103) 'agreement_date'
			,am.branch_code
			,am.branch_name
			,am.agreement_status
			,mature.maturity_days
			,convert(nvarchar(15), mature.maturity_date, 103) 'maturity_date'
			,ma.count_extend
	from	agreement_main am with (nolock)
			outer apply
			(
				select	ain.maturity_date
						,datediff(day, dbo.xfn_get_system_date(), ain.maturity_date) 'maturity_days'
				from	dbo.agreement_information ain with (nolock)
				where	ain.agreement_no = am.agreement_no
			) mature
			outer apply
			(
				select	count(1) 'count_extend'
				from	dbo.maturity ma with (nolock)
				where	status in('APPROVE', 'POST')
				and		ma.agreement_no = am.AGREEMENT_NO
				and		ma.result = 'CONTINUE'
			) ma
	where	am.agreement_status	 = 'GO LIVE'
	and		mature.maturity_days <= @p_maturity_days
	and		am.branch_code			 = case @p_branch_code
										   when 'ALL' then am.branch_code
										   else @p_branch_code
									   end
			and am.agreement_no not in (select agreement_no from dbo.settlement_agreement sa   with (nolock)  where sa.status <> 'cancel')
			and am.agreement_no in (select distinct agreement_no from dbo.agreement_asset ass  with (nolock)  where ass.asset_status = 'rented')
			and am.agreement_no not in(	select	agreement_no from dbo.maturity mtr with (nolock) where mtr.status in ('hold', 'on process'))
			and
			(
				am.agreement_external_no																	like '%' + @p_keywords + '%'
				or	am.client_name																			like '%' + @p_keywords + '%'
				or	convert(nvarchar(15), am.agreement_date, 103)											like '%' + @p_keywords + '%'
				or	am.branch_name																			like '%' + @p_keywords + '%'
				or	am.agreement_status																		like '%' + @p_keywords + '%'
				or	dbo.xfn_agreement_get_os_principal(am.agreement_no, dbo.xfn_get_system_date(), null)	like '%' + @p_keywords + '%'
				or	dbo.xfn_agreement_get_ovd_rental_amount(am.agreement_no, null)							like '%' + @p_keywords + '%'
				or	mature.maturity_days																	like '%' + @p_keywords + '%'
				or	ma.count_extend																			like '%' + @p_keywords + '%'
				or	convert(nvarchar(15), mature.maturity_date, 103)										like '%' + @p_keywords + '%'
			) ;

	
	select	@rows_count = count(1)
	from	@maturity_request

	select		id,
                outstanding_rental,
                overdue_invice,
                agreement_no,
                agreement_external_no,
                client_name,
                agreement_date,
                branch_code,
                branch_name,
                agreement_status,
                maturity_days,
                maturity_date,
                count_extend
				,@rows_count 'rowcount'
	from		@maturity_request am 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then am.agreement_external_no + am.client_name
													 when 2 then am.branch_name
													 when 3 then cast(am.agreement_date as sql_variant)
													 when 4 then am.agreement_status
													 when 5 then cast(outstanding_rental as sql_variant)
													 when 6 then cast(overdue_invice as sql_variant)
													 when 7 then cast(am.maturity_days as sql_variant)
													 when 8 then cast(am.maturity_date as sql_variant)
													 when 9 then cast(am.count_extend as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then am.agreement_external_no + am.client_name
													   when 2 then am.branch_name
													   when 3 then cast(am.agreement_date as sql_variant)
													   when 4 then am.agreement_status
													   when 5 then cast(outstanding_rental as sql_variant)
														when 6 then cast(overdue_invice as sql_variant)
													   when 7 then cast(am.maturity_days as sql_variant)
													   when 8 then cast(am.maturity_date as sql_variant)
													   when 9 then cast(am.count_extend as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

	--if exists
	--(
	--	select	1
	--	from	sys_global_param
	--	where	code	  = 'HO'
	--			and value = @p_branch_code
	--)
	--begin
	--	set @p_branch_code = 'ALL' ;
	--end ;

	--select	@rows_count = count(1)
	--from	agreement_main am with (nolock)
	--		left join dbo.settlement_agreement sa with (nolock) ON (
	--													 sa.agreement_no = am.agreement_no
	--													 and   sa.status <> 'CANCEL'
	--												 ) 
	--		outer apply
	--		(
	--			select	ain.MATURITY_DATE
	--					,datediff(day, dbo.xfn_get_system_date(), ain.MATURITY_DATE) 'maturity_days'
	--			from	dbo.AGREEMENT_INFORMATION ain with (nolock)
	--			where	ain.AGREEMENT_NO = am.AGREEMENT_NO
	--		) mature
	--		outer apply
	--		(
	--			select	top 1
	--					aa.asset_status
	--			from	dbo.agreement_asset aa with (nolock)
	--			where	aa.agreement_no		= am.agreement_no
	--					and aa.asset_status = 'RENTED'
	--		) aa
	--		outer apply
	--		(
	--			select	count(1) 'count_extend'
	--			from	dbo.maturity ma with (nolock)
	--			where	status in
	--							(
	--								'APPROVE', 'POST'
	--							)
	--					and ma.agreement_no = am.AGREEMENT_NO
	--		) ma
	--where	am.branch_code			 = case @p_branch_code
	--									   when 'ALL' then am.branch_code
	--									   else @p_branch_code
	--								   end
	--		--and		am.maturity_code is null
	--		and sa.id is null
	--		and am.agreement_status	 = 'GO LIVE'
	--		and mature.maturity_days <= @p_maturity_days
	--		and am.agreement_no not in
	--			(
	--				select	agreement_no
	--				from	dbo.maturity with (nolock)
	--				--where ((result = 'CONTINUE' and status in ('HOLD','ON PROCESS')) or (RESULT = 'STOP'))
	--				where	(
	--							(
	--								result = 'CONTINUE'
	--								or	RESULT = 'STOP'
	--							)
	--							and status in
	--(
	--	'HOLD', 'ON PROCESS'
	--)
	--						)
	--			)
	--		and aa.asset_status		 = 'RENTED'
	--		and
	--		(
	--			am.agreement_external_no																	like '%' + @p_keywords + '%'
	--			or	am.client_name																			like '%' + @p_keywords + '%'
	--			or	convert(nvarchar(15), am.agreement_date, 103)											like '%' + @p_keywords + '%'
	--			or	am.branch_name																			like '%' + @p_keywords + '%'
	--			or	am.agreement_status																		like '%' + @p_keywords + '%'
	--			or	dbo.xfn_agreement_get_os_principal(am.agreement_no, dbo.xfn_get_system_date(), null)	like '%' + @p_keywords + '%'
	--			or	dbo.xfn_agreement_get_ovd_rental_amount(am.agreement_no, null)							like '%' + @p_keywords + '%'
	--			or	mature.maturity_days																	like '%' + @p_keywords + '%'
	--			or	ma.count_extend																			like '%' + @p_keywords + '%'
	--			or	convert(nvarchar(15), mature.maturity_date, 103)										like '%' + @p_keywords + '%'
	--		) ;

	--select		id
	--			,dbo.xfn_agreement_get_os_principal(am.agreement_no, dbo.xfn_get_system_date(), null) 'outstanding_rental'
	--			,dbo.xfn_agreement_get_ovd_rental_amount(am.agreement_no, null) 'overdue_invice'
	--			,am.agreement_no
	--			,am.agreement_external_no
	--			,am.client_name
	--			,convert(nvarchar(15), am.agreement_date, 103) 'agreement_date'
	--			,am.branch_code
	--			,am.branch_name
	--			,am.agreement_status
	--			,mature.maturity_days
	--			,convert(nvarchar(15), mature.maturity_date, 103) 'maturity_date'
	--			,ma.count_extend
	--			,@rows_count 'rowcount'
	--from		agreement_main am with (nolock)
	--			left join dbo.settlement_agreement sa with (nolock) on (
	--														 sa.agreement_no = am.agreement_no
	--														 and   sa.status <> 'CANCEL'
	--													 ) 
	--			outer apply
	--			(
	--				select	ain.MATURITY_DATE
	--						,datediff(day, dbo.xfn_get_system_date(), ain.MATURITY_DATE) 'maturity_days'
	--				from	dbo.AGREEMENT_INFORMATION ain with (nolock)
	--				where	ain.AGREEMENT_NO = am.AGREEMENT_NO
	--			) mature
	--			outer apply
	--			(
	--				select	top 1
	--						aa.asset_status
	--				from	dbo.agreement_asset aa with (nolock)
	--				where	aa.agreement_no		= am.agreement_no
	--						and aa.asset_status = 'RENTED'
	--			) aa
	--			outer apply
	--			(
	--				select	count(1) 'count_extend'
	--				from	dbo.maturity ma with (nolock)
	--				where	status in
	--								(
	--									'APPROVE', 'POST'
	--								)
	--						and ma.agreement_no = am.AGREEMENT_NO
	--			) ma
	--where		am.branch_code			 = case @p_branch_code
	--										   when 'ALL' then am.branch_code
	--										   else @p_branch_code
	--									   end
	--			--and			am.maturity_code is null
	--			and sa.id is null
	--			and am.agreement_status	 = 'GO LIVE'
	--			and mature.maturity_days <= @p_maturity_days
	--			and am.agreement_no not in
	--				(
	--					select	agreement_no
	--					from	dbo.maturity with (nolock)
	--					--where ((result = 'CONTINUE' and status in ('HOLD','ON PROCESS')) or (RESULT = 'STOP'))
	--					where	(
	--								(
	--									result = 'CONTINUE'
	--									or	RESULT = 'STOP'
	--								)
	--								and status in
	--(
	--	'HOLD', 'ON PROCESS'
	--)
	--							)
	--				)
	--			and aa.asset_status		 = 'RENTED'
	--			and
	--			(
	--				am.agreement_external_no																	like '%' + @p_keywords + '%'
	--				or	am.client_name																			like '%' + @p_keywords + '%'
	--				or	convert(nvarchar(15), am.agreement_date, 103)											like '%' + @p_keywords + '%'
	--				or	am.branch_name																			like '%' + @p_keywords + '%'
	--				or	am.agreement_status																		like '%' + @p_keywords + '%'
	--				or	dbo.xfn_agreement_get_os_principal(am.agreement_no, dbo.xfn_get_system_date(), null)	like '%' + @p_keywords + '%'
	--				or	dbo.xfn_agreement_get_ovd_rental_amount(am.agreement_no, null)							like '%' + @p_keywords + '%'
	--				or	mature.maturity_days																	like '%' + @p_keywords + '%'
	--				or	ma.count_extend																			like '%' + @p_keywords + '%'
	--				or	convert(nvarchar(15), mature.maturity_date, 103)										like '%' + @p_keywords + '%'
	--			)
	--order by	case
	--				when @p_sort_by = 'asc' then case @p_order_by
	--												 when 1 then am.agreement_external_no + am.client_name
	--												 when 2 then am.branch_name
	--												 when 3 then cast(am.agreement_date as sql_variant)
	--												 when 4 then am.agreement_status
	--												 when 5 then cast(dbo.xfn_agreement_get_ovd_rental_amount(am.agreement_no, null) as sql_variant)
	--												 when 6 then cast(dbo.xfn_agreement_get_os_principal(am.agreement_no, dbo.xfn_get_system_date(), null) as sql_variant)
	--												 when 7 then cast(mature.maturity_days as sql_variant)
	--												 when 8 then cast(mature.maturity_date as sql_variant)
	--												 when 9 then cast(ma.count_extend as sql_variant)
	--											 end
	--			end asc
	--			,case
	--				 when @p_sort_by = 'desc' then case @p_order_by
	--												   when 1 then am.agreement_external_no + am.client_name
	--												   when 2 then am.branch_name
	--												   when 3 then cast(am.agreement_date as sql_variant)
	--												   when 4 then am.agreement_status
	--												   when 5 then cast(dbo.xfn_agreement_get_ovd_rental_amount(am.agreement_no, null) as sql_variant)
	--												   when 6 then cast(dbo.xfn_agreement_get_os_principal(am.agreement_no, dbo.xfn_get_system_date(), null) as sql_variant)
	--												   when 7 then cast(mature.maturity_days as sql_variant)
	--												   when 8 then cast(mature.maturity_date as sql_variant)
	--												   when 9 then cast(ma.count_extend as sql_variant)
	--											   end
	--			 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
