CREATE PROCEDURE [dbo].[xsp_et_detail_getrows_external]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_et_code	   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	et_detail ed
			inner join dbo.agreement_asset aa on (aa.asset_no = ed.asset_no)
	where	ed.et_code = @p_et_code
			and (
					ed.id					like '%' + @p_keywords + '%'
					or is_terminate			like '%' + @p_keywords + '%'
					or aa.asset_name		like '%' + @p_keywords + '%'
					or ed.os_rental_amount	like '%' + @p_keywords + '%'
				) ;

	select		ed.id
				,is_terminate						
				,aa.asset_name						
				,ed.os_rental_amount	 	
				,@rows_count 'rowcount'
	from		et_detail ed
				inner join dbo.agreement_asset aa on (aa.asset_no = ed.asset_no)
	where		ed.et_code = @p_et_code
				and (
						ed.id					like '%' + @p_keywords + '%'
						or is_terminate			like '%' + @p_keywords + '%'
						or aa.asset_name		like '%' + @p_keywords + '%'
						or ed.os_rental_amount	like '%' + @p_keywords + '%'
					)
					
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then ed.is_terminate								
														when 2 then aa.asset_name					
														when 3 then cast(ed.os_rental_amount as sql_variant) 
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then ed.is_terminate								
														when 2 then aa.asset_name					
														when 3 then cast(ed.os_rental_amount as sql_variant) 
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

