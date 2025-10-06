CREATE PROCEDURE dbo.xsp_master_ojk_reference_lookup
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
	from	master_ojk_reference  mor
			inner join dbo.sys_general_subcode sgs on (sgs.code = mor.reference_type_code)
	where	mor.is_active  = '1'
			and reference_type_code = @p_reference_type_code
			and (
					mor.ojk_code			like 	'%'+@p_keywords+'%'
					or	mor.description		like 	'%'+@p_keywords+'%'
				);

		select	mor.code
				,mor.ojk_code
				,mor.description
				,@rows_count	 'rowcount'
		from	master_ojk_reference  mor
				inner join dbo.sys_general_subcode sgs on (sgs.code = mor.reference_type_code)
		where	mor.is_active  = '1'
				and reference_type_code = @p_reference_type_code
				and (
						mor.ojk_code			like 	'%'+@p_keywords+'%'
						or	mor.description		like 	'%'+@p_keywords+'%'
					)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1	then mor.ojk_code
														when 2	then mor.description
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1	then mor.ojk_code
														when 2	then mor.description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end
