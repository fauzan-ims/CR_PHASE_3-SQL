CREATE PROCEDURE dbo.xsp_ifinfin_interface_agreement_obligation_payment_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	ifinfin_interface_agreement_obligation_payment
	where	(
				id							like '%' + @p_keywords + '%'
				or	obligation_code			like '%' + @p_keywords + '%'
				or	agreement_no			like '%' + @p_keywords + '%'
				or	installment_no			like '%' + @p_keywords + '%'
				or	payment_date			like '%' + @p_keywords + '%'
				or	value_date				like '%' + @p_keywords + '%'
				or	payment_source_type		like '%' + @p_keywords + '%'
				or	payment_source_no		like '%' + @p_keywords + '%'
				or	payment_amount			like '%' + @p_keywords + '%'
			) ;

		select		id
					,obligation_code
					,agreement_no
					,installment_no
					,payment_date
					,value_date
					,payment_source_type
					,payment_source_no
					,payment_amount
					,@rows_count 'rowcount'
		from		ifinfin_interface_agreement_obligation_payment
		where		(
						id							like '%' + @p_keywords + '%'
						or	obligation_code			like '%' + @p_keywords + '%'
						or	agreement_no			like '%' + @p_keywords + '%'
						or	installment_no			like '%' + @p_keywords + '%'
						or	payment_date			like '%' + @p_keywords + '%'
						or	value_date				like '%' + @p_keywords + '%'
						or	payment_source_type		like '%' + @p_keywords + '%'
						or	payment_source_no		like '%' + @p_keywords + '%'
						or	payment_amount			like '%' + @p_keywords + '%'
					)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then obligation_code
														when 2 then agreement_no
														when 3 then payment_source_type
														when 4 then payment_source_no
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then obligation_code
														when 2 then agreement_no
														when 3 then payment_source_type
														when 4 then payment_source_no
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
