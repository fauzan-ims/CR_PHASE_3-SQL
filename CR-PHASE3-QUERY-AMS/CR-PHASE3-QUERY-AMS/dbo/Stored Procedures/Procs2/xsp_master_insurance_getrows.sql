CREATE PROCEDURE dbo.xsp_master_insurance_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_insurance
	where	(
				insurance_no														like '%' + @p_keywords + '%'
				or	insurance_name					 								like '%' + @p_keywords + '%'
				or	contact_person_area_phone_no + ' - ' + contact_person_phone_no	like '%' + @p_keywords + '%'
				or	contact_person_name												like '%' + @p_keywords + '%'
				or	case insurance_type
						when 'LIFE' then 'LIFE'
						when 'CREDIT' then 'CREDIT'
						else 'COLLATERAL'
					end																like '%' + @p_keywords + '%'
				or	case is_validate
						when '1' then 'Yes'
						else 'No'
					end																like '%' + @p_keywords + '%'
			) ;

		select		code
					,insurance_no
					,insurance_name	
					,contact_person_area_phone_no
					,contact_person_phone_no
					,contact_person_name				
					,case insurance_type
						when 'LIFE' then 'LIFE'
						when 'CREDIT' then 'CREDIT'
						else 'COLLATERAL'
					 end 'insurance_type'			
					,case is_validate
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_validate'
					,@rows_count 'rowcount'
		from		master_insurance
		where		(
						insurance_no														like '%' + @p_keywords + '%'
						or	insurance_name													like '%' + @p_keywords + '%'
						or	contact_person_area_phone_no + ' - ' + contact_person_phone_no	like '%' + @p_keywords + '%'
						or	contact_person_name												like '%' + @p_keywords + '%'
						or	case insurance_type
								when 'LIFE' then 'LIFE'
								when 'CREDIT' then 'CREDIT'
								else 'COLLATERAL'
							end																like '%' + @p_keywords + '%'
						or	case is_validate
								when '1' then 'Yes'
								else 'No'
							end																like '%' + @p_keywords + '%'
					)
		order by case when @p_sort_by = 'asc' then case @p_order_by
													when 1 then insurance_no
													when 2 then insurance_name	
													when 3 then contact_person_area_phone_no + contact_person_phone_no		
													when 4 then contact_person_name				
													when 5 then insurance_type			
													when 6 then is_validate	
												  end
					end 
					,case when @p_sort_by = 'desc' then CASE @p_order_by
													when 1 then insurance_no
													when 2 then insurance_name	
													when 3 then contact_person_area_phone_no + contact_person_phone_no		
													when 4 then contact_person_name				
													when 5 then insurance_type			
													when 6 then is_validate	
												   end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;

