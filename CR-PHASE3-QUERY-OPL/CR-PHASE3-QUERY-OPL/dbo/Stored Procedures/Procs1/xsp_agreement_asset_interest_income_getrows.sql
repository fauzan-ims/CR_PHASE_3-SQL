--created by, Rian at 18/03/2023 

CREATE procedure xsp_agreement_asset_interest_income_getrows
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_agreement_no nvarchar(50)
	,@p_asset_no	 nvarchar(50) = 'ALL'
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.agreement_asset_interest_income aii
	inner join dbo.agreement_asset aas on (aas.ASSET_NO = aii.ASSET_NO)
	where	aii.agreement_no = @p_agreement_no
			and aii.asset_no = case @p_asset_no
							   when 'ALL' then aii.asset_no
							   else @p_asset_no
						   end
			and (
					aii.asset_no											like '%' + @p_keywords + '%'
					or	aii.installment_no									like '%' + @p_keywords + '%'
					or	aii.transaction_date								like '%' + @p_keywords + '%'
					or	aii.invoice_no										like '%' + @p_keywords + '%'
					or	convert(varchar(30), aii.transaction_date, 103)		like '%' + @p_keywords + '%'
					or	aii.income_amount									like '%' + @p_keywords + '%'
					or	aii.reff_no											like '%' + @p_keywords + '%'
					or	aii.reff_name										like '%' + @p_keywords + '%'
					or	aas.asset_name										like '%' + @p_keywords + '%'
				) ;

	select	aii.agreement_no
			,aii.asset_no
			,aas.asset_name
			,aii.installment_no
			,aii.invoice_no
			,aii.branch_code
			,aii.branch_name
			,convert(varchar(30), aii.transaction_date, 103) 'transaction_date'
			,aii.income_amount
			,aii.reff_no
			,aii.reff_name
			,@rows_count 'rowcount'
	from	dbo.agreement_asset_interest_income aii
			inner join dbo.AGREEMENT_ASSET aas on (aas.ASSET_NO = aii.ASSET_NO)
	where	aii.agreement_no = @p_agreement_no
			and aii.asset_no = case @p_asset_no
							   when 'ALL' then aii.asset_no
							   else @p_asset_no
						   end
			and (
					aii.asset_no											like '%' + @p_keywords + '%'
					or	aii.installment_no									like '%' + @p_keywords + '%'
					or	aii.transaction_date								like '%' + @p_keywords + '%'
					or	aii.invoice_no										like '%' + @p_keywords + '%'
					or	convert(varchar(30), aii.transaction_date, 103)		like '%' + @p_keywords + '%'
					or	aii.income_amount									like '%' + @p_keywords + '%'
					or	aii.reff_no											like '%' + @p_keywords + '%'
					or	aii.reff_name										like '%' + @p_keywords + '%'
					or	aas.asset_name										like '%' + @p_keywords + '%'
				) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then aii.asset_no
													 when 2 then cast(aii.installment_no as sql_variant)
													 when 3 then aii.invoice_no
													 when 4 then cast(aii.transaction_date as sql_variant)
													 when 5 then cast(aii.income_amount as sql_variant)
													 when 6 then aii.reff_no + aii.reff_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then aii.asset_no
														when 2 then cast(aii.installment_no as sql_variant)
														when 3 then aii.invoice_no
														when 4 then cast(aii.transaction_date as sql_variant)
														when 5 then cast(aii.income_amount as sql_variant)
														when 6 then aii.reff_no + aii.reff_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
