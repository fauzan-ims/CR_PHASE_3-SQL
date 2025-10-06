CREATE PROCEDURE dbo.xsp_sys_general_subcode_lookup
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_general_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sys_general_subcode sgs
	where	sgs.general_code = @p_general_code
			and (
					sgs.description				like '%' + @p_keywords + '%'
				) ;

		select		sgs.code
					,sgs.description 'general_subcode_desc'
					,@rows_count 'rowcount'
		from		sys_general_subcode sgs
		where		sgs.general_code = @p_general_code
					and (
							sgs.description				like '%' + @p_keywords + '%'

						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then sgs.description
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then sgs.description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
