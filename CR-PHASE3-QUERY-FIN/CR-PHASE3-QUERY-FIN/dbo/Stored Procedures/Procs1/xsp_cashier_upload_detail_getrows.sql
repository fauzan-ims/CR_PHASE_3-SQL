CREATE PROCEDURE dbo.xsp_cashier_upload_detail_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_cashier_upload_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	cashier_upload_detail
	where	cashier_upload_code = @p_cashier_upload_code
			and (
					reff_loan_no					like '%' + @p_keywords + '%'
					or client_name					like '%' + @p_keywords + '%'
					or	total_installment_amount	like '%' + @p_keywords + '%'
					or	total_obligation_amount		like '%' + @p_keywords + '%'
				) ;

	select		id
				,cashier_upload_code
				,reff_loan_no
				,agreement_no
				,client_name
				,total_installment_amount
				,total_obligation_amount
				,@rows_count 'rowcount'
	from		cashier_upload_detail
	where		cashier_upload_code = @p_cashier_upload_code
				and (
						reff_loan_no					like '%' + @p_keywords + '%'
						or client_name					like '%' + @p_keywords + '%'
						or	total_installment_amount	like '%' + @p_keywords + '%'
						or	total_obligation_amount		like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then reff_loan_no
													 when 2 then client_name
													 when 3 then cast(total_installment_amount as sql_variant)
													 when 4 then cast(total_obligation_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then reff_loan_no
													   when 2 then client_name
													   when 3 then cast(total_installment_amount as sql_variant)
													   when 4 then cast(total_obligation_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
