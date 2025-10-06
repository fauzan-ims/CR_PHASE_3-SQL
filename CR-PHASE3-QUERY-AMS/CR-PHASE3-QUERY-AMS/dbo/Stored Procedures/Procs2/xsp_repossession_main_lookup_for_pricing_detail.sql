CREATE PROCEDURE dbo.xsp_repossession_main_lookup_for_pricing_detail
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_pricing_code	nvarchar(50)
	,@p_branch_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	repossession_main rmn
			inner join dbo.asset ast on (ast.code = rmn.asset_code)
	where	rmn.exit_date is null
			and (rmn.repossession_status = 'REPO I' or rmn.repossession_status = 'REPO II' or rmn.repossession_status = 'INVENTORY' or rmn.repossession_status = 'REPO WO')
			--and rmn.repossession_status_process = ''
			and rmn.exit_status = ''
			and rmn.branch_code = @p_branch_code
			and rmn.is_permit_to_sell = '1'
			and not exists (select rpd.asset_code from dbo.repossession_pricing_detail rpd where rpd.asset_code = rmn.code) 
			and	(
					rmn.code								like '%' + @p_keywords + '%'
					or	rmn.asset_code						like '%' + @p_keywords + '%'
					or	rmn.item_name						like '%' + @p_keywords + '%'
					or	rmn.pricing_amount					like '%' + @p_keywords + '%'
				) ;

		select		rmn.code
					,rmn.asset_code							
					,rmn.item_name	
					,rmn.pricing_amount				
					,@rows_count 'rowcount'
		from		repossession_main rmn
					inner join dbo.ASSET ast on (ast.CODE = rmn.ASSET_CODE)
		where		rmn.exit_date is null
					and (rmn.repossession_status = 'REPO I' or rmn.repossession_status = 'REPO II' or rmn.repossession_status = 'INVENTORY' or rmn.repossession_status = 'REPO WO')
					--and rmn.repossession_status_process = ''
					and rmn.exit_status = ''
					and rmn.branch_code = @p_branch_code
					and rmn.is_permit_to_sell = '1'
					and not exists (select rpd.asset_code from dbo.repossession_pricing_detail rpd where rpd.asset_code = rmn.code) 
					and	(
							rmn.code								like '%' + @p_keywords + '%'
							or	rmn.asset_code						like '%' + @p_keywords + '%'
							or	rmn.item_name						like '%' + @p_keywords + '%'
							or	rmn.pricing_amount					like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then rmn.code
													 when 2 then rmn.asset_code
													 when 3 then ast.item_name		
													 when 4 then cast(rmn.pricing_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													  when 1 then rmn.code
													  when 2 then rmn.asset_code
													  when 3 then rmn.item_name		
													  when 4 then cast(rmn.pricing_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
