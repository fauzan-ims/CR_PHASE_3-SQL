CREATE PROCEDURE dbo.xsp_lookup_asset_for_controlbranch
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)	
	--
	,@p_branch_code		nvarchar(50)
	,@p_for_all			nvarchar(1) = ''
)
as
begin
	declare @rows_count int = 0 ;
	
	if (@p_for_all <> '')
	BEGIN
		select	@rows_count = count(1)
		from
				(
					select	' ALL' as 'code'
							,' ALL' as 'name'
					union
					select	code
							,item_name
					from	dbo.asset
					where branch_code = case @p_branch_code
									when 'All' then branch_code
									else @p_branch_code
								 end					
				) as asset
		where	(
					asset.code		like '%' + @p_keywords + '%'
					or	asset.name  like '%' + @p_keywords + '%'
				) ;

			select		*
			from
						(
							select	' ALL' as 'code'
									,' ALL' as 'name'
									,@rows_count 'rowcount'
							union
							select	code
									,item_name
									,@rows_count 'rowcount'
							from	dbo.asset
							where branch_code = case @p_branch_code
									when 'ALL' then branch_code
									else @p_branch_code
								 end				
						) as asset
			where		(
							asset.code		like '%' + @p_keywords + '%'
							or	asset.name  like '%' + @p_keywords + '%'
						)

			order by 	case  
						when @p_sort_by = 'asc' then case @p_order_by
														when 1 then asset.code
														when 2 then asset.name
						  							end
					end asc 
					,case 
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then asset.code
														when 2 then asset.name
						  							end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	END
    ELSE
    begin

	select	@rows_count = count(1)
	from	dbo.asset
	where	branch_code = case @p_branch_code
								 when 'ALL' then branch_code
								 else @p_branch_code
							end
	and		(
				code 		like '%' + @p_keywords + '%'
				or	item_name	like '%' + @p_keywords + '%'
			) ;


	select	code 'asset_code'
			,item_name
			,@rows_count 'rowcount'
	from	dbo.ASSET
	where	branch_code = case @p_branch_code
								 when 'ALL' then branch_code
								 else @p_branch_code
							end
	and		(
				CODE		like '%' + @p_keywords + '%'
				or	item_name	like '%' + @p_keywords + '%'
			)
	order by	 case
						when @p_sort_by = 'asc' then case @p_order_by
							when 1 then code
							WHEN 2 then item_name
					end
				end asc,
				case
						when @p_sort_by = 'desc' then case @p_order_by
							when 1 then code
							WHEN 2 then item_name
					end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	
end ;
end
