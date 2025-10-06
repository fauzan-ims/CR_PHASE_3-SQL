CREATE procedure dbo.xsp_inventory_card_getrows
(
	 @p_keywords		nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
	,@p_warehouse_code	nvarchar(50)
	,@p_branch_code		nvarchar(50)
)
as
begin
	declare 	@rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select 	@rows_count = count(1)
	from	inventory_card ic
			inner join dbo.master_warehouse mw on mw.code = ic.warehouse_code
	where	ic.company_code	   = @p_company_code
	and		ic.warehouse_code  = case @p_warehouse_code
								when 'ALL' then ic.warehouse_code
								else @p_warehouse_code
							end
	and		ic.branch_code = case @p_branch_code
								when 'ALL' then ic.branch_code
								else @p_branch_code
							end
	and		(
				ic.transaction_code			like 	'%'+@p_keywords+'%'
				or	ic.item_name				like 	'%'+@p_keywords+'%'
				or	ic.branch_name				like 	'%'+@p_keywords+'%'
				or	mw.description				like 	'%'+@p_keywords+'%'
				or	ic.on_hand_quantity			like 	'%'+@p_keywords+'%'
			)
	group by ic.transaction_code,ic.item_code, ic.item_name,ic.branch_name, mw.description, ic.on_hand_quantity;


	select	ic.item_code
			,ic.item_name
			,ic.branch_name
			,mw.description 'warehouse_name'
			,ic.on_hand_quantity
			,ic.transaction_code
			,@rows_count	 'rowcount'
	from	inventory_card ic
			inner join dbo.master_warehouse mw on mw.code = ic.warehouse_code
	where	ic.company_code	   = @p_company_code
	and		ic.warehouse_code	= case @p_warehouse_code
									when 'ALL' then ic.warehouse_code
									else @p_warehouse_code
								end
	and		ic.branch_code = case @p_branch_code
									when 'ALL' then ic.branch_code
									else @p_branch_code
								end
	and		(
				ic.transaction_code			like 	'%'+@p_keywords+'%'
				or	ic.item_name				like 	'%'+@p_keywords+'%'
				or	ic.branch_name				like 	'%'+@p_keywords+'%'
				or	mw.description				like 	'%'+@p_keywords+'%'
				or	ic.on_hand_quantity			like 	'%'+@p_keywords+'%'
			)
	group by ic.transaction_code,ic.item_code, ic.item_name,ic.branch_name, mw.description, ic.on_hand_quantity
	order by	case
				when @p_sort_by = 'asc' then case @p_order_by
												when 1	then ic.transaction_code
												when 2	then ic.item_name
												when 3	then ic.branch_name
												when 4	then mw.description
												when 5	then cast(ic.on_hand_quantity as sql_variant)
											end
			end asc
			,case
				when @p_sort_by = 'desc' then case @p_order_by
												when 1	then ic.transaction_code
												when 2	then ic.item_name
												when 3	then ic.branch_name
												when 4	then mw.description
												when 5	then cast(ic.on_hand_quantity as sql_variant)
											end
			end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
