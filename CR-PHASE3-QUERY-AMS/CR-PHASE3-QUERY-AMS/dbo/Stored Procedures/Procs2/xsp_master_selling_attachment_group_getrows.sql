CREATE PROCEDURE [dbo].[xsp_master_selling_attachment_group_getrows]
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	dbo.master_selling_attachment_group g
			--inner join dbo.sys_general_subcode s on (s.code = g.document_group_type_code)
	where	(
				g.description				like 	'%'+@p_keywords+'%'
				or	case g.is_active
							when '1' then 'Yes'
							else 'No'
					end 					like 	'%'+@p_keywords+'%'
				or	g.sell_type				like 	'%'+@p_keywords+'%'
			);

		select	g.code
				,g.description
				,case g.is_active
					 when '1' then 'Yes'
					 else 'No'
				 end 'is_active'
				--,s.description 'document_group_type_name'
				,g.sell_type
				,@rows_count	 'rowcount'
		from	dbo.master_selling_attachment_group g
				--inner join dbo.sys_general_subcode s on (s.code = g.document_group_type_code)
		where	(
					g.description				like 	'%'+@p_keywords+'%'
					or	case g.is_active
							 when '1' then 'Yes'
							 else 'No'
						end 					like 	'%'+@p_keywords+'%'
					or	g.sell_type				like 	'%'+@p_keywords+'%'
				)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1	then g.description
													when 2	then g.sell_type
													when 3	then g.is_active 
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1	then g.description
														when 2	then g.sell_type
														when 3	then g.is_active 
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end
