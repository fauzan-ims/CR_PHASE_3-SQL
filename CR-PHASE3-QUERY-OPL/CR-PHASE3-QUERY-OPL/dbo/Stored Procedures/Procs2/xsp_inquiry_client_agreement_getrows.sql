CREATE PROCEDURE [dbo].[xsp_inquiry_client_agreement_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	--
	,@p_client_no  nvarchar(50)
)
as
begin
	create table #temp_table
	(
		agreement_no			  nvarchar(50)
		,client_name			  nvarchar(250)
		,branch_name			  nvarchar(250)
		,agreement_date			  datetime
		,total_unit				  int
		,total_ovd_days			  int
		,total_ovd_amount		  decimal(18, 2)
		,total_late_return_days	  int
		,total_late_return_amount decimal(18, 2)
		,agreement_status		  nvarchar(50)
		,termination_status		  nvarchar(50)
		,termination_date		  datetime
	) ;

	declare @rows_count int = 0 ;

	insert into #temp_table
	(
		agreement_no
		,client_name
		,branch_name
		,agreement_date
		,total_unit
		,total_ovd_days
		,total_ovd_amount
		,total_late_return_days
		,total_late_return_amount
		,agreement_status
		,termination_status
		,termination_date
	)
	select	distinct
			am.agreement_external_no
			,am.client_name
			,am.branch_name
			,am.agreement_date
			,agreement_asset.total_unit
			,isnull(ao.obligation_day,0)
			,isnull(ao.obligation_amount,0)
			,isnull(ai.lra_days, 0)
			,isnull(ai.lra_penalty_amount, 0)
			,am.agreement_status
			,am.termination_status
			,am.termination_date
	from	dbo.agreement_main			   am
			inner join dbo.agreement_asset aas on aas.agreement_no = am.agreement_no
			inner join dbo.agreement_information ai on (ai.agreement_no = am.agreement_no)
			outer apply
	(
		select		count(1) 'total_unit'
					,aa.agreement_no
		from		dbo.agreement_asset aa
		where		aa.agreement_no = am.agreement_no
		group by	aa.agreement_no
	)									   agreement_asset
			outer apply
	(
		select	sum(ao.obligation_day)	   obligation_day
				,sum(ao.obligation_amount) obligation_amount
		from	dbo.agreement_obligation ao with (nolock)
				outer apply
		(
			select	isnull(sum(aop.payment_amount), 0) payment_amount
			from	dbo.agreement_obligation_payment aop with (nolock)
			where	aop.obligation_code = ao.code
		)								 aop
		where	ao.asset_no			   = aas.asset_no
				and ao.agreement_no	   = aas.agreement_no
				and ao.cre_by		   <> 'MIGRASI'
				and ao.obligation_type in
	(
		N'OVDP', N'LRAP'
	)
				and aop.payment_amount = 0
	) ao
	where	am.client_no = @p_client_no ;

	select	@rows_count = count(1)
	from	#temp_table
	where	(
				agreement_no										like '%' + @p_keywords + '%'
				or	client_name										like '%' + @p_keywords + '%'
				or	branch_name										like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), agreement_date, 103)		like '%' + @p_keywords + '%'
				or	total_unit										like '%' + @p_keywords + '%'
				or	total_ovd_days									like '%' + @p_keywords + '%'
				or	total_ovd_amount								like '%' + @p_keywords + '%'
				or	total_late_return_days							like '%' + @p_keywords + '%'
				or	total_late_return_amount						like '%' + @p_keywords + '%'
				or	agreement_status								like '%' + @p_keywords + '%'
				or	termination_status								like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), termination_date, 103)	like '%' + @p_keywords + '%'
			) ;

	select		agreement_no
				,client_name
				,branch_name
				,convert(nvarchar(30), agreement_date, 103)	  'agreement_date'
				,total_unit
				,total_ovd_days
				,total_ovd_amount
				,total_late_return_days
				,total_late_return_amount
				,agreement_status
				,termination_status
				,convert(nvarchar(30), termination_date, 103) 'termination_date'
				,@rows_count								  'rowcount'
	from		#temp_table
	where		(
					agreement_no										like '%' + @p_keywords + '%'
					or	client_name										like '%' + @p_keywords + '%'
					or	branch_name										like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), agreement_date, 103)		like '%' + @p_keywords + '%'
					or	total_unit										like '%' + @p_keywords + '%'
					or	total_ovd_days									like '%' + @p_keywords + '%'
					or	total_ovd_amount								like '%' + @p_keywords + '%'
					or	total_late_return_days							like '%' + @p_keywords + '%'
					or	total_late_return_amount						like '%' + @p_keywords + '%'
					or	agreement_status								like '%' + @p_keywords + '%'
					or	termination_status								like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), termination_date, 103)	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then agreement_no
													 when 2 then branch_name
													 when 3 then cast(agreement_date as sql_variant)
													 when 4 then total_unit
													 when 5 then total_ovd_days
													 when 6 then total_late_return_days
													 when 7 then agreement_status
													 when 8 then termination_status
													 when 9 then cast(termination_date as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then agreement_no
													   when 2 then branch_name
													   when 3 then cast(agreement_date as sql_variant)
													   when 4 then total_unit
													   when 5 then total_ovd_days
													   when 6 then total_late_return_days
													   when 7 then agreement_status
													   when 8 then termination_status
													   when 9 then cast(termination_date as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
