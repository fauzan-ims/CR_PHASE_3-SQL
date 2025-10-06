CREATE PROCEDURE dbo.xsp_application_step_period_getrows
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
	from	application_step_period
	where	application_no = @p_application_no
			and (
					step_no							like '%' + @p_keywords + '%'
					or	number_of_installment		like '%' + @p_keywords + '%'
					or	recovery_flag				like '%' + @p_keywords + '%'
					or	even_method					like '%' + @p_keywords + '%'
					or	recovery_principal_amount	like '%' + @p_keywords + '%'
					or	recovery_installment_amount like '%' + @p_keywords + '%'
				) ;

		select		code
					,step_no
					,number_of_installment		
					,recovery_flag				
					,even_method					
					,recovery_principal_amount	
					,recovery_installment_amount 
					,@rows_count 'rowcount'
		from		application_step_period
		where		application_no = @p_application_no
					and (
							step_no							like '%' + @p_keywords + '%'
							or	number_of_installment		like '%' + @p_keywords + '%'
							or	recovery_flag				like '%' + @p_keywords + '%'
							or	even_method					like '%' + @p_keywords + '%'
							or	recovery_principal_amount	like '%' + @p_keywords + '%'
							or	recovery_installment_amount like '%' + @p_keywords + '%'
						)

	Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then try_cast(step_no as nvarchar(20))
													when 2 then try_cast(number_of_installment as nvarchar(20))		
													when 3 then recovery_flag				
													when 4 then even_method				
													when 5 then try_cast(recovery_principal_amount as nvarchar(20))	
													when 6 then try_cast(recovery_installment_amount as nvarchar(20)) 
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then try_cast(step_no as nvarchar(20))
														when 2 then try_cast(number_of_installment as nvarchar(20))		
														when 3 then recovery_flag				
														when 4 then even_method				
														when 5 then try_cast(recovery_principal_amount as nvarchar(20))	
														when 6 then try_cast(recovery_installment_amount as nvarchar(20)) 
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

