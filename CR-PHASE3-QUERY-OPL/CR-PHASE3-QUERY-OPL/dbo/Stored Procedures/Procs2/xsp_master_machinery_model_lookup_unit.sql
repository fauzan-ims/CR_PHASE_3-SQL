---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE procedure [dbo].[xsp_master_machinery_model_lookup_unit]
(
	@p_keywords					   nvarchar(50)
	,@p_pagenumber				   int
	,@p_rowspage				   int
	,@p_order_by				   int
	,@p_sort_by					   nvarchar(5)
	,@p_machinery_subcategory_code nvarchar(50)
	,@p_machinery_merk_code		   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_machinery_model
	where	is_active					   = '1'
			and machinery_subcategory_code = case @p_machinery_subcategory_code
												 when 'ALL' then machinery_subcategory_code
												 else @p_machinery_subcategory_code
											 end
			and machinery_merk_code= case @p_machinery_merk_code
												 when 'ALL' then machinery_merk_code
												 else @p_machinery_merk_code
											 end
			and (
					code			like '%' + @p_keywords + '%'
					or	description like '%' + @p_keywords + '%'
				) ;

	if @p_sort_by = 'asc'
	begin
		select		code
					,description
					,@rows_count 'rowcount'
		from		master_machinery_model
		where		is_active					   = '1'
					and machinery_subcategory_code = case @p_machinery_subcategory_code
														 when 'ALL' then machinery_subcategory_code
														 else @p_machinery_subcategory_code
													 end
					and machinery_merk_code= case @p_machinery_merk_code
												 when 'ALL' then machinery_merk_code
												 else @p_machinery_merk_code
											 end
					and (
							code			like '%' + @p_keywords + '%'
							or	description like '%' + @p_keywords + '%'
						)
		order by	case @p_order_by
						when 1 then code
						when 2 then description
					end asc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
	else
	begin
		select		code
					,description
					,@rows_count 'rowcount'
		from		master_machinery_model
		where		is_active					   = '1'
					and machinery_subcategory_code = case @p_machinery_subcategory_code
														 when 'ALL' then machinery_subcategory_code
														 else @p_machinery_subcategory_code
													 end
					and machinery_merk_code= case @p_machinery_merk_code
												 when 'ALL' then machinery_merk_code
												 else @p_machinery_merk_code
											 end
					and (
							code			like '%' + @p_keywords + '%'
							or	description like '%' + @p_keywords + '%'
						)
		order by	case @p_order_by
						when 1 then code
						when 2 then description
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
end ;



