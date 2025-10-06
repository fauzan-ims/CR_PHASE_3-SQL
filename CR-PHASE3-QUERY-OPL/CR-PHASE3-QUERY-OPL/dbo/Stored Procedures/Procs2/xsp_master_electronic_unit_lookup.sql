---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE procedure dbo.xsp_master_electronic_unit_lookup
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
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_electronic_unit elu
			inner join dbo.master_electronic_category elc on (elc.code	  = elu.electronic_category_code)
			inner join dbo.master_electronic_subcategory els on (els.code = elu.electronic_subcategory_code)
			inner join dbo.master_electronic_merk elm on (elm.code		  = elu.electronic_merk_code)
			inner join dbo.master_electronic_model elmo on (elmo.code	  = elu.electronic_model_code)
	where	elu.electronic_category_code		= case @p_category_code
													  when '' then elu.electronic_category_code
													  else @p_category_code
												  end
			and elu.electronic_subcategory_code = case @p_subcategory_code
													  when '' then elu.electronic_subcategory_code
													  else @p_subcategory_code
												  end
			and elu.electronic_merk_code		= case @p_merk_code
													  when '' then elu.electronic_merk_code
													  else @p_merk_code
												  end
			and elu.electronic_model_code		= case @p_model_code
													  when '' then elu.electronic_model_code
													  else @p_model_code
												  end
			and elu.is_active					= '1'
			and (
					elu.code like '%' + @p_keywords + '%'
					or	elu.description like '%' + @p_keywords + '%'
				) ;

	select		elu.code
				,elu.description
				,elu.electronic_category_code 'category_code'
				,elu.electronic_subcategory_code 'subcategory_code'
				,elu.electronic_merk_code 'merk_code'
				,elu.electronic_model_code 'model_code'
				,elc.description 'category_desc'
				,els.description 'subcategory_desc'
				,elm.description 'merk_desc'
				,elmo.description 'model_desc'
				,@rows_count 'rowcount'
	from		master_electronic_unit elu
				inner join dbo.master_electronic_category elc on (elc.code	  = elu.electronic_category_code)
				inner join dbo.master_electronic_subcategory els on (els.code = elu.electronic_subcategory_code)
				inner join dbo.master_electronic_merk elm on (elm.code		  = elu.electronic_merk_code)
				inner join dbo.master_electronic_model elmo on (elmo.code	  = elu.electronic_model_code)
	where		elu.electronic_category_code		= case @p_category_code
														  when '' then elu.electronic_category_code
														  else @p_category_code
													  end
				and elu.electronic_subcategory_code = case @p_subcategory_code
														  when '' then elu.electronic_subcategory_code
														  else @p_subcategory_code
													  end
				and elu.electronic_merk_code		= case @p_merk_code
														  when '' then elu.electronic_merk_code
														  else @p_merk_code
													  end
				and elu.electronic_model_code		= case @p_model_code
														  when '' then elu.electronic_model_code
														  else @p_model_code
													  end
				and elu.is_active					= '1'
				and (
						elu.code like '%' + @p_keywords + '%'
						or	elu.description like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then elu.code
													 when 2 then elu.description
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then elu.code
													   when 2 then elu.description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
