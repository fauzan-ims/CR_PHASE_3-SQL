CREATE PROCEDURE dbo.xsp_agreement_asset_getrows_backup
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_agreement_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	agreement_asset ast with (nolock)
			outer apply
	(
		select	sum(ao.obligation_day) obligation_day
				,sum(ao.obligation_amount) obligation_amount
		from	dbo.agreement_obligation ao with (nolock)
	--LEFT JOIN dbo.AGREEMENT_OBLIGATION_PAYMENT aop WITH (NOLOCK) ON (aop.OBLIGATION_CODE = ao.CODE)
				outer apply
		(
			select	isnull(sum(aop.payment_amount), 0) payment_amount
			from	dbo.agreement_obligation_payment aop with (nolock)
			where	aop.obligation_code = ao.code
		) aop
		where	ao.asset_no			   = ast.asset_no
				and ao.agreement_no = ast.agreement_no
				and ao.cre_by		   <> 'MIGRASI'
				and ao.obligation_type in
	(
		N'OVDP', N'LRAP'
	)
				and aop.payment_amount = 0
	) ao
			left join dbo.sys_general_subcode sgs with (nolock) on (
														  ast.asset_type_code	= sgs.code
														  and  sgs.general_code = 'ASTPRT'
													  )
	where	ast.agreement_no = @p_agreement_no
			and
			(
				ast.asset_no									like '%' + @p_keywords + '%'
				or	ast.asset_name								like '%' + @p_keywords + '%'
				or	sgs.description								like '%' + @p_keywords + '%'
				or	ast.fa_reff_no_01							like '%' + @p_keywords + '%'
				or	ast.replacement_fa_reff_no_01				like '%' + @p_keywords + '%'
				or	ast.fa_reff_no_02							like '%' + @p_keywords + '%'
				or	ast.replacement_fa_reff_no_02				like '%' + @p_keywords + '%'
				or	ast.fa_reff_no_03							like '%' + @p_keywords + '%'
				or	ast.replacement_fa_reff_no_03				like '%' + @p_keywords + '%'
				or	ast.asset_year								like '%' + @p_keywords + '%'
				or	ast.asset_condition							like '%' + @p_keywords + '%'
				or	ast.lease_round_amount						like '%' + @p_keywords + '%'
				or	ast.net_margin_amount						like '%' + @p_keywords + '%'
				or	ast.lease_amount							like '%' + @p_keywords + '%'
				or	ast.asset_status							like '%' + @p_keywords + '%'
				or	ao.obligation_day							like '%' + @p_keywords + '%'
				or	ao.obligation_amount						like '%' + @p_keywords + '%'
			) ;

	select		ast.asset_no
				,ast.asset_name
				,ast.asset_year
				,ast.asset_condition
				,sgs.description 'asset_type'
				,ast.lease_round_amount
				--,ast.lease_amount
				,ast.net_margin_amount
				,ast.asset_status
				,ast.lease_rounded_amount 'lease_amount'
				,isnull(ast.fa_reff_no_01, ast.replacement_fa_reff_no_01) 'fa_reff_no_01'
				,isnull(ast.fa_reff_no_02, ast.replacement_fa_reff_no_02) 'fa_reff_no_02'
				,isnull(ast.fa_reff_no_03, ast.replacement_fa_reff_no_03) 'fa_reff_no_03'
				,ao.obligation_day
				,ao.obligation_amount
				--,convert(varchar(30), aippp.trx_payment_date, 103) 'payment_date'
				--,convert(varchar(30), aippp.value_payment_date, 103) 'value_date'
				,@rows_count 'rowcount'
	from		agreement_asset ast with (nolock)
				outer apply
	(
		select	sum(ao.obligation_day) obligation_day
				,sum(ao.obligation_amount) obligation_amount
		from	dbo.agreement_obligation ao with (nolock)
	--LEFT JOIN dbo.AGREEMENT_OBLIGATION_PAYMENT aop WITH (NOLOCK) ON (aop.OBLIGATION_CODE = ao.CODE)
				outer apply
		(
			select	isnull(sum(aop.payment_amount), 0) payment_amount
			from	dbo.agreement_obligation_payment aop with (nolock)
			where	aop.obligation_code = ao.code
		) aop
		where	ao.asset_no			   = ast.asset_no
				and ao.agreement_no = ast.agreement_no
				and ao.cre_by		   <> 'MIGRASI'
				and ao.obligation_type in
	(
		N'OVDP', N'LRAP'
	)
				and aop.payment_amount = 0
	) ao
				left join dbo.sys_general_subcode sgs with (nolock) on (
															  ast.asset_type_code	= sgs.code
															  and  sgs.general_code = 'ASTPRT'
														  )
	where		ast.agreement_no = @p_agreement_no
				and
				(
					ast.asset_no									like '%' + @p_keywords + '%'
					or	ast.asset_name								like '%' + @p_keywords + '%'
					or	sgs.description								like '%' + @p_keywords + '%'
					or	ast.fa_reff_no_01							like '%' + @p_keywords + '%'
					or	ast.replacement_fa_reff_no_01				like '%' + @p_keywords + '%'
					or	ast.fa_reff_no_02							like '%' + @p_keywords + '%'
					or	ast.replacement_fa_reff_no_02				like '%' + @p_keywords + '%'
					or	ast.fa_reff_no_03							like '%' + @p_keywords + '%'
					or	ast.replacement_fa_reff_no_03				like '%' + @p_keywords + '%'
					or	ast.asset_year								like '%' + @p_keywords + '%'
					or	ast.asset_condition							like '%' + @p_keywords + '%'
					or	ast.lease_round_amount						like '%' + @p_keywords + '%'
					or	ast.net_margin_amount						like '%' + @p_keywords + '%'
					or	ast.lease_amount							like '%' + @p_keywords + '%'
					or	ast.asset_status							like '%' + @p_keywords + '%'
					or	ao.obligation_day							like '%' + @p_keywords + '%'
					or	ao.obligation_amount						like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ast.asset_no
													 when 3 then isnull(ast.fa_reff_no_01, ast.replacement_fa_reff_no_01) + isnull(ast.fa_reff_no_02, ast.replacement_fa_reff_no_02) + isnull(ast.fa_reff_no_03, ast.replacement_fa_reff_no_03)
													 when 4 then sgs.description
													 when 5 then ast.asset_year
													 when 6 then ast.asset_condition
													 when 7 then cast(ast.lease_amount as sql_variant)
													 when 8 then cast(ao.obligation_day as sql_variant)
													 when 9 then cast(ao.obligation_amount as sql_variant)
													 when 10 then ast.asset_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then ast.asset_no
													   when 3 then isnull(ast.fa_reff_no_01, ast.replacement_fa_reff_no_01) + isnull(ast.fa_reff_no_02, ast.replacement_fa_reff_no_02) + isnull(ast.fa_reff_no_03, ast.replacement_fa_reff_no_03)
													   when 4 then sgs.description
													   when 5 then ast.asset_year
													   when 6 then ast.asset_condition
													   when 7 then cast(ast.lease_amount as sql_variant)
													   when 8 then cast(ao.obligation_day as sql_variant)
													   when 9 then cast(ao.obligation_amount as sql_variant)
													   when 10 then ast.asset_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
