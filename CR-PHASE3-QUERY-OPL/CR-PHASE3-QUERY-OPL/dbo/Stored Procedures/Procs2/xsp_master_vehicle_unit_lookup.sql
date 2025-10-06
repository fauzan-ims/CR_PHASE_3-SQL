CREATE procedure dbo.xsp_master_vehicle_unit_lookup
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	,@p_category_code	 nvarchar(50) = ''
	,@p_subcategory_code nvarchar(50) = ''
	,@p_merk_code		 nvarchar(50) = ''
	,@p_model_code		 nvarchar(50) = ''
	,@p_type_code		 nvarchar(50) = ''
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_vehicle_unit mvu
			inner join dbo.master_vehicle_category mvc on (mvc.code	   = mvu.vehicle_category_code)
			inner join dbo.master_vehicle_subcategory mvs on (mvs.code = mvu.vehicle_subcategory_code)
			inner join dbo.master_vehicle_merk mvm on (mvm.code		   = mvu.vehicle_merk_code)
			inner join dbo.master_vehicle_model mvmo on (mvmo.code	   = mvu.vehicle_model_code)
			inner join dbo.master_vehicle_type mvt on (mvt.code		   = mvu.vehicle_type_code)
	where	mvu.vehicle_category_code		 = case @p_category_code
												   when '' then mvu.vehicle_category_code
												   else @p_category_code
											   end
			and mvu.vehicle_subcategory_code = case @p_subcategory_code
												   when '' then mvu.vehicle_subcategory_code
												   else @p_subcategory_code
											   end
			and mvu.vehicle_merk_code		 = case @p_merk_code
												   when '' then mvu.vehicle_merk_code
												   else @p_merk_code
											   end
			and mvu.vehicle_model_code		 = case @p_model_code
												   when '' then mvu.vehicle_model_code
												   else @p_model_code
											   end
			and mvu.vehicle_type_code		 = case @p_type_code
												   when '' then mvu.vehicle_type_code
												   else @p_type_code
											   end
			and mvu.is_active				 = '1'
			and (
					mvu.code like '%' + @p_keywords + '%'
					or	mvu.description like '%' + @p_keywords + '%'
				) ;

	select		mvu.code
				,mvu.description
				,mvu.vehicle_category_code 'category_code'
				,mvu.vehicle_subcategory_code 'subcategory_code'
				,mvu.vehicle_merk_code 'merk_code'
				,mvu.vehicle_model_code 'model_code'
				,mvu.vehicle_type_code 'type_code'
				,mvc.description 'category_desc'
				,mvs.description 'subcategory_desc'
				,mvm.description 'merk_desc'
				,mvmo.description 'model_desc'
				,mvt.description 'type_desc'
				,@rows_count 'rowcount'
	from		master_vehicle_unit mvu
				inner join dbo.master_vehicle_category mvc on (mvc.code	   = mvu.vehicle_category_code)
				inner join dbo.master_vehicle_subcategory mvs on (mvs.code = mvu.vehicle_subcategory_code)
				inner join dbo.master_vehicle_merk mvm on (mvm.code		   = mvu.vehicle_merk_code)
				inner join dbo.master_vehicle_model mvmo on (mvmo.code	   = mvu.vehicle_model_code)
				inner join dbo.master_vehicle_type mvt on (mvt.code		   = mvu.vehicle_type_code)
	where		mvu.vehicle_category_code		 = case @p_category_code
													   when '' then mvu.vehicle_category_code
													   else @p_category_code
												   end
				and mvu.vehicle_subcategory_code = case @p_subcategory_code
													   when '' then mvu.vehicle_subcategory_code
													   else @p_subcategory_code
												   end
				and mvu.vehicle_merk_code		 = case @p_merk_code
													   when '' then mvu.vehicle_merk_code
													   else @p_merk_code
												   end
				and mvu.vehicle_model_code		 = case @p_model_code
													   when '' then mvu.vehicle_model_code
													   else @p_model_code
												   end
				and mvu.vehicle_type_code		 = case @p_type_code
													   when '' then mvu.vehicle_type_code
													   else @p_type_code
												   end
				and mvu.is_active				 = '1'
				and (
						mvu.code like '%' + @p_keywords + '%'
						or	mvu.description like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mvu.code
													 when 2 then mvu.description
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then mvu.code
													   when 2 then mvu.description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
