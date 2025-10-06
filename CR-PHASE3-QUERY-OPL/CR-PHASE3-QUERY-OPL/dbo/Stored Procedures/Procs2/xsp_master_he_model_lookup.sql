CREATE procedure dbo.xsp_master_he_model_lookup
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	,@p_subcategory_code nvarchar(50)
	,@p_merk_code		 nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_he_model
	where	is_active				= '1'
			and he_subcategory_code = case @p_subcategory_code
										  when '' then he_subcategory_code
										  else @p_subcategory_code
									  end
			and he_merk_code		= case @p_merk_code
										  when '' then he_merk_code
										  else @p_merk_code
									  end
			and (
					code like '%' + @p_keywords + '%'
					or	description like '%' + @p_keywords + '%'
				) ;

	select		code
				,description
				,@rows_count 'rowcount'
	from		master_he_model
	where		is_active				= '1'
				and he_subcategory_code = case @p_subcategory_code
											  when '' then he_subcategory_code
											  else @p_subcategory_code
										  end
				and he_merk_code		= case @p_merk_code
											  when '' then he_merk_code
											  else @p_merk_code
										  end
				and (
						code like '%' + @p_keywords + '%'
						or	description like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then description
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
