CREATE PROCEDURE dbo.xsp_master_ojk_reference_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_reference_type_code nvarchar(50)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	master_ojk_reference mor
			inner join dbo.sys_general_subcode sgs on (sgs.code = mor.reference_type_code)
	where	reference_type_code	= case @p_reference_type_code
									when 'ALL' then reference_type_code
									else @p_reference_type_code
							  end
			and (
				mor.code								like 	'%'+@p_keywords+'%'
				or	mor.description						like 	'%'+@p_keywords+'%'
				or	sgs.description						like 	'%'+@p_keywords+'%'
				or	mor.ojk_code						like 	'%'+@p_keywords+'%'
				or	 case mor.is_active
						 when '1' then 'Yes'
						 else 'No'
				     end 							like 	'%'+@p_keywords+'%'

			);

		select	mor.code
				,mor.description
				,sgs.description 'reference_type_name'
				,mor.ojk_code
				,case mor.is_active
					 when '1' then 'Yes'
					 else 'No'
				 end 	'is_active'
				,@rows_count	 'rowcount'
		from	master_ojk_reference mor
				inner join dbo.sys_general_subcode sgs on (sgs.code = mor.reference_type_code)
		where	reference_type_code	= case @p_reference_type_code
										when 'ALL' then reference_type_code
										else @p_reference_type_code
								  end
				and (
					mor.code								like 	'%'+@p_keywords+'%'
					or	mor.description						like 	'%'+@p_keywords+'%'
					or	sgs.description						like 	'%'+@p_keywords+'%'
					or	mor.ojk_code						like 	'%'+@p_keywords+'%'
					or	 case mor.is_active
							 when '1' then 'Yes'
							 else 'No'
						 end 							like 	'%'+@p_keywords+'%'

				)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1	then mor.code
														when 2	then mor.description
														when 3	then sgs.description
														when 4	then mor.ojk_code
														when 5	then mor.is_active
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1	then mor.code
														when 2	then mor.description
														when 3	then sgs.description
														when 4	then mor.ojk_code
														when 5	then mor.is_active
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end
