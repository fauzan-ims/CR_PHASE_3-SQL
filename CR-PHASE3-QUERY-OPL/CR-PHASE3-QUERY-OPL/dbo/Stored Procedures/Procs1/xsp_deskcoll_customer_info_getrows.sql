CREATE PROCEDURE dbo.xsp_deskcoll_customer_info_getrows
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	--
	,@p_agreement_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.deskcoll_customer_info dci
			inner join dbo.task_main tm on (tm.deskcoll_main_id				= dci.deskcoll_id)
			inner join dbo.agreement_customer ac on (dci.customer_client_no = ac.customer_client_no and ac.agreement_no = tm.agreement_no)
	where	ac.agreement_no = @p_agreement_no
			and (
					dci.customer_client_no								like '%' + @p_keywords + '%'
					or	ac.customer_client_name							like '%' + @p_keywords + '%'
					or	dci.invoice_no									like '%' + @p_keywords + '%'
					or	ac.contact_person_area_phone_no					like '%' + @p_keywords + '%'
					or	ac.contact_person_phone_no						like '%' + @p_keywords + '%'
					or	dci.transaction_amount							like '%' + @p_keywords + '%'
					or	dci.os_invoice_amount							like '%' + @p_keywords + '%'
					or	convert(varchar(30), dci.invoice_due_date, 103) like '%' + @p_keywords + '%'
					or	tm.overdue_days									like '%' + @p_keywords + '%'
					or	ac.area_mobile_no								like '%' + @p_keywords + '%'
					or	ac.mobile_no									like '%' + @p_keywords + '%'
					or	ac.email										like '%' + @p_keywords + '%'
				) ;

	select		dci.customer_client_no
				,ac.customer_client_name
				,dci.invoice_no
				,dci.transaction_amount
				,dci.os_invoice_amount
				,ac.contact_person_phone_no
				,ac.contact_person_area_phone_no
				,convert(varchar(30), dci.invoice_due_date, 103) 'invoice_due_date'
				,datediff(day, dci.invoice_due_date , tm.task_date ) 'over_due_days'
				,tm.task_date
				,ac.area_mobile_no
				,ac.mobile_no
				,ac.email
				,@rows_count 'rowcount'
	from		dbo.deskcoll_customer_info dci
				inner join dbo.task_main tm on (tm.deskcoll_main_id				= dci.deskcoll_id)
				inner join dbo.agreement_customer ac on (dci.customer_client_no = ac.customer_client_no and ac.agreement_no = tm.agreement_no)
	where		ac.agreement_no = @p_agreement_no
				and (
								dci.customer_client_no							like '%' + @p_keywords + '%'
							or	ac.customer_client_name							like '%' + @p_keywords + '%'
							or	dci.invoice_no									like '%' + @p_keywords + '%'
							or	ac.contact_person_area_phone_no					like '%' + @p_keywords + '%'
							or	ac.contact_person_phone_no						like '%' + @p_keywords + '%'
							or	dci.transaction_amount							like '%' + @p_keywords + '%'
							or	dci.os_invoice_amount							like '%' + @p_keywords + '%'
							or	convert(varchar(30), dci.invoice_due_date, 103) like '%' + @p_keywords + '%'
							or	ac.area_mobile_no								like '%' + @p_keywords + '%'
							or	ac.mobile_no									like '%' + @p_keywords + '%'
							or	ac.email										like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ac.customer_client_no
													 when 2 then ac.contact_person_area_phone_no + ac.contact_person_phone_no
													 when 3 then ac.email
													 when 4 then dci.invoice_no
													 when 5 then cast(dci.invoice_due_date as sql_variant)
													 when 6 then cast(dci.transaction_amount as sql_variant)
													 when 7 then cast(dci.os_invoice_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then ac.customer_client_no
													   when 2 then ac.contact_person_area_phone_no + ac.contact_person_phone_no
													   when 3 then ac.email
													   when 4 then dci.invoice_no
													   when 5 then cast(dci.invoice_due_date as sql_variant)
													   when 6 then cast(dci.transaction_amount as sql_variant)
													   when 7 then cast(dci.os_invoice_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
