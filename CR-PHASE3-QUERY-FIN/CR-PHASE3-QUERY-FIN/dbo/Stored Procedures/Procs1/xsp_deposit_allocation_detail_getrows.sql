CREATE PROCEDURE [dbo].[xsp_deposit_allocation_detail_getrows]
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_deposit_allocation_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	deposit_allocation_detail dad
			left join dbo.cashier_received_request crr on (crr.code = dad.received_request_code)
 			left join dbo.master_transaction mt on (mt.code = dad.transaction_code)
			outer apply (	select cpd.transaction_code, cpd.is_partial from master_cashier_priority_detail cpd
							inner join dbo.master_cashier_priority cp on (cp.code = cpd.cashier_priority_code and cp.is_default = '1')
							where cpd.transaction_code = dad.transaction_code
						) parsial
	where	dad.deposit_allocation_code	=@p_deposit_allocation_code
			and	(
					case is_paid
						when '1' then 'true'
						else 'false'
					end							like '%' + @p_keywords + '%'
					or	installment_no			like '%' + @p_keywords + '%'
					--or	transaction_code	like '%' + @p_keywords + '%'
					or	received_request_code	like '%' + @p_keywords + '%'
					or	dad.orig_amount			like '%' + @p_keywords + '%'
					or	dad.exch_rate			like '%' + @p_keywords + '%'
					or	dad.base_amount			like '%' + @p_keywords + '%'
					or	innitial_amount			like '%' + @p_keywords + '%'
					or	remarks					like '%' + @p_keywords + '%'
				or	isnull(mt.transaction_name,dad.remarks)	like '%' + @p_keywords + '%'
				) ;

		select		dad.id
					,is_paid
					,installment_no			
					--,isnull(dad.transaction_code, parsial.transaction_code) 'transaction_code'
					,dad.transaction_code
					,isnull(mt.transaction_name,dad.remarks)	'transaction_name'
					,case  isnull(mt.module_name, '') 
							when '' then '0'
							else '1'
					 end 'is_module'
					,orig_amount
					,innitial_amount
					,remarks
					,parsial.is_partial
					,dad.base_amount
					,dad.exch_rate
					,crr.invoice_no
					,isnull(crr.invoice_external_no,dad.installment_no) 'invoice_external_no'
					,convert(varchar(30), crr.invoice_date, 103) 'invoice_date'
					,convert(varchar(30), crr.invoice_due_date, 103) 'invoice_due_date'
					,crr.invoice_billing_amount
					,crr.invoice_ppn_amount
					,crr.invoice_pph_amount
					,@rows_count 'rowcount'
		from		deposit_allocation_detail dad
					left join dbo.master_transaction mt on (mt.code = dad.transaction_code)
					left join dbo.cashier_received_request crr on (crr.code = dad.received_request_code)
					outer apply (	select cpd.transaction_code, cpd.is_partial, cpd.order_no from master_cashier_priority_detail cpd
							inner join dbo.master_cashier_priority cp on (cp.code = cpd.cashier_priority_code and cp.is_default = '1')
							where cpd.transaction_code = dad.transaction_code
						) parsial
		where		dad.deposit_allocation_code	= @p_deposit_allocation_code
					and	(
							case is_paid
								when '1' then 'true'
								else 'false'
							end							like '%' + @p_keywords + '%'
							or	installment_no			like '%' + @p_keywords + '%'
							--or	transaction_code		like '%' + @p_keywords + '%'
							or	received_request_code	like '%' + @p_keywords + '%'
							or	dad.orig_amount			like '%' + @p_keywords + '%'
							or	dad.exch_rate			like '%' + @p_keywords + '%'
							or	dad.base_amount			like '%' + @p_keywords + '%'
							or	innitial_amount			like '%' + @p_keywords + '%'
							or	remarks					like '%' + @p_keywords + '%'
							or	isnull(mt.transaction_name,dad.remarks)	like '%' + @p_keywords + '%'
							
						)
		order by	
					case when @p_sort_by = 'asc' then case @p_order_by
															when 1 then dad.transaction_code
															when 2 then crr.invoice_external_no			
															when 3 then cast(crr.invoice_billing_amount as sql_variant)			
															when 4 then installment_no			
															when 5 then cast(innitial_amount as sql_variant)			
															when 6 then cast(orig_amount as sql_variant)				
															when 7 then cast(dad.base_amount as sql_variant)				
														end
				end asc 
							,case when @p_sort_by = 'desc' then case @p_order_by
																	when 1 then dad.transaction_code
																	when 2 then crr.invoice_external_no			
																	when 3 then cast(crr.invoice_billing_amount as sql_variant)			
																	when 4 then installment_no			
																	when 5 then cast(innitial_amount as sql_variant)			
																	when 6 then cast(orig_amount as sql_variant)				
																	when 7 then cast(dad.base_amount as sql_variant)				
																end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

