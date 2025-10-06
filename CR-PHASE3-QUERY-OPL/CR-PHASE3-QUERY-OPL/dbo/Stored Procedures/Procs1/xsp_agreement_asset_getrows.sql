CREATE PROCEDURE dbo.xsp_agreement_asset_getrows
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 INT
	,@p_rowspage	 INT
	,@p_order_by	 INT
	,@p_sort_by		 NVARCHAR(5)
	,@p_agreement_no NVARCHAR(50)
)
as
BEGIN
	DECLARE @rows_count INT = 0 ;

	declare @temptable table
	(
		obligation_day		bigint
		,obligation_amount	decimal(18,2)
		,asset_no			nvarchar(50)
		,agreement_no		nvarchar(50)
	
	)
	insert into @temptable --dibuat raffy 2025/09/11 agar lebih ringan 
	(
	    obligation_day,
	    obligation_amount,
	    asset_no,
	    agreement_no
	)
	select
		sum(ao.obligation_day) as obligation_day,
		sum(ao.obligation_amount) as obligation_amount,
		ao.asset_no,
		ao.agreement_no
	from dbo.agreement_obligation ao with (nolock)
	outer apply
	(
		select isnull(SUM(aop.payment_amount), 0) AS payment_amount
		from dbo.agreement_obligation_payment aop WITH (NOLOCK)
		where aop.obligation_code = ao.code
	) aop	
	where	ao.cre_by       <> 'MIGRASI'
			and ao.obligation_type IN (N'OVDP', N'LRAP')
			and aop.payment_amount = 0
	group by ao.asset_no, ao.agreement_no


	select	@rows_count = count(1)
	from	agreement_asset ast with (nolock)
	outer apply 
		(
			select	obligation_day
					, obligation_amount
			from	@temptable
			where	ast.asset_no = asset_no
					and agreement_no = ast.agreement_no
		)ao
	--		outer apply
	--(
	--	select	sum(ao.obligation_day) obligation_day
	--			,sum(ao.obligation_amount) obligation_amount
	--	from	dbo.agreement_obligation ao with (nolock)
	----LEFT JOIN dbo.AGREEMENT_OBLIGATION_PAYMENT aop WITH (NOLOCK) ON (aop.OBLIGATION_CODE = ao.CODE)
	--			outer apply
	--	(
	--		select	isnull(sum(aop.payment_amount), 0) payment_amount
	--		from	dbo.agreement_obligation_payment aop with (nolock)
	--		where	aop.obligation_code = ao.code
	--	) aop
	--	where	ao.asset_no			   = ast.asset_no
	--			AND ao.agreement_no = ast.agreement_no
	--			AND ao.cre_by		   <> 'MIGRASI'
	--			AND ao.obligation_type IN
	--(
	--	N'OVDP', N'LRAP'
	--)
	--			AND aop.payment_amount = 0
	--) ao
			LEFT JOIN dbo.sys_general_subcode sgs WITH (NOLOCK) ON (
														  ast.asset_type_code	= sgs.code
														  AND  sgs.general_code = 'ASTPRT'
													  )
	WHERE	ast.agreement_no = @p_agreement_no
			AND
			(
				ast.asset_no									LIKE '%' + @p_keywords + '%'
				OR	ast.asset_name								LIKE '%' + @p_keywords + '%'
				OR	sgs.description								LIKE '%' + @p_keywords + '%'
				OR	ast.fa_reff_no_01							LIKE '%' + @p_keywords + '%'
				OR	ast.replacement_fa_reff_no_01				LIKE '%' + @p_keywords + '%'
				OR	ast.fa_reff_no_02							LIKE '%' + @p_keywords + '%'
				OR	ast.replacement_fa_reff_no_02				LIKE '%' + @p_keywords + '%'
				OR	ast.fa_reff_no_03							LIKE '%' + @p_keywords + '%'
				OR	ast.replacement_fa_reff_no_03				LIKE '%' + @p_keywords + '%'
				OR	ast.asset_year								LIKE '%' + @p_keywords + '%'
				OR	ast.asset_condition							LIKE '%' + @p_keywords + '%'
				OR	ast.lease_round_amount						LIKE '%' + @p_keywords + '%'
				OR	ast.net_margin_amount						LIKE '%' + @p_keywords + '%'
				OR	ast.lease_amount							LIKE '%' + @p_keywords + '%'
				OR	ast.asset_status							LIKE '%' + @p_keywords + '%'
				OR	ao.obligation_day							LIKE '%' + @p_keywords + '%'
				OR	ao.obligation_amount						LIKE '%' + @p_keywords + '%'
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
					select	obligation_day
							,obligation_amount
					from	@temptable
					where	ast.asset_no = asset_no
							and agreement_no = ast.agreement_no
				)ao
	--			outer apply
	--(
	--	select	sum(ao.obligation_day) obligation_day
	--			,sum(ao.obligation_amount) obligation_amount
	--	from	dbo.agreement_obligation ao with (nolock)
	----LEFT JOIN dbo.AGREEMENT_OBLIGATION_PAYMENT aop WITH (NOLOCK) ON (aop.OBLIGATION_CODE = ao.CODE)
	--			outer apply
	--	(
	--		select	isnull(sum(aop.payment_amount), 0) payment_amount
	--		from	dbo.agreement_obligation_payment aop with (nolock)
	--		where	aop.obligation_code = ao.code
	--	) aop
	--	where	ao.asset_no			   = ast.asset_no
	--			and ao.agreement_no = ast.agreement_no
	--			and ao.cre_by		   <> 'MIGRASI'
	--			and ao.obligation_type in
	--(
	--	N'OVDP', N'LRAP'
	--)
	--			and aop.payment_amount = 0
	--) ao
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
