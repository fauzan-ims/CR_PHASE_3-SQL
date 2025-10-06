CREATE PROCEDURE dbo.xsp_application_disbursement_plan_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_application_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_disbursement_plan
	where	application_no = @p_application_no
			and (
					disbursement_to								like '%' + @p_keywords + '%'
					or	convert(varchar(30), plan_date, 103)	like '%' + @p_keywords + '%'
					or	disbursement_pct						like '%' + @p_keywords + '%'
					or	disbursement_amount						like '%' + @p_keywords + '%'
					or	bank_name								like '%' + @p_keywords + '%'
					or	bank_account_no							like '%' + @p_keywords + '%'
					or	bank_account_name						like '%' + @p_keywords + '%'
					or	currency_code							like '%' + @p_keywords + '%'
				) ;
 
		select		code
					,disbursement_to
					,convert(varchar(30), plan_date, 103) 'plan_date'
					,disbursement_pct
					,disbursement_amount					
					,bank_name							
					,bank_account_no						
					,bank_account_name		
					,currency_code			
					,@rows_count 'rowcount'
		from		application_disbursement_plan
		where		application_no = @p_application_no
					and (
							disbursement_to								like '%' + @p_keywords + '%'
							or	convert(varchar(30), plan_date, 103)	like '%' + @p_keywords + '%'
							or	disbursement_pct						like '%' + @p_keywords + '%'
							or	disbursement_amount						like '%' + @p_keywords + '%'
							or	bank_name								like '%' + @p_keywords + '%'
							or	bank_account_no							like '%' + @p_keywords + '%'
							or	bank_account_name						like '%' + @p_keywords + '%'
							or	currency_code							like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then disbursement_to
													when 2 then cast(plan_date as sql_variant)	
													when 3 then currency_code
													when 4 then cast(disbursement_pct as sql_variant)	
													when 5 then cast(disbursement_amount as sql_variant)						
													when 6 then bank_name + bank_account_no	+ bank_account_name	
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then disbursement_to
													when 2 then cast(plan_date as sql_variant)	
													when 3 then currency_code
													when 4 then cast(disbursement_pct as sql_variant)	
													when 5 then cast(disbursement_amount as sql_variant)						
													when 6 then bank_name + bank_account_no	+ bank_account_name	
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

