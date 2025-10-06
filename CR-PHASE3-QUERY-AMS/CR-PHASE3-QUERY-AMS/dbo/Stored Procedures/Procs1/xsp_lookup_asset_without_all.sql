CREATE PROCEDURE dbo.xsp_lookup_asset_without_all
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)	
	--
	,@p_branch_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	FROM	dbo.asset a
	left join dbo.asset_vehicle av on (av.asset_code = a.code)
	where	branch_code = case @p_branch_code
					when 'All' then branch_code
					else @p_branch_code
				 END
			AND a.STATUS <> 'CANCEL'		
	and	(
			code			like '%' + @p_keywords + '%'
			or	item_name	like '%' + @p_keywords + '%'
			or	av.plat_no	like '%' + @p_keywords + '%'
		) ;


						
	select	code
			,item_name 'name'
			,plat_no
			,@rows_count 'rowcount'
	from	dbo.asset a
	left join dbo.asset_vehicle av on (av.asset_code = a.code)
	where	branch_code = case @p_branch_code
			when 'ALL' then branch_code
			else @p_branch_code
			end				
			AND a.STATUS <> 'CANCEL'
	and		(
				code			like '%' + @p_keywords + '%'
				or	av.plat_no	like '%' + @p_keywords + '%'
				or	item_name	like '%' + @p_keywords + '%'
						)

			order by 	case  
						when @p_sort_by = 'asc' then case @p_order_by
														when 1 then a.code
														when 2 then a.item_name 
														when 3 then av.plat_no 
						  							end
					end asc 
					,case 
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then a.code
														when 2 then item_name
														when 3 then av.plat_no 
						  							end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	END;
    
