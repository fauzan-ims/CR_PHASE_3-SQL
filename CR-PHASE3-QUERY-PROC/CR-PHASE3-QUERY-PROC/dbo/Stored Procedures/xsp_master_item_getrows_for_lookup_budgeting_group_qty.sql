create PROCEDURE dbo.xsp_master_item_getrows_for_lookup_budgeting_group_qty
(
	@p_keywords						nvarchar(50)
	,@p_pagenumber					int
	,@p_rowspage					int
	,@p_order_by					int
	,@p_sort_by						nvarchar(5)
	,@p_company_code				nvarchar(50)
	,@p_transaction_type			nvarchar(50) = 'ALL'
	--
	,@p_budgeting_group_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_item mi
			left join dbo.master_item_group mig on mig.code	  = mi.item_group_code  and mig.company_code = mi.company_code
			left join dbo.master_merk mm on mm.code			  = mi.merk_code and mm.company_code = mi.company_code
			left join dbo.master_type mt on mt.code			  = mi.type_code  and mt.company_code = mi.company_code
			left join dbo.master_model mmd on mmd.code		  = mi.model_code and mmd.company_code = mi.company_code
			left join dbo.master_uom mu on mu.code			  = mi.uom_code  and mu.company_code = mi.company_code
			left join dbo.sys_general_subcode sgs on sgs.code = mi.type_asset_code  and sgs.company_code = mi.company_code
	where	mi.company_code		= @p_company_code
	and		mi.is_active		= '1'
	and		mi.transaction_type = case @p_transaction_type
											  when 'ALL' then mi.transaction_type
											  else @p_transaction_type
										  end
    and		mi.code not in	(
								select	item_code collate latin1_general_ci_as
								from	efam.dbo.master_budgeting_group_quantity 
								where	budgeting_group_code = @p_budgeting_group_code
							)
	and		(
				mi.code like '%' + @p_keywords + '%'
				or	mi.description like '%' + @p_keywords + '%'
					
			) ;

	select	mi.code
			,mi.description
			,@rows_count 'rowcount'
	from	master_item mi
			left join dbo.master_item_group mig on mig.code	  = mi.item_group_code  and mig.company_code = mi.company_code
			left join dbo.master_merk mm on mm.code			  = mi.merk_code and mm.company_code = mi.company_code
			left join dbo.master_type mt on mt.code			  = mi.type_code  and mt.company_code = mi.company_code
			left join dbo.master_model mmd on mmd.code		  = mi.model_code and mmd.company_code = mi.company_code
			left join dbo.master_uom mu on mu.code			  = mi.uom_code  and mu.company_code = mi.company_code
			left join dbo.sys_general_subcode sgs on sgs.code = mi.type_asset_code  and sgs.company_code = mi.company_code
	where	mi.company_code			= @p_company_code
	and		mi.is_active		= '1'
	and		mi.transaction_type = case @p_transaction_type
											  when 'ALL' then mi.transaction_type
											  else @p_transaction_type
										  end
    and		mi.code not in	(
								select	item_code collate latin1_general_ci_as
								from	efam.dbo.master_budgeting_group_quantity 
								where	budgeting_group_code = @p_budgeting_group_code
							)
	and		(
				mi.code like '%' + @p_keywords + '%'
				or	mi.description like '%' + @p_keywords + '%'
					
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mi.code
													 when 2 then mi.description
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then mi.code
														when 2 then mi.description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
