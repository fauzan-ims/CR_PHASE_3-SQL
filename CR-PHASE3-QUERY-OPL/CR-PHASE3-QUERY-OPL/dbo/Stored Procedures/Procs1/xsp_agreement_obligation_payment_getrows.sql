CREATE PROCEDURE [dbo].[xsp_agreement_obligation_payment_getrows]
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_agreement_no		nvarchar(50)
	,@p_installment_no		int = 0
	,@p_asset_no			nvarchar(50) -- (+) Ari 2023-10-10 ket : add asset no
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	agreement_obligation_payment
	where	agreement_no	 = @p_agreement_no
	and isnull(installment_no, 0)	 = @p_installment_no
	and	asset_no = @p_asset_no  -- (+) Ari 2023-10-10 ket : add condition asset no
	and(
			obligation_code									like '%' + @p_keywords + '%'
			or	agreement_no								like '%' + @p_keywords + '%'
			or	installment_no								like '%' + @p_keywords + '%'
			or	convert(nvarchar(30),payment_date, 103)		like '%' + @p_keywords + '%'
			or	convert(nvarchar(30), value_date, 103)		like '%' + @p_keywords + '%'
			or	payment_source_type							like '%' + @p_keywords + '%'
			or	payment_source_no							like '%' + @p_keywords + '%'
			or	payment_amount								like '%' + @p_keywords + '%'
			or	case is_waive
					when '1' then 'YES'
					else 'NO'
				end											like '%' + @p_keywords + '%'
		) ;

	select		id
				,obligation_code
				,agreement_no
				,installment_no
				,convert(nvarchar(30), payment_date, 103) 'payment_date'
				,convert(nvarchar(30), value_date, 103) 'value_date'
				,payment_source_type
				,payment_source_no
				,payment_amount
				,case is_waive
					 when '1' then 'YES'
					 else 'NO'
				 end 'is_waive'
				,@rows_count 'rowcount'
	from		agreement_obligation_payment
	where		agreement_no = @p_agreement_no
				and isnull(installment_no, 0) = @p_installment_no
				and	asset_no = @p_asset_no  -- (+) Ari 2023-10-10 ket : add condition asset no
				and(
					obligation_code									like '%' + @p_keywords + '%'
					or	agreement_no								like '%' + @p_keywords + '%'
					or	installment_no								like '%' + @p_keywords + '%'
					or	convert(nvarchar(30),payment_date, 103)		like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), value_date, 103)		like '%' + @p_keywords + '%'
					or	payment_source_type							like '%' + @p_keywords + '%'
					or	payment_source_no							like '%' + @p_keywords + '%'
					or	payment_amount								like '%' + @p_keywords + '%'
					or	case is_waive
							when '1' then 'YES'
							else 'NO'
						end											like '%' + @p_keywords + '%'	
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then payment_source_type
													 when 2 then payment_source_no
													 when 3 then cast(payment_date as sql_variant)
													 when 4 then cast(value_date as sql_variant)
													 when 5 then cast(payment_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then payment_source_type
													 when 2 then payment_source_no
													 when 3 then cast(payment_date as sql_variant)
													 when 4 then cast(value_date as sql_variant)
													 when 5 then cast(payment_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
