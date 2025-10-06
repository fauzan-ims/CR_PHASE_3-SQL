CREATE PROCEDURE dbo.xsp_repossession_pricing_detail_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_pricing_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	repossession_pricing_detail rdp
			left join dbo.repossession_main rmn on (rmn.code			 = rdp.asset_code)
			--left join dbo.agreement_main amn on (amn.agreement_no		 = rmn.agreement_no)
			--left join dbo.agreement_collateral acl on (acl.collateral_no = rmn.collateral_no)
	where	rdp.pricing_code = @p_pricing_code
			and	(
					rdp.id									like '%' + @p_keywords + '%'
					or	rdp.asset_code						like '%' + @p_keywords + '%'
					--or	amn.agreement_external_no			like '%' + @p_keywords + '%'
					--or	amn.client_name						like '%' + @p_keywords + '%'
					--or	acl.collateral_external_no			like '%' + @p_keywords + '%'
					--or	acl.collateral_name					like '%' + @p_keywords + '%'
					or	rdp.pricelist_amount				like '%' + @p_keywords + '%'
					or	rmn.pricing_amount					like '%' + @p_keywords + '%'
					or	rdp.request_amount					like '%' + @p_keywords + '%'
					or	rdp.approve_amount					like '%' + @p_keywords + '%'
				) ;

		select		rdp.id
					,rdp.asset_code		
					,rmn.asset_code 'code_asset'				
					,rmn.item_name				
					,rdp.pricelist_amount			
					,rmn.pricing_amount			
					,rdp.request_amount			
					,rdp.approve_amount			
					,@rows_count 'rowcount'
		from		repossession_pricing_detail rdp
					left join dbo.repossession_main rmn on (rmn.code			 = rdp.asset_code)
		where		rdp.pricing_code = @p_pricing_code
					and	(
							rdp.id									like '%' + @p_keywords + '%'
							or	rdp.asset_code						like '%' + @p_keywords + '%'
							or	rdp.pricelist_amount				like '%' + @p_keywords + '%'
							or	rmn.pricing_amount					like '%' + @p_keywords + '%'
							or	rdp.request_amount					like '%' + @p_keywords + '%'
							or	rdp.approve_amount					like '%' + @p_keywords + '%'
						)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then rdp.asset_code
														when 2 then rmn.asset_code
														when 3 then rmn.item_name
														when 4 then cast(rdp.pricelist_amount as sql_variant)
														when 5 then cast(rmn.pricing_amount as sql_variant)
														when 6 then cast(rdp.request_amount as sql_variant)
														when 7 then cast(rdp.approve_amount as sql_variant)
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then rdp.asset_code
														when 2 then rmn.asset_code
														when 3 then rmn.item_name
														when 4 then cast(rdp.pricelist_amount as sql_variant)
														when 5 then cast(rmn.pricing_amount as sql_variant)
														when 6 then cast(rdp.request_amount as sql_variant)
														when 7 then cast(rdp.approve_amount as sql_variant)
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
