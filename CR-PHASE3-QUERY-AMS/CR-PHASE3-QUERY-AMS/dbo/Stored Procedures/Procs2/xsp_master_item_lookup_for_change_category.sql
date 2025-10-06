--created by, Rian at 17/02/2023 

CREATE PROCEDURE dbo.xsp_master_item_lookup_for_change_category
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	,@p_company_code	 nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_item mi
	inner join dbo.master_category mc on (mc.code = mi.fa_category_code)
	where	mi.company_code			= @p_company_code
			and mi.is_active		= '1'
			and mi.transaction_type = 'FXDAST'
			and (
					mi.code					 like '%' + @p_keywords + '%'
					or	mi.description		 like '%' + @p_keywords + '%'
					or	mi.transaction_type	 like '%' + @p_keywords + '%'
				) ;

	select		mi.code
				,mi.company_code
				,mi.description
				,mi.transaction_type
				,mi.item_group_code
				,mi.merk_code
				,mi.type_code
				,mi.model_code
				,mi.uom_code
				,mi.fa_category_code
				,mi.po_latest_price
				,mi.po_average_price
				,mi.fa_category_code
				,mc.depre_cat_commercial_code
				,mc.depre_cat_commercial_name
				,mc.depre_cat_fiscal_code
				,mc.depre_cat_fiscal_name
				,mc.description 'fa_category_name'
				,case mi.is_rent
					 when '1' then 'YES'
					 else 'NO'
				 end 'is_rent'
				,case mi.is_active
					 when '1' then 'ACTIVE'
					 else 'INACTIVE'
				 end 'is_active'
				,@rows_count 'rowcount'
	from		master_item mi
				inner join dbo.master_category mc on (mc.code = mi.fa_category_code)
	where		mi.company_code			= @p_company_code
				and mi.is_active		= '1'
				and mi.transaction_type = 'FXDAST'
				and (
						mi.code					 like '%' + @p_keywords + '%'
						or	mi.description		 like '%' + @p_keywords + '%'
						or	mi.transaction_type	 like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mi.code
													 when 2 then mi.transaction_type
													 when 3 then mi.description
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then mi.code
													 when 2 then mi.transaction_type
													 when 3 then mi.description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
