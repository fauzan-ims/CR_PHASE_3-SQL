---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE dbo.xsp_master_machinery_subcategory_getrows
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
	from	master_machinery_subcategory mms
			inner join dbo.master_machinery_category mmc on (mmc.code = mms.machinery_category_code)
	where	(
				mms.code							like '%' + @p_keywords + '%'
				or	mmc.description					like '%' + @p_keywords + '%'
				or	mms.description					like '%' + @p_keywords + '%'
				or	case mms.is_active
						when '1' then 'Yes'
						else 'No'
					end								like '%' + @p_keywords + '%'
			) ;
			 
		select		mms.code
					,mmc.description 'machinery_category_name'
					,mms.description
					,case mms.is_active
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_active'
					,@rows_count 'rowcount'
		from		master_machinery_subcategory mms
					inner join dbo.master_machinery_category mmc on (mmc.code = mms.machinery_category_code)
		where		(
						mms.code							like '%' + @p_keywords + '%'
						or	mmc.description					like '%' + @p_keywords + '%'
						or	mms.description					like '%' + @p_keywords + '%'
						or	case mms.is_active
								when '1' then 'Yes'
								else 'No'
							end								like '%' + @p_keywords + '%'
					) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mms.code
													when 2 then mmc.description	
													when 3 then mms.description	
													when 4 then mms.is_active
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then mms.code
													when 2 then mmc.description	
													when 3 then mms.description	
													when 4 then mms.is_active
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;



