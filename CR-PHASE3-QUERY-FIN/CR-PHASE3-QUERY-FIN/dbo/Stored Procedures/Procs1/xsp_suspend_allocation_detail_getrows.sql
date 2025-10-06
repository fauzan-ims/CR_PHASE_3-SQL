CREATE PROCEDURE [dbo].[xsp_suspend_allocation_detail_getrows]
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_suspend_allocation_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	suspend_allocation_detail sad
			left join dbo.master_transaction mt on (mt.code = sad.transaction_code)
			left join dbo.cashier_received_request crr on (crr.code = sad.received_request_code)
			outer apply (	select cpd.transaction_code, cpd.is_partial from master_cashier_priority_detail cpd
							inner join dbo.master_cashier_priority cp on (cp.code = cpd.cashier_priority_code and cp.is_default = '1')
							where cpd.transaction_code = sad.transaction_code
						) parsial
	where	sad.suspend_allocation_code = @p_suspend_allocation_code
			and	(
					case is_paid
						when '1' then 'true'
						else 'false'
					end							like '%' + @p_keywords + '%'
					or	installment_no			like '%' + @p_keywords + '%'
					--or	transaction_code		like '%' + @p_keywords + '%'
					or	received_request_code	like '%' + @p_keywords + '%'
					or	sad.orig_amount			like '%' + @p_keywords + '%'
					or	sad.exch_rate			like '%' + @p_keywords + '%'
					or	sad.base_amount			like '%' + @p_keywords + '%'
					or	innitial_amount			like '%' + @p_keywords + '%'
					or	remarks					like '%' + @p_keywords + '%'
				) ;
		select		sad.id
					,is_paid
					,installment_no			
					--,isnull(sad.TRANSACTION_CODE,sad.remarks) 'transaction_no'
					,sad.transaction_code  'transaction_no'
					,case  isnull(mt.transaction_name, sad.remarks) 
							when '' then ''
							else sad.remarks
					 end 'transaction_name'		
					,orig_amount
					,innitial_amount
					,remarks
					,parsial.is_partial
					,sad.base_amount
					,sad.exch_rate
					,crr.invoice_no
					,isnull(crr.invoice_external_no,sad.installment_no) 'invoice_external_no'
					,convert(varchar(30), crr.invoice_date, 103) 'invoice_date'
					,convert(varchar(30), crr.invoice_due_date, 103) 'invoice_due_date'
					,crr.invoice_billing_amount
					,crr.invoice_ppn_amount
					,crr.invoice_pph_amount
					,case  isnull(mt.module_name, '') 
							when '' then '0'
							else '1'
					 end 'is_module'
					,@rows_count 'rowcount'
		from		suspend_allocation_detail sad
					left join dbo.master_transaction mt on (mt.code = sad.transaction_code)
					left join dbo.cashier_received_request crr on (crr.code = sad.received_request_code)
					outer apply (	select cpd.transaction_code, cpd.is_partial,cpd.order_no from master_cashier_priority_detail cpd
							inner join dbo.master_cashier_priority cp on (cp.code = cpd.cashier_priority_code and cp.is_default = '1')
							where cpd.transaction_code = sad.transaction_code
						) parsial
		where		sad.suspend_allocation_code = @p_suspend_allocation_code
					and (
							case is_paid
								when '1' then 'true'
								else 'false'
							end							like '%' + @p_keywords + '%'
							or	installment_no			like '%' + @p_keywords + '%'
							--or	transaction_code		like '%' + @p_keywords + '%'
							or	received_request_code	like '%' + @p_keywords + '%'
							or	sad.orig_amount			like '%' + @p_keywords + '%'
							or	sad.exch_rate			like '%' + @p_keywords + '%'
							or	sad.base_amount			like '%' + @p_keywords + '%'
							or	innitial_amount			like '%' + @p_keywords + '%'
							or	remarks					like '%' + @p_keywords + '%'
						)
		order by 
				case  when @p_sort_by = 'asc' then case @p_order_by
														when 1 then isnull(received_request_code,sad.remarks)
														when 2 then crr.invoice_external_no
														when 3 then cast(crr.invoice_billing_amount as sql_variant)			
														when 4 then installment_no			
														when 5 then cast(innitial_amount as sql_variant)			
														when 6 then cast(orig_amount as sql_variant)				
														when 7 then cast(sad.base_amount as sql_variant)				
														when 8 then is_paid
													end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then isnull(received_request_code,sad.remarks)
														when 2 then crr.invoice_external_no
														when 3 then cast(crr.invoice_billing_amount as sql_variant)			
														when 4 then installment_no			
														when 5 then cast(innitial_amount as sql_variant)			
														when 6 then cast(orig_amount as sql_variant)				
														when 7 then cast(sad.base_amount as sql_variant)				
														when 8 then is_paid
														end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
