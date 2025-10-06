---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_vehicle_pricelist_upload_getrows
(
	@p_keywords		    nvarchar(50)
	,@p_pagenumber	    int
	,@p_rowspage	    int
	,@p_order_by	    int
	,@p_sort_by		    nvarchar(5)
	,@p_upload_result	nvarchar(4000)
	,@p_branch_code		nvarchar(50)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	master_vehicle_pricelist_upload
	where	upload_result = @p_upload_result
			and branch_code	= case @p_branch_code
									when 'ALL' then branch_code
									else @p_branch_code
								  end
			and (
				upload_by										like 	'%'+@p_keywords+'%'
				or	asset_year									like 	'%'+@p_keywords+'%'
				or	condition									like 	'%'+@p_keywords+'%'
				or	description									like 	'%'+@p_keywords+'%'
				or	branch_name									like 	'%'+@p_keywords+'%'
				or	convert(varchar(30), effective_date, 103)	like 	'%'+@p_keywords+'%'
				or	asset_value									like 	'%'+@p_keywords+'%'
				or	dp_amount									like 	'%'+@p_keywords+'%'
				or	financing_amount							like 	'%'+@p_keywords+'%'
				or	upload_id									like 	'%'+@p_keywords+'%'
				or	upload_result								like 	'%'+@p_keywords+'%'
			);

		select	upload_by
				,asset_year
				,condition
				,description
				,branch_name
				,currency_code
				,convert(varchar(30), effective_date, 103) 'effective_date'
				,asset_value
				,dp_amount
				,financing_amount
				,upload_id
				,upload_result
				,@rows_count	 'rowcount'
		from	master_vehicle_pricelist_upload
		where	upload_result = @p_upload_result
				and branch_code	= case @p_branch_code
										when 'ALL' then branch_code
										else @p_branch_code
									  end
				and (
					upload_by										like 	'%'+@p_keywords+'%'
					or	asset_year									like 	'%'+@p_keywords+'%'
					or	condition									like 	'%'+@p_keywords+'%'
					or	description									like 	'%'+@p_keywords+'%'
					or	branch_name									like 	'%'+@p_keywords+'%'
					or	convert(varchar(30), effective_date, 103)	like 	'%'+@p_keywords+'%'
					or	asset_value									like 	'%'+@p_keywords+'%'
					or	dp_amount									like 	'%'+@p_keywords+'%'
					or	financing_amount							like 	'%'+@p_keywords+'%'
					or	upload_id									like 	'%'+@p_keywords+'%'
					or	upload_result								like 	'%'+@p_keywords+'%'
				)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1	then asset_year									
													when 2	then condition									
													when 3	then description									
													when 4	then branch_name									
													when 5	then cast(effective_date as sql_variant)	
													when 6	then cast(asset_value as sql_variant)									
													when 7	then cast(dp_amount as sql_variant)									
													when 8	then cast(financing_amount as sql_variant)								
													when 9	then upload_id									
													when 10	then upload_result
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1	then asset_year									
														when 2	then condition									
														when 3	then description									
														when 4	then branch_name									
														when 5	then cast(effective_date as sql_variant)	
														when 6	then cast(asset_value as sql_variant)									
														when 7	then cast(dp_amount as sql_variant)									
														when 8	then cast(financing_amount as sql_variant)								
														when 9	then upload_id									
														when 10	then upload_result
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end


