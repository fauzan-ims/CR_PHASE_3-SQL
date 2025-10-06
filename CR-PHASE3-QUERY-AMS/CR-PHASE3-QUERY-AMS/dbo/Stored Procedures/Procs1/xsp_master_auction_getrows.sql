CREATE PROCEDURE dbo.xsp_master_auction_getrows
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
	from	master_auction
	where	(
				code							like '%' + @p_keywords + '%'
				or	auction_name				like '%' + @p_keywords + '%'
				or	contact_person_name			like '%' + @p_keywords + '%'
				or	contact_person_area_phone_no + ' - ' 
					+ contact_person_phone_no	like '%' + @p_keywords + '%'
				or	case is_validate
						when '1' then 'Yes'
						else 'No'
					end							like '%' + @p_keywords + '%'
			) ;

		select		code
					,auction_name			
					,contact_person_name		
					,email
					,contact_person_area_phone_no					
					,contact_person_phone_no
					,@rows_count 'rowcount'
					,case is_validate
						when '1' then 'Yes'
						else 'No'
					 end 'validated'
		from		master_auction
		where		(
						code							like '%' + @p_keywords + '%'
						or	auction_name				like '%' + @p_keywords + '%'
						or	contact_person_name			like '%' + @p_keywords + '%'
						or	contact_person_area_phone_no + ' - ' 
							+ contact_person_phone_no	like '%' + @p_keywords + '%'
						or	case is_validate
								when '1' then 'Yes'
								else 'No'
							end							like '%' + @p_keywords + '%'
					)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then auction_name			
													 when 3 then contact_person_area_phone_no + contact_person_phone_no
													 when 4 then contact_person_name
													 when 5 then case is_validate
													 				when '1' then 'Yes'
													 				else 'No'
													 			 end
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then auction_name			
													   when 3 then contact_person_area_phone_no + contact_person_phone_no
													   when 4 then contact_person_name
													   when 5 then case is_validate
													   				  when '1' then 'Yes'
													   				  else 'No'
													   			   end
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
