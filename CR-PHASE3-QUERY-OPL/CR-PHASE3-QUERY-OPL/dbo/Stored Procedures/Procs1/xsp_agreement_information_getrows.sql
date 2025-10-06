create PROCEDURE dbo.xsp_agreement_information_getrows
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
	from	dbo.AGREEMENT_INFORMATION
	where	agreement_no = @p_agreement_no
	and		(
				agreement_no						like '%' + @p_keywords + '%'
				or	deskcoll_staff_code				like '%' + @p_keywords + '%'
				or	deskcoll_staff_name				like '%' + @p_keywords + '%'
				or	installment_amount				like '%' + @p_keywords + '%'
				or	installment_due_date			like '%' + @p_keywords + '%'
				or	next_due_date					like '%' + @p_keywords + '%'
				or  last_paid_period				like '%' + @p_keywords + '%'
				or	ovd_period						like '%' + @p_keywords + '%'
				or	ovd_days						like '%' + @p_keywords + '%'
				or	ovd_rental_amount				like '%' + @p_keywords + '%'
				or	ovd_penalty_amount				like '%' + @p_keywords + '%'
				or	os_rental_amount				like '%' + @p_keywords + '%'
				or	os_deposit_installment_amount	like '%' + @p_keywords + '%'	
				or	os_period						like '%' + @p_keywords + '%'
				or	last_payment_installment_date	like '%' + @p_keywords + '%'	
				or	last_payment_obligation_date	like '%' + @p_keywords + '%'	
				or	payment_promise_date			like '%' + @p_keywords + '%'
			) ;

	select 	agreement_no
		    ,deskcoll_staff_code
		    ,deskcoll_staff_name
		    ,installment_amount
		    ,installment_due_date
		    ,next_due_date
		    ,last_paid_period
		    ,ovd_period
		    ,ovd_days
		    ,ovd_rental_amount
		    ,ovd_penalty_amount
		    ,os_rental_amount
		    ,os_deposit_installment_amount
		    ,os_period
		    ,last_payment_installment_date
		    ,last_payment_obligation_date
		    ,payment_promise_date
			,@rows_count 'rowcount'
	from	dbo.AGREEMENT_INFORMATION
	where	agreement_no = @p_agreement_no
	and		(
				agreement_no						like '%' + @p_keywords + '%'
				or	deskcoll_staff_code				like '%' + @p_keywords + '%'
				or	deskcoll_staff_name				like '%' + @p_keywords + '%'
				or	installment_amount				like '%' + @p_keywords + '%'
				or	installment_due_date			like '%' + @p_keywords + '%'
				or	next_due_date					like '%' + @p_keywords + '%'
				or	last_paid_period				like '%' + @p_keywords + '%'
				or	ovd_period						like '%' + @p_keywords + '%'
				or	ovd_days						like '%' + @p_keywords + '%'
				or	ovd_rental_amount				like '%' + @p_keywords + '%'
				or	ovd_penalty_amount				like '%' + @p_keywords + '%'
				or	os_rental_amount				like '%' + @p_keywords + '%'
				or	os_deposit_installment_amount	like '%' + @p_keywords + '%'	
				or	os_period						like '%' + @p_keywords + '%'
				or	last_payment_installment_date	like '%' + @p_keywords + '%'	
				or	last_payment_obligation_date	like '%' + @p_keywords + '%'	
				or	payment_promise_date			like '%' + @p_keywords + '%'
			)
	order by	case 
					when @p_sort_by='asc' then case @p_order_by
													when 1 then agreement_no
													when 2 then deskcoll_staff_code
													when 3 then deskcoll_staff_name
													when 4 then cast(installment_amount as sql_variant)
													when 5 then installment_due_date
													when 6 then next_due_date
													when 7 then last_paid_period
													when 8 then ovd_period
													when 9 then ovd_days
													when 10 then cast(ovd_rental_amount as sql_variant)
													when 11 then cast(ovd_penalty_amount as sql_variant)
													when 12 then cast(os_rental_amount as sql_variant)
													when 13 then cast(os_deposit_installment_amount as sql_variant)
													when 14 then os_period
													when 15 then last_payment_installment_date
													when 16 then last_payment_obligation_date
													when 17 then payment_promise_date
												end
					end asc,
				case 
					when @p_sort_by='desc' then case @p_order_by 
													when 1 then agreement_no
													when 2 then deskcoll_staff_code
													when 3 then deskcoll_staff_name
													when 4 then cast(installment_amount as sql_variant)
													when 5 then installment_due_date
													when 6 then next_due_date
													when 7 then last_paid_period
													when 8 then ovd_period
													when 9 then ovd_days
													when 10 then cast(ovd_rental_amount as sql_variant)
													when 11 then cast(ovd_penalty_amount as sql_variant)
													when 12 then cast(os_rental_amount as sql_variant)
													when 13 then cast(os_deposit_installment_amount as sql_variant)
													when 14 then os_period
													when 15 then last_payment_installment_date
													when 16 then last_payment_obligation_date
													when 17 then payment_promise_date
												end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only;
end ;
