--Created, Rian at 28/12/2022

CREATE PROCEDURE dbo.xsp_master_bast_checklist_asset_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sys_general_subcode sgs
	where	sgs.general_code = 'ASTYPE'
	and		sgs.is_active = '1'
	and		(
				sgs.code						like '%' + @p_keywords + '%'
				or	sgs.order_key				like '%' + @p_keywords + '%'
				or	sgs.description				like '%' + @p_keywords + '%'
			) ;

	select	sgs.code
			,sgs.general_code
			,sgs.order_key
			,sgs.description
			,@rows_count 'rowcount'
	from	sys_general_subcode sgs
	where	sgs.general_code = 'ASTYPE'
	and		sgs.is_active = '1'
	and		(
				sgs.code						like '%' + @p_keywords + '%'
				or	sgs.order_key				like '%' + @p_keywords + '%'
				or	sgs.description				like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by			
														when 1 then sgs.code
														when 2 then sgs.description
														when 3 then cast(sgs.order_key as sql_variant)		
														
					 								end
				end asc
				,case
					when @p_sort_by = 'desc' then case @p_order_by				
														when 1 then sgs.code
														when 2 then sgs.description
														when 3 then cast(sgs.order_key as sql_variant)		
																
					 								end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
