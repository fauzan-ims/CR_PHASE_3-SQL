CREATE PROCEDURE [dbo].[xsp_agreement_obligation_getrows]
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_agreement_no		nvarchar(50)
	,@p_obligation_type		nvarchar(50)
	,@p_asset_no			nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	agreement_obligation o
			outer apply(
							select	sum(payment_amount) 'payment_amount'
									,max(ap.payment_source_no) 'payment_source_no'
									,max(ap.payment_date) 'payment_date'
							from	dbo.agreement_obligation_payment ap
							where	ap.agreement_no			= o.agreement_no
									and isnull(ap.installment_no, 0)	= o.installment_no
									and	ap.asset_no			= o.asset_no -- (+) Ari 2023-10-10 ket : tampilkan perasset
						) payment 
	where	o.agreement_no		= @p_agreement_no
	and		o.ASSET_NO			= @p_asset_no
	and		obligation_type		= case @p_obligation_type
										when 'ALL' then o.obligation_type
										else @p_obligation_type
								  end 
	--and		p.payment_date in (select max(payment_date) as payment_date from agreement_obligation_payment group by obligation_code)
			and(
				o.code													like '%' + @p_keywords + '%'
				or	o.installment_no									like '%' + @p_keywords + '%'
				or	obligation_day										like '%' + @p_keywords + '%'
				or	convert(varchar(30), obligation_date, 103) 			like '%' + @p_keywords + '%'
				or	obligation_reff_no									like '%' + @p_keywords + '%'
				or	obligation_amount									like '%' + @p_keywords + '%'
				or	payment.payment_source_no							like '%' + @p_keywords + '%'
				or	convert(varchar(30), payment.payment_date, 103) 	like '%' + @p_keywords + '%'
				or	payment.payment_amount						 		like '%' + @p_keywords + '%'
				or	o.obligation_name						 			like '%' + @p_keywords + '%'
			) ;

		select		o.code
					,o.installment_no			                    
					,obligation_day			                    
					,convert(varchar(30), obligation_date, 103) 'obligation_date'	
					,obligation_reff_no							
					,obligation_amount							
					,case when sum(payment.payment_amount) > 0 then payment.payment_source_no else null end 'payment_date'						
					,case when sum(payment.payment_amount) > 0 then convert(varchar(30), payment.payment_date, 103) else null end 'payment_date'	
					,sum(payment.payment_amount) 'total_payment'
					,o.obligation_name
					,case
						when cast(o.obligation_date as date) < cast(dbo.xfn_get_system_date() as date) then case when sum(isnull(payment.payment_amount,0)) <> o.obligation_amount then '1'
							else '0'
						end
							else '0'
					end 'status'
					,@rows_count 'rowcount'
		from	agreement_obligation o
		outer apply(
							select	sum(payment_amount) 'payment_amount'
									,max(ap.payment_source_no) 'payment_source_no'
									,max(ap.value_date) 'payment_date'
							from	dbo.agreement_obligation_payment ap
							where	ap.agreement_no			= o.agreement_no
									and isnull(ap.installment_no, 0)	= o.installment_no
									and	ap.asset_no			= o.asset_no -- (+) Ari 2023-10-10 ket : tampilkan perasset
						) payment 
		where	o.agreement_no		= @p_agreement_no
		and		o.ASSET_NO			= @p_asset_no
		and		obligation_type		= case @p_obligation_type
											when 'ALL' then o.obligation_type
											else @p_obligation_type
									  end 
		--and		p.payment_date in (select max(payment_date) as payment_date from agreement_obligation_payment group by obligation_code)
				and(
					o.code													like '%' + @p_keywords + '%'
					or	o.installment_no									like '%' + @p_keywords + '%'
					or	obligation_day										like '%' + @p_keywords + '%'
					or	convert(varchar(30), obligation_date, 103) 			like '%' + @p_keywords + '%'
					or	obligation_reff_no									like '%' + @p_keywords + '%'
					or	obligation_amount									like '%' + @p_keywords + '%'
					or	payment.payment_source_no							like '%' + @p_keywords + '%'
					or	convert(varchar(30), payment.payment_date, 103) 	like '%' + @p_keywords + '%'
					or	payment.payment_amount						 		like '%' + @p_keywords + '%'
					or	o.obligation_name						 			like '%' + @p_keywords + '%'
				)
		group by	o.code
					,o.installment_no
					,o.obligation_day
					,o.obligation_date
					,o.obligation_reff_no
					,o.obligation_amount
					,payment.payment_source_no
					,payment.payment_date
					,payment.payment_amount
					,o.obligation_name

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then o.installment_no			                    
													when 2 then cast(obligation_day as sql_variant)			                   							
													when 3 then cast(obligation_amount as sql_variant) 							
													when 4 then	payment.payment_source_no							
													when 5 then	cast(payment.payment_date as sql_variant) 
													when 6 then cast(payment.payment_amount as sql_variant) 
													when 7 then cast(o.obligation_name as sql_variant) 
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then o.installment_no			                    
													when 2 then cast(obligation_day as sql_variant)			                   							
													when 3 then cast(obligation_amount as sql_variant) 							
													when 4 then	payment.payment_source_no							
													when 5 then	cast(payment.payment_date as sql_variant) 
													when 6 then cast(payment.payment_amount as sql_variant) 
													when 7 then cast(o.obligation_name as sql_variant) 
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
