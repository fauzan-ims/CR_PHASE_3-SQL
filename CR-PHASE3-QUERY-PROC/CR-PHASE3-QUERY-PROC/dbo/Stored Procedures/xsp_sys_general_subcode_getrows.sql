CREATE PROCEDURE dbo.xsp_sys_general_subcode_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_general_code	nvarchar(50)
	,@p_company_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sys_general_subcode sgs
			inner join dbo.sys_general_code sgc on sgc.code = sgs.general_code and sgc.company_code = sgs.company_code
	where	sgs.general_code = @p_general_code
	and		sgs.company_code = @p_company_code
	and		(
				sgs.code						like '%' + @p_keywords + '%'
				or	sgs.description				like '%' + @p_keywords + '%'
				or	sgs.order_key				like '%' + @p_keywords + '%'
				or	case sgs.is_active
						when '1' then 'Yes'
						else 'No'
					end							like '%' + @p_keywords + '%'
			) ;

	select		sgs.code
				,sgc.description 'general_desc'
				,sgs.order_key
				,sgs.description
				,case sgs.is_active
						when '1' then 'Yes'
						else 'No'
					end 'is_active'
				,@rows_count 'rowcount'
	from		sys_general_subcode sgs
				inner join dbo.sys_general_code sgc on sgc.code = sgs.general_code and sgc.company_code = sgs.company_code
	where		sgs.general_code = @p_general_code
	and			sgs.company_code = @p_company_code
	and			(
						sgs.code						like '%' + @p_keywords + '%'
						or	sgs.description				like '%' + @p_keywords + '%'
						or	sgs.order_key				like '%' + @p_keywords + '%'
						or	case sgs.is_active
								when '1' then 'Yes'
								else 'No'
							end							like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by			
														when 1 then sgs.code
														when 2 then sgs.description
														when 3 then cast(sgs.order_key as sql_variant)
														when 4 then sgs.is_active
					 								end
				end asc
				,case
					when @p_sort_by = 'desc' then case @p_order_by				
														when 1 then sgs.code
														when 2 then sgs.description
														when 3 then cast(sgs.order_key as sql_variant)
														when 4 then sgs.is_active
					 								end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
