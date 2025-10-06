CREATE PROCEDURE [dbo].[xsp_application_amortization_simulation_getrows]
(
	@p_keywords						nvarchar(50)
	,@p_pagenumber					int
	,@p_rowspage					int
	,@p_order_by					int
	,@p_sort_by						nvarchar(5)
	,@p_application_simulation_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_amortization_simulation
	where	application_simulation_code = @p_application_simulation_code
			and (
					installment_no							like '%' + @p_keywords + '%'
					or	convert(varchar(30), due_date, 103) like '%' + @p_keywords + '%'
					or	installment_principal_amount		like '%' + @p_keywords + '%'
					or	installment_interest_amount			like '%' + @p_keywords + '%'
					or	installment_amount					like '%' + @p_keywords + '%'
					or	os_principal_amount					like '%' + @p_keywords + '%'
				) ;
 
	select		application_simulation_code
				,installment_no
				,convert(varchar(30), due_date, 103) 'due_date'
				,installment_principal_amount
				,installment_interest_amount
				,installment_amount
				,os_principal_amount
				,@rows_count 'rowcount'
	from		application_amortization_simulation
	where		application_simulation_code = @p_application_simulation_code
				and (
						installment_no							like '%' + @p_keywords + '%'
						or	convert(varchar(30), due_date, 103) like '%' + @p_keywords + '%'
						or	installment_principal_amount		like '%' + @p_keywords + '%'
						or	installment_interest_amount			like '%' + @p_keywords + '%'
						or	installment_amount					like '%' + @p_keywords + '%'
						or	os_principal_amount					like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then cast(installment_no as sql_variant)
														when 2 then convert(varchar(30), due_date, 103)
														when 3 then cast(installment_amount as sql_variant)
														when 4 then cast(installment_principal_amount as sql_variant)
														when 5 then cast(installment_interest_amount as sql_variant)
														when 6 then cast(os_principal_amount as sql_variant)
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then cast(installment_no as sql_variant)
														when 2 then convert(varchar(30), due_date, 103)
														when 3 then cast(installment_amount as sql_variant)
														when 4 then cast(installment_principal_amount as sql_variant)
														when 5 then cast(installment_interest_amount as sql_variant)
														when 6 then cast(os_principal_amount as sql_variant)
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;  
end ;

