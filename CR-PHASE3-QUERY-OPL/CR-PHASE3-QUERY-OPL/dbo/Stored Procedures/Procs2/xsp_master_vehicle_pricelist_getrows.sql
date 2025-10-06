---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_vehicle_pricelist_getrows
(
	@p_keywords					 nvarchar(50)
	,@p_pagenumber				 int
	,@p_rowspage				 int
	,@p_order_by				 int
	,@p_sort_by					 nvarchar(5)
	,@p_vehicle_category_code	 nvarchar(50) = ''
	,@p_vehicle_subcategory_code nvarchar(50) = ''
	,@p_vehicle_merk_code		 nvarchar(50) = ''
	,@p_vehicle_model_code		 nvarchar(50) = ''
	,@p_vehicle_type_code		 nvarchar(50) = ''
	,@p_asset_year				 nvarchar(4)  = ''
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_vehicle_pricelist mvp
			inner join dbo.master_vehicle_unit mvu on (mvu.code = mvp.vehicle_unit_code)
	where	mvp.asset_year					 = case @p_asset_year
												   when '' then mvp.asset_year
												   else @p_asset_year
											   end
			and mvp.vehicle_category_code	 = case @p_vehicle_category_code
												   when '' then mvp.vehicle_category_code
												   else @p_vehicle_category_code
											   end
			and mvp.vehicle_subcategory_code = case @p_vehicle_subcategory_code
												   when '' then mvp.vehicle_subcategory_code
												   else @p_vehicle_subcategory_code
											   end
			and mvp.vehicle_merk_code		 = case @p_vehicle_merk_code
												   when '' then mvp.vehicle_merk_code
												   else @p_vehicle_merk_code
											   end
			and mvp.vehicle_model_code		 = case @p_vehicle_model_code
												   when '' then mvp.vehicle_model_code
												   else @p_vehicle_model_code
											   end
			and mvp.vehicle_type_code		 = case @p_vehicle_type_code
												   when '' then mvp.vehicle_type_code
												   else @p_vehicle_type_code
											   end
			and (
					mvu.description		like '%' + @p_keywords + '%'
					or	mvp.asset_year	like '%' + @p_keywords + '%'
					or	mvp.condition	like '%' + @p_keywords + '%'
				) ;

		select		mvp.code
					,mvp.description
					,mvu.description 'vehicle_unit_desc'
					,mvp.asset_year
					,mvp.condition
					,detail.asset_value 'last_price'
					,@rows_count 'rowcount'
		from		master_vehicle_pricelist mvp
					inner join dbo.master_vehicle_unit mvu on (mvu.code = mvp.vehicle_unit_code)
					outer apply
		(
			select top 1
						asset_value
			from		dbo.master_vehicle_pricelist_detail
			where		mvp.code = vehicle_pricelist_code
			order by	effective_date desc
		) detail
		where		mvp.asset_year					 = case @p_asset_year
														   when '' then mvp.asset_year
														   else @p_asset_year
													   end
					and mvp.vehicle_category_code	 = case @p_vehicle_category_code
														   when '' then mvp.vehicle_category_code
														   else @p_vehicle_category_code
													   end
					and mvp.vehicle_subcategory_code = case @p_vehicle_subcategory_code
														   when '' then mvp.vehicle_subcategory_code
														   else @p_vehicle_subcategory_code
													   end
					and mvp.vehicle_merk_code		 = case @p_vehicle_merk_code
														   when '' then mvp.vehicle_merk_code
														   else @p_vehicle_merk_code
													   end
					and mvp.vehicle_model_code		 = case @p_vehicle_model_code
														   when '' then mvp.vehicle_model_code
														   else @p_vehicle_model_code
													   end
					and mvp.vehicle_type_code		 = case @p_vehicle_type_code
														   when '' then mvp.vehicle_type_code
														   else @p_vehicle_type_code
													   end
					and (
							mvu.description		like '%' + @p_keywords + '%'
							or	mvp.asset_year	like '%' + @p_keywords + '%'
							or	mvp.condition	like '%' + @p_keywords + '%'
						)

	Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mvp.description
													when 2 then mvp.asset_year
													when 3 then mvp.condition
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then mvp.description
														when 2 then mvp.asset_year
														when 3 then mvp.condition
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

