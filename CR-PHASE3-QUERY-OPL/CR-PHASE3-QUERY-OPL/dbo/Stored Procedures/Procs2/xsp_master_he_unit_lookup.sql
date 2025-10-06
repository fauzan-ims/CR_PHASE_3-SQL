---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE procedure dbo.xsp_master_he_unit_lookup
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
	from	master_he_unit heu
			inner join dbo.master_he_category hec on (hec.code	  = heu.he_category_code)
			inner join dbo.master_he_subcategory hes on (hes.code = heu.he_subcategory_code)
			inner join dbo.master_he_merk hem on (hem.code		  = heu.he_merk_code)
			inner join dbo.master_he_model hemo on (hemo.code	  = heu.he_model_code)
			inner join dbo.master_he_type het on (het.code		  = heu.he_type_code)
	where	heu.he_category_code		= case @p_category_code
											  when '' then heu.he_category_code
											  else @p_category_code
										  end
			and heu.he_subcategory_code = case @p_subcategory_code
											  when '' then heu.he_subcategory_code
											  else @p_subcategory_code
										  end
			and heu.he_merk_code		= case @p_merk_code
											  when '' then heu.he_merk_code
											  else @p_merk_code
										  end
			and heu.he_model_code		= case @p_model_code
											  when '' then heu.he_model_code
											  else @p_model_code
										  end
			and heu.he_type_code		= case @p_type_code
											  when '' then heu.he_type_code
											  else @p_type_code
										  end
			and heu.is_active			= '1'
			and (
					heu.code like '%' + @p_keywords + '%'
					or	heu.description like '%' + @p_keywords + '%'
				) ;

	select		heu.code
				,heu.description
				,heu.he_category_code 'category_code'
				,heu.he_subcategory_code 'subcategory_code'
				,heu.he_merk_code 'merk_code'
				,heu.he_model_code 'model_code'
				,heu.he_type_code 'type_code'
				,hec.description 'category_desc'
				,hes.description 'subcategory_desc'
				,hem.description 'merk_desc'
				,hemo.description 'model_desc'
				,het.description 'type_desc'
				,@rows_count 'rowcount'
	from		master_he_unit heu
				inner join dbo.master_he_category hec on (hec.code	  = heu.he_category_code)
				inner join dbo.master_he_subcategory hes on (hes.code = heu.he_subcategory_code)
				inner join dbo.master_he_merk hem on (hem.code		  = heu.he_merk_code)
				inner join dbo.master_he_model hemo on (hemo.code	  = heu.he_model_code)
				inner join dbo.master_he_type het on (het.code		  = heu.he_type_code)
	where		heu.he_category_code		= case @p_category_code
												  when '' then heu.he_category_code
												  else @p_category_code
											  end
				and heu.he_subcategory_code = case @p_subcategory_code
												  when '' then heu.he_subcategory_code
												  else @p_subcategory_code
											  end
				and heu.he_merk_code		= case @p_merk_code
												  when '' then heu.he_merk_code
												  else @p_merk_code
											  end
				and heu.he_model_code		= case @p_model_code
												  when '' then heu.he_model_code
												  else @p_model_code
											  end
				and heu.he_type_code		= case @p_type_code
												  when '' then heu.he_type_code
												  else @p_type_code
											  end
				and heu.is_active			= '1'
				and (
						heu.code like '%' + @p_keywords + '%'
						or	heu.description like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then heu.code
													 when 2 then heu.description
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then heu.code
													   when 2 then heu.description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
