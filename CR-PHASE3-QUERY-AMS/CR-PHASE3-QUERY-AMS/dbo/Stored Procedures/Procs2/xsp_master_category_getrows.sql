--created by, Rian at 17/02/2023 

CREATE procedure dbo.xsp_master_category_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_category mc
			left join dbo.sys_general_subcode sgs on (sgs.code = mc.asset_type_code) and (sgs.company_code = mc.company_code)
	where	mc.company_code = @p_company_code
	and		(
				mc.code							 like '%' + @p_keywords + '%'
				or	mc.description				 like '%' + @p_keywords + '%'
				or	mc.asset_type_code			 like '%' + @p_keywords + '%'
				or	sgs.description				 like '%' + @p_keywords + '%'
				or	case mc.is_active
						when '1' then 'Yes'
						else 'No'
					end							 like '%' + @p_keywords + '%'
			) ;

	select		mc.code
				,mc.company_code
				,mc.description
				,mc.asset_type_code
				,sgs.description 'general_subcode_desc'
				,mc.transaction_depre_code
				,mc.transaction_depre_name
				,mc.transaction_accum_depre_code
				,mc.transaction_accum_depre_name
				,mc.transaction_gain_loss_code
				,mc.transaction_gain_loss_name
				,last_depre_date
				,asset_amount_threshold
				,depre_amount_threshold
				,total_net_book_value_amount
				,total_accum_depre_amount
				,total_asset_value
				,case mc.is_active
					when '1' then 'Yes'
					else 'No'
				 end 'is_active'
				,@rows_count 'rowcount'
	from		master_category mc
				left join dbo.sys_general_subcode sgs on (sgs.code = mc.asset_type_code and sgs.company_code = mc.company_code)
	where		mc.company_code = @p_company_code
	and			(
					mc.code							 like '%' + @p_keywords + '%'
					or	mc.description				 like '%' + @p_keywords + '%'
					or	mc.asset_type_code			 like '%' + @p_keywords + '%'
					or	sgs.description				 like '%' + @p_keywords + '%'
					or	case mc.is_active
							when '1' then 'Yes'
							else 'No'
						end							 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mc.code
													when 2 then sgs.description
													when 3 then mc.description
													when 4 then mc.is_active
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then mc.code
													 when 2 then sgs.description
													 when 3 then mc.description
													 when 4 then mc.is_active
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
