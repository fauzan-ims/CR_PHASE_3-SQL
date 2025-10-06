--created by, Rian at 17/02/2023 

CREATE procedure dbo.xsp_master_category_lookup
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
	,@p_asset_type_code	nvarchar(50) = ''
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.master_category mc
	where	mc.is_active = '1'
	and		mc.company_code = @p_company_code
	and		mc.asset_type_code = case @p_asset_type_code
									when '' then mc.asset_type_code
									else @p_asset_type_code
								 end
	and		(
				mc.code					like '%' + @p_keywords + '%'
				or	mc.description		like '%' + @p_keywords + '%' 
			) ;

	select	mc.code
			,mc.description 'description_category'
			,mc.asset_type_code 
			,@rows_count 'rowcount'
	from	dbo.master_category mc
	where	mc.is_active = '1'
	and		mc.company_code = @p_company_code
	and		mc.asset_type_code = case @p_asset_type_code
									when '' then mc.asset_type_code
									else @p_asset_type_code
								 end
	and		(
				mc.code					like '%' + @p_keywords + '%'
			or	mc.description			like '%' + @p_keywords + '%' 
			)
	order by
			case
				when @p_sort_by = 'asc' then case @p_order_by	
													when 1 then mc.code
													when 2 then mc.description
				 								end
			end asc
			,case
				when @p_sort_by = 'desc' then case @p_order_by				
													when 1 then mc.code
													when 2 then mc.description
				 								end
			end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end ;
