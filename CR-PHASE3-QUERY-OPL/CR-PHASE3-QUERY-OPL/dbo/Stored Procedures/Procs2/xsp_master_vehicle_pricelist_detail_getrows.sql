---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_vehicle_pricelist_detail_getrows
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_vehicle_pricelist_code  nvarchar(50)
	,@p_branch_code				nvarchar(50)
)
as
begin
	declare 	@rows_count int = 0 ;

	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	END
    
	select 	@rows_count = count(1)
	from	master_vehicle_pricelist_detail
	where	vehicle_pricelist_code	= case @p_vehicle_pricelist_code
											when 'ALL' then vehicle_pricelist_code
											else @p_vehicle_pricelist_code
									  end
            AND branch_code			= case @p_branch_code
										    when 'ALL' then branch_code
										    else @p_branch_code
								  end
			and (
				id													like 	'%'+@p_keywords+'%'
				or	convert(varchar(30), effective_date, 103) 		like 	'%'+@p_keywords+'%'
				or	asset_value										like 	'%'+@p_keywords+'%'
				or	dp_pct											like 	'%'+@p_keywords+'%'
				or	dp_amount										like 	'%'+@p_keywords+'%'
				or	financing_amount								like 	'%'+@p_keywords+'%'
			);

		select	id
				,convert(varchar(30), effective_date, 103) 'effective_date'
				,asset_value		
				,dp_pct			
				,dp_amount		
				,financing_amount
				,@rows_count	 'rowcount'
		from	master_vehicle_pricelist_detail
		where	vehicle_pricelist_code	= case @p_vehicle_pricelist_code
											when 'ALL' then vehicle_pricelist_code
											else @p_vehicle_pricelist_code
			    						  end
                and branch_code			= case @p_branch_code
										    when 'ALL' then branch_code
										    else @p_branch_code
								  end
			    and (
			    	id													like 	'%'+@p_keywords+'%'
			    	or	convert(varchar(30), effective_date, 103) 		like 	'%'+@p_keywords+'%'
			    	or	asset_value										like 	'%'+@p_keywords+'%'
			    	or	dp_pct											like 	'%'+@p_keywords+'%'
			    	or	dp_amount										like 	'%'+@p_keywords+'%'
			    	or	financing_amount								like 	'%'+@p_keywords+'%'
			    )

	Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1	then cast(effective_date as sql_variant)	 			
													when 2	then cast(asset_value as sql_variant)		
													when 3	then cast(dp_pct as sql_variant)			
													when 4	then cast(dp_amount as sql_variant)		
													when 5	then cast(financing_amount as sql_variant)
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1	then cast(effective_date as sql_variant)	 			
														when 2	then cast(asset_value as sql_variant)		
														when 3	then cast(dp_pct as sql_variant)			
														when 4	then cast(dp_amount as sql_variant)		
														when 5	then cast(financing_amount as sql_variant)
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end


