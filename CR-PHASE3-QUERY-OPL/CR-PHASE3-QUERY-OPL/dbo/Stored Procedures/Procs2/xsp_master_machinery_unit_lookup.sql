---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE procedure dbo.xsp_master_machinery_unit_lookup
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
	from	master_machinery_unit mmu
			inner join dbo.master_machinery_category mmc on (mmc.code	 = mmu.machinery_category_code)
			inner join dbo.master_machinery_subcategory mms on (mms.code = mmu.machinery_subcategory_code)
			inner join dbo.master_machinery_merk mmm on (mmm.code		 = mmu.machinery_merk_code)
			inner join dbo.master_machinery_model mmmo on (mmmo.code	 = mmu.machinery_model_code)
			inner join dbo.master_machinery_type mmt on (mmt.code		 = mmu.machinery_type_code)
	where	mmu.machinery_category_code		   = case @p_category_code
													 when '' then mmu.machinery_category_code
													 else @p_category_code
												 end
			and mmu.machinery_subcategory_code = case @p_subcategory_code
													 when '' then mmu.machinery_subcategory_code
													 else @p_subcategory_code
												 end
			and mmu.machinery_merk_code		   = case @p_merk_code
													 when '' then mmu.machinery_merk_code
													 else @p_merk_code
												 end
			and mmu.machinery_model_code	   = case @p_model_code
													 when '' then mmu.machinery_model_code
													 else @p_model_code
												 end
			and mmu.machinery_type_code		   = case @p_type_code
													 when '' then mmu.machinery_type_code
													 else @p_type_code
												 end
			and mmu.is_active				   = '1'
			and (
					mmu.code like '%' + @p_keywords + '%'
					or	mmu.description like '%' + @p_keywords + '%'
				) ;

	select		mmu.code
				,mmu.description
				,mmu.machinery_category_code 'category_code'
				,mmu.machinery_subcategory_code 'subcategory_code'
				,mmu.machinery_merk_code 'merk_code'
				,mmu.machinery_model_code 'model_code'
				,mmu.machinery_type_code 'type_code'
				,mmc.description 'category_desc'
				,mms.description 'subcategory_desc'
				,mmm.description 'merk_desc'
				,mmmo.description 'model_desc'
				,mmt.description 'type_desc'
				,@rows_count 'rowcount'
	from		master_machinery_unit mmu
				inner join dbo.master_machinery_category mmc on (mmc.code	 = mmu.machinery_category_code)
				inner join dbo.master_machinery_subcategory mms on (mms.code = mmu.machinery_subcategory_code)
				inner join dbo.master_machinery_merk mmm on (mmm.code		 = mmu.machinery_merk_code)
				inner join dbo.master_machinery_model mmmo on (mmmo.code	 = mmu.machinery_model_code)
				inner join dbo.master_machinery_type mmt on (mmt.code		 = mmu.machinery_type_code)
	where		mmu.machinery_category_code		   = case @p_category_code
														 when '' then mmu.machinery_category_code
														 else @p_category_code
													 end
				and mmu.machinery_subcategory_code = case @p_subcategory_code
														 when '' then mmu.machinery_subcategory_code
														 else @p_subcategory_code
													 end
				and mmu.machinery_merk_code		   = case @p_merk_code
														 when '' then mmu.machinery_merk_code
														 else @p_merk_code
													 end
				and mmu.machinery_model_code	   = case @p_model_code
														 when '' then mmu.machinery_model_code
														 else @p_model_code
													 end
				and mmu.machinery_type_code		   = case @p_type_code
														 when '' then mmu.machinery_type_code
														 else @p_type_code
													 end
				and mmu.is_active				   = '1'
				and (
						mmu.code like '%' + @p_keywords + '%'
						or	mmu.description like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mmu.code
													 when 2 then mmu.description
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then mmu.code
													   when 2 then mmu.description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
