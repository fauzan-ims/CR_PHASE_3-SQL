CREATE PROCEDURE dbo.xsp_sys_general_document_getrows
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
	from	sys_general_document
	where	(
				document_name				like '%' + @p_keywords + '%'
				or	case is_temp
						when '1' then 'Yes'
						else 'No'
					end								like '%' + @p_keywords + '%'
				or	case is_physical
						when '1' then 'Yes'
						else 'No'
					end								like '%' + @p_keywords + '%'
				or	case is_allow_out
						when '1' then 'Yes'
						else 'No'
					end								like '%' + @p_keywords + '%'
				or	case is_collateral
						when '1' then 'Yes'
						else 'No'
					end								like '%' + @p_keywords + '%'
				or	case is_active
							when '1' then 'Yes'
							else 'No'
					end								like '%' + @p_keywords + '%'
			) ;

		select		code
					,document_name
					,case is_temp
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_temp'
					,case is_physical
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_physical'
					,case is_allow_out
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_allow_out'
					,case is_collateral
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_collateral'
					,case is_active
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_active'
					,@rows_count 'rowcount'
		from		sys_general_document
		where		(
						document_name		like '%' + @p_keywords + '%'
						or	case is_temp
								when '1' then 'Yes'
								else 'No'
							end								like '%' + @p_keywords + '%'
						or	case is_physical
								when '1' then 'Yes'
								else 'No'
							end								like '%' + @p_keywords + '%'
						or	case is_allow_out
								when '1' then 'Yes'
								else 'No'
							end								like '%' + @p_keywords + '%'
						or	case is_collateral
								when '1' then 'Yes'
								else 'No'
							end								like '%' + @p_keywords + '%'
						or	case is_active
									when '1' then 'Yes'
									else 'No'
							end								like '%' + @p_keywords + '%'
					)
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then document_name
													when 2 then is_temp
													when 3 then is_collateral
													when 4 then is_physical
													when 5 then is_allow_out
													when 6 then is_active
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then document_name
														when 2 then is_temp
														when 3 then is_collateral
														when 4 then is_physical
														when 5 then is_allow_out
														when 6 then is_active
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;
