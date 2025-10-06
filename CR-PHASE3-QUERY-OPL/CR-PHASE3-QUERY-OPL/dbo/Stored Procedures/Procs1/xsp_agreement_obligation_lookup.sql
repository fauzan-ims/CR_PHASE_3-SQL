CREATE PROCEDURE [dbo].[xsp_agreement_obligation_lookup]
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
	from	(
					select		 obligation_type 
								,obligation_name 'obligation_name'
								,invoice_no
								,installment_no
								--,obligation_amount
								,sum(obligation_amount - aop.payment_amount) 'obligation_amount' -- (+) Ari 2023-10-09 ket : hitung kembali jika obligation sudah ada yg terbayar
					from		agreement_obligation ao
					outer apply	(	select	isnull(sum(payment_amount),0) 'payment_amount'
									from	dbo.agreement_obligation_payment aop
									where	aop.agreement_no = ao.agreement_no
									and		aop.installment_no = ao.installment_no
									and		aop.asset_no = ao.asset_no
								) aop
					where		agreement_no = @p_agreement_no
								and	invoice_no not in (
														select	wod.invoice_no
														from	dbo.waived_obligation wo
																inner join dbo.waived_obligation_detail wod on (wod.waived_obligation_code = wo.code)
														where	wo.agreement_no = @p_agreement_no
														--and		wo.waived_status = 'APPROVE'
														-- (+) Ari 2023-10-09 ket : tidak sedang di proses
														and		wo.waived_status in ('HOLD','ON PROCESS') 
													  )
								AND ao.OBLIGATION_TYPE <> 'LRAP'
					group	by	ao.obligation_type
								,ao.obligation_name
								,ao.invoice_no
								,ao.installment_no

					UNION
                    
					select		 obligation_type 
								,obligation_name 'obligation_name'
								,ao.ASSET_NO 
								,installment_no
								--,obligation_amount
								,sum(obligation_amount - aop.payment_amount) 'obligation_amount' -- (+) Ari 2023-10-09 ket : hitung kembali jika obligation sudah ada yg terbayar
					from		agreement_obligation ao
					outer apply	(	select	isnull(sum(payment_amount),0) 'payment_amount'
									from	dbo.agreement_obligation_payment aop
									where	aop.agreement_no = ao.agreement_no
									and		aop.installment_no = ao.installment_no
									and		aop.asset_no = ao.asset_no
								 ) aop
					where		agreement_no = @p_agreement_no
								and	ao.ASSET_NO NOT IN(
																SELECT	wod.invoice_no
																FROM	dbo.waived_obligation wo
																		INNER JOIN dbo.waived_obligation_detail wod ON (wod.waived_obligation_code = wo.code)
																WHERE	wo.agreement_no = @p_agreement_no
																--and		wo.waived_status = 'APPROVE'
																-- (+) Ari 2023-10-09 ket : tidak sedang di proses
																		AND wo.waived_status IN ('HOLD','ON PROCESS') 
															)
								AND ao.OBLIGATION_TYPE = 'LRAP'
					group	by	ao.obligation_type
								,ao.obligation_name
								,ao.ASSET_NO
								,ao.installment_no
			) agob
	WHERE	 (
						agob.obligation_type			like '%' + @p_keywords + '%'
						or	agob.obligation_name		like '%' + @p_keywords + '%'
						or	agob.invoice_no		like '%' + @p_keywords + '%'

			 )
	and		isnull(agob.obligation_amount,0) > 0 -- (+) Ari 2023-10-09 ket : jika 0 tidak perlu muncul kembali

	select	agob.obligation_type
			,agob.obligation_name
			,invoice_no
			,installment_no
			--,obligation_amount
			,agob.obligation_amount -- (+) Ari 2023-10-09 ket : hitung kembali jika obligation sudah ada yg terbayar
			,@rows_count 'rowcount'
	from	(
					select		 obligation_type 
								,obligation_name 'obligation_name'
								,invoice_no
								,installment_no
								--,obligation_amount
								,sum(obligation_amount - aop.payment_amount) 'obligation_amount' -- (+) Ari 2023-10-09 ket : hitung kembali jika obligation sudah ada yg terbayar
					from		agreement_obligation ao
					outer apply	(	select	isnull(sum(payment_amount),0) 'payment_amount'
									from	dbo.agreement_obligation_payment aop
									where	aop.agreement_no = ao.agreement_no
									and		aop.installment_no = ao.installment_no
									and		aop.asset_no = ao.asset_no
								 ) aop
					where		agreement_no = @p_agreement_no
								and	invoice_no not in(
																select	wod.invoice_no
																from	dbo.waived_obligation wo
																		inner join dbo.waived_obligation_detail wod on (wod.waived_obligation_code = wo.code)
																where	wo.agreement_no = @p_agreement_no
																--and		wo.waived_status = 'APPROVE'
																-- (+) Ari 2023-10-09 ket : tidak sedang di proses
																and		wo.waived_status in ('HOLD','ON PROCESS') 
															)
								AND ao.OBLIGATION_TYPE <> 'LRAP'
					group	by	ao.obligation_type
								,ao.obligation_name
								,ao.invoice_no
								,ao.installment_no

					UNION
                    
					select		 obligation_type 
								,obligation_name 'obligation_name'
								,ao.ASSET_NO 
								,installment_no
								--,obligation_amount
								,sum(obligation_amount - aop.payment_amount) 'obligation_amount' -- (+) Ari 2023-10-09 ket : hitung kembali jika obligation sudah ada yg terbayar
					from		agreement_obligation ao
					outer apply	(	select	isnull(sum(payment_amount),0) 'payment_amount'
									from	dbo.agreement_obligation_payment aop
									where	aop.agreement_no = ao.agreement_no
									and		aop.installment_no = ao.installment_no
									and		aop.asset_no = ao.asset_no
								 ) aop
					where		agreement_no = @p_agreement_no
								and	ao.ASSET_NO NOT IN(
																SELECT	wod.invoice_no
																FROM	dbo.waived_obligation wo
																		INNER JOIN dbo.waived_obligation_detail wod ON (wod.waived_obligation_code = wo.code)
																WHERE	wo.agreement_no = @p_agreement_no
																--and		wo.waived_status = 'APPROVE'
																-- (+) Ari 2023-10-09 ket : tidak sedang di proses
																		AND wo.waived_status IN ('HOLD','ON PROCESS') 
															)
								AND ao.OBLIGATION_TYPE = 'LRAP'
					group	by	ao.obligation_type
								,ao.obligation_name
								,ao.ASSET_NO
								,ao.installment_no
			) agob
	where	 (
						agob.obligation_type			like '%' + @p_keywords + '%'
						or	agob.obligation_name		like '%' + @p_keywords + '%'
						or	agob.invoice_no		like '%' + @p_keywords + '%'

			)
	and		isnull(agob.obligation_amount,0) > 0 -- (+) Ari 2023-10-09 ket : jika 0 tidak perlu muncul kembali
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then agob.obligation_type
													 when 2 then agob.obligation_name
													 when 3 then agob.invoice_no
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then agob.obligation_type
													   when 2 then agob.obligation_name
													   when 3 then agob.invoice_no
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
