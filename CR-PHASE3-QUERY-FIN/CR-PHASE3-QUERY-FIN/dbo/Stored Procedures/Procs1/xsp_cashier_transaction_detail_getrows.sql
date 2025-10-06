CREATE PROCEDURE [dbo].[xsp_cashier_transaction_detail_getrows]
(
	@p_keywords					 nvarchar(50)
	,@p_pagenumber				 int
	,@p_rowspage				 int
	,@p_order_by				 int
	,@p_sort_by					 nvarchar(5)
	,@p_cashier_transaction_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	cashier_transaction_detail ctd with (nolock)
			left join dbo.cashier_received_request crr with (nolock) on (crr.code = ctd.received_request_code)
			left join dbo.master_transaction mt with (nolock) on (mt.code = ctd.transaction_code)
			left join dbo.CASHIER_TRANSACTION on CASHIER_TRANSACTION.CODE = ctd.CASHIER_TRANSACTION_CODE
			outer apply
	(
		select	cpd.transaction_code
				,cpd.is_partial
				,cpd.order_no
		from	master_cashier_priority_detail cpd with (nolock)
				left join dbo.master_cashier_priority cp with (nolock) on (
																 cp.code			 = cpd.cashier_priority_code
																 and   cp.is_default = '1'
															 )
		where	cpd.transaction_code = ctd.transaction_code
	) parsial
	where	cashier_transaction_code = @p_cashier_transaction_code
			and (
					case is_paid
						when '1' then 'true'
						else 'false'
					end							like '%' + @p_keywords + '%'
					or	installment_no			like '%' + @p_keywords + '%'
					--or	ctd.transaction_code	like '%' + @p_keywords + '%'
					or	ctd.RECEIVED_REQUEST_CODE	like '%' + @p_keywords + '%'
					or	ctd.orig_amount			like '%' + @p_keywords + '%'
					or	ctd.exch_rate			like '%' + @p_keywords + '%'
					or	ctd.base_amount			like '%' + @p_keywords + '%'
					or	ctd.orig_currency_code	like '%' + @p_keywords + '%'
					or	innitial_amount			like '%' + @p_keywords + '%'
					or	remarks					like '%' + @p_keywords + '%'
					or	replace(ctd.agreement_no, '.', '/')		like '%' + @p_keywords + '%'
				) ;

		select	ctd.id
				,is_paid
				,installment_no
				--,isnull(received_request_code, ctd.remarks) 'transaction_no'
				,ctd.RECEIVED_REQUEST_CODE 'transaction_no'
				,case isnull(ctd.RECEIVED_REQUEST_CODE, crr.doc_ref_name)
						when '' then ''
						else ctd.remarks
					end 'transaction_name'
				,case isnull(mt.module_name, '')
						when '' then '0'
						else '1'
					end 'is_module'
				,orig_amount
				,innitial_amount
				,remarks
				,parsial.is_partial
				,ctd.exch_rate
				,ctd.base_amount
				,ctd.orig_currency_code
				,crr.invoice_no
				,isnull(crr.invoice_external_no,ctd.installment_no) 'invoice_external_no'
				,convert(varchar(30), crr.invoice_date, 103) 'invoice_date'
				,convert(varchar(30), crr.invoice_due_date, 103) 'invoice_due_date'
				,crr.invoice_billing_amount
				,crr.invoice_ppn_amount
				,crr.invoice_pph_amount
				,ctd.transaction_code -- Louis Kamis, 26 Juni 2025 16.21.13 -- 
				,replace(ctd.agreement_no, '.', '/') 'agreement_no' -- Louis Kamis, 26 Juni 2025 17.19.25 -- 
				,@rows_count 'rowcount'
		from	cashier_transaction_detail ctd with (nolock)
				left join dbo.master_transaction mt with (nolock) on (mt.code = ctd.transaction_code)
				left join dbo.cashier_received_request crr with (nolock) on (crr.code = ctd.received_request_code)
				left join dbo.CASHIER_TRANSACTION on CASHIER_TRANSACTION.CODE = ctd.CASHIER_TRANSACTION_CODE
				outer apply
					(
						select	cpd.transaction_code
								,cpd.is_partial
								,cpd.order_no
						from	master_cashier_priority_detail cpd with (nolock) -- Hari - 01.Aug.2023 04:31 PM --	jadikan inner biar data tidak double
								inner join dbo.master_cashier_priority cp with (nolock) on (
																				cp.code			  = cpd.cashier_priority_code
																				and cp.is_default = '1'
																			)
						where	cpd.transaction_code = ctd.transaction_code
					) parsial
		where		cashier_transaction_code = @p_cashier_transaction_code
					and (
							case is_paid
								when '1' then 'true'
								else 'false'
							end											like '%' + @p_keywords + '%'
							or	installment_no							like '%' + @p_keywords + '%'
							--or	ctd.transaction_code	like '%' + @p_keywords + '%'
							or	ctd.RECEIVED_REQUEST_CODE					like '%' + @p_keywords + '%'
							or	ctd.orig_amount							like '%' + @p_keywords + '%'
							or	ctd.exch_rate							like '%' + @p_keywords + '%'
							or	ctd.base_amount							like '%' + @p_keywords + '%'
							or	ctd.orig_currency_code					like '%' + @p_keywords + '%'
							or	innitial_amount							like '%' + @p_keywords + '%'
							or	remarks									like '%' + @p_keywords + '%'
							or	replace(ctd.agreement_no, '.', '/')		like '%' + @p_keywords + '%'
						)
		order by	
					case  when @p_sort_by = 'asc' then case @p_order_by
															when 1 then isnull(ctd.RECEIVED_REQUEST_CODE,ctd.remarks)
															when 2 then installment_no			
															when 3 then crr.invoice_external_no			
															when 4 then cast(crr.invoice_billing_amount as sql_variant)			
															when 5 then cast(innitial_amount as sql_variant)			
															when 6 then cast(orig_amount as sql_variant)				
															when 7 then cast(ctd.base_amount as sql_variant)				
															when 8 then is_paid	
														end
					end asc 
					,case when @p_sort_by = 'desc' then case @p_order_by
															when 1 then isnull(ctd.RECEIVED_REQUEST_CODE,ctd.remarks)
															when 2 then installment_no			
															when 3 then crr.invoice_external_no			
															when 4 then cast(crr.invoice_billing_amount as sql_variant)			
															when 5 then cast(innitial_amount as sql_variant)			
															when 6 then cast(orig_amount as sql_variant)				
															when 7 then cast(ctd.base_amount as sql_variant)				
															when 8 then is_paid	
												end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

