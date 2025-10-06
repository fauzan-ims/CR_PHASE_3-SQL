CREATE PROCEDURE dbo.xsp_master_insurance_bank_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_insurance_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_insurance_bank
	where	insurance_code = @p_insurance_code
			and (
					id								like '%' + @p_keywords + '%'
					or	bank_name					like '%' + @p_keywords + '%'
					or	bank_branch					like '%' + @p_keywords + '%'
					or	bank_account_name			like '%' + @p_keywords + '%'
					or	bank_account_no				like '%' + @p_keywords + '%'
					or	case is_default
							when '1' then 'Yes'
							else 'No'
						end							like '%' + @p_keywords + '%'
				) ;
		select		id
					,bank_name
					,bank_branch
					,bank_account_no
					,bank_account_name
					,case is_default
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_default'
					,@rows_count 'rowcount'
		from		master_insurance_bank
		where		insurance_code = @p_insurance_code
					and (
							id								like '%' + @p_keywords + '%'
							or	bank_name					like '%' + @p_keywords + '%'
							or	bank_branch					like '%' + @p_keywords + '%'
							or	bank_account_name			like '%' + @p_keywords + '%'
							or	bank_account_no				like '%' + @p_keywords + '%'
							or	case is_default
									when '1' then 'Yes'
									else 'No'
								end							like '%' + @p_keywords + '%'
						)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then bank_name			
													when 2 then bank_branch			
													when 3 then bank_account_name	
													when 4 then bank_account_no		
													when 5 then is_default
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then bank_name			
													when 2 then bank_branch			
													when 3 then bank_account_name	
													when 4 then bank_account_no		
													when 5 then is_default
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;


