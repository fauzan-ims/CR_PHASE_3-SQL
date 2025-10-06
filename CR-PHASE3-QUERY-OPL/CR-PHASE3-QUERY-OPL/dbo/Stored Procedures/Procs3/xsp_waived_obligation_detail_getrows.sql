CREATE PROCEDURE [dbo].[xsp_waived_obligation_detail_getrows]
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_waived_obligation_code	nvarchar(50)
)
as
begin

	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	waived_obligation_detail
	where	waived_obligation_code = @p_waived_obligation_code
	and			(
						convert(nvarchar(3),installment_no) 
						+ obligation_type						like '%' + @p_keywords + '%'
					or id										like '%' + @p_keywords + '%'
					or	obligation_type							like '%' + @p_keywords + '%'
					or	obligation_name							like '%' + @p_keywords + '%'
					or	installment_no							like '%' + @p_keywords + '%'
					or	obligation_amount						like '%' + @p_keywords + '%'
					or	waived_amount							like '%' + @p_keywords + '%'
				)

	select		convert(nvarchar(3),installment_no) + obligation_type 'ins_type'
				,id
				,obligation_type
				,obligation_name
				,installment_no
				,obligation_amount
				,waived_amount
				,case when obligation_type = 'LRAP' then asset_no else invoice_no end 'invoice_no' --2025/08/11 raffy cr fase 3
				,@rows_count 'rowcount'
	from		waived_obligation_detail
	where		waived_obligation_code = @p_waived_obligation_code
	and			(
						convert(nvarchar(3),installment_no) 
						+ obligation_type						like '%' + @p_keywords + '%'
					or id										like '%' + @p_keywords + '%'
					or	obligation_type							like '%' + @p_keywords + '%'
					or	obligation_name							like '%' + @p_keywords + '%'
					or	installment_no							like '%' + @p_keywords + '%'
					or	obligation_amount						like '%' + @p_keywords + '%'
					or	waived_amount							like '%' + @p_keywords + '%'
				)
	order by 	case  
						when @p_sort_by = 'asc'
									then CASE @p_order_by
											when 1 then invoice_no		
											when 2 then obligation_type		
											when 3 then obligation_name		
											when 4 then cast(installment_no as sql_variant)	
											when 5 then cast(obligation_amount as sql_variant)
											when 6 then cast(waived_amount as sql_variant)
										end 
				end asc,
				case  
						when @p_sort_by = 'desc' THEN CASE @p_order_by
													when 1 then invoice_no		
													when 2 then obligation_type		
													when 3 then obligation_name		
													when 4 then cast(installment_no as sql_variant)	
													when 5 then cast(obligation_amount as sql_variant)
													when 6 then cast(waived_amount as sql_variant)
												end 
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	
end ;

