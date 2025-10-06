---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_electronic_category_getrows
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
	from	master_electronic_category mfc
	where	(
				mfc.code					like '%' + @p_keywords + '%'
				or	mfc.description			like '%' + @p_keywords + '%'
				or	case mfc.is_active
						when '1' then 'Yes'
						else 'No'
					end						like '%' + @p_keywords + '%'
			) ;

		select		mfc.code
					,mfc.description
					,case mfc.is_active
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_active'
					,@rows_count 'rowcount'
		from		master_electronic_category mfc
		where		(
						mfc.code					like '%' + @p_keywords + '%'
						or	mfc.description			like '%' + @p_keywords + '%'
						or	case mfc.is_active
								when '1' then 'Yes'
								else 'No'
							end						like '%' + @p_keywords + '%'
					)

	Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mfc.code
													when 2 then mfc.description
													when 3 then mfc.is_active
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then mfc.code
														when 2 then mfc.description
														when 3 then mfc.is_active
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;


