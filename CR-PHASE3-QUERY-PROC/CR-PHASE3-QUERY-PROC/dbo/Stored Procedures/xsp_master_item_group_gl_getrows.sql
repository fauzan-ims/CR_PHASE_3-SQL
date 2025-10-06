--created by, Rian at 17/02/2023 

CREATE procedure dbo.xsp_master_item_group_gl_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
	,@p_item_group_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_item_group_gl		  mig
			inner join dbo.sys_currency	  sc on sc.code				 = mig.currency_code
												and	 sc.company_code = mig.company_code
			left join dbo.journal_gl_link jgla on jgla.code			 = mig.gl_asset_code
			left join ifinams.dbo.sys_general_subcode sgs on sgs.code		 = mig.gl_asset_code
			left join dbo.journal_gl_link jgle on jgle.code			 = mig.gl_expend_code
			left join dbo.journal_gl_link jgli on jgli.code			 = mig.gl_inprogress_code
	where	item_group_code		 = @p_item_group_code
			and mig.company_code = @p_company_code
			and (
					currency_code							like '%' + @p_keywords + '%'
					or sc.description						like '%' + @p_keywords + '%'
					or mig.category							like '%' + @p_keywords + '%'
					or isnull(jgla.name, sgs.description)	like '%' + @p_keywords + '%'
				) ;

	select		id
				,mig.company_code
				,item_group_code
				,currency_code
				,case mig.category
					when 'FXDAST' then 'Fixed Aset'
					when 'EXPENSE' then 'Expense'
					when 'INVENTORY' then 'Inventory'
					else mig.category
				 end 'category'
				,sc.description	   'currency_name'
				,isnull(jgla.name, sgs.description) 'gl_asset_name'
				,gl_expend_code
				,gl_inprogress_code
				,jgli.name		   'gl_inprogress_name'
				,@rows_count	   'rowcount'
	from		master_item_group_gl		  mig
				inner join dbo.sys_currency	  sc on sc.code				 = mig.currency_code
													and	 sc.company_code = mig.company_code
				left join dbo.journal_gl_link jgla on jgla.code			 = mig.gl_asset_code
				left join ifinams.dbo.sys_general_subcode sgs on sgs.code		 = mig.gl_asset_code
				left join dbo.journal_gl_link jgle on jgle.code			 = mig.gl_expend_code
				left join dbo.journal_gl_link jgli on jgli.code			 = mig.gl_inprogress_code
	where		item_group_code		 = @p_item_group_code
				and mig.company_code = @p_company_code
				and (
						currency_code							like '%' + @p_keywords + '%'
						or sc.description						like '%' + @p_keywords + '%'
						or mig.category							like '%' + @p_keywords + '%'
						or isnull(jgla.name, sgs.description)	like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then currency_code
													 when 2 then mig.category
													 when 3 then isnull(jgla.name, sgs.description)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then currency_code
													   when 2 then mig.category
													   when 3 then isnull(jgla.name, sgs.description)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
