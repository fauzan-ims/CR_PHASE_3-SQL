CREATE procedure dbo.xsp_master_collateral_category_lookup
(
	@p_keywords				 nvarchar(50)
	,@p_pagenumber			 int
	,@p_rowspage			 int
	,@p_order_by			 int
	,@p_sort_by				 nvarchar(5)
	,@p_collateral_type_code nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;

	if @p_collateral_type_code = 'ELEC'
	begin
		set @p_collateral_type_code = 'ELCT' ;
	end ;
	else if @p_collateral_type_code = 'FUR'
	begin
		set @p_collateral_type_code = 'FNTR' ;
	end ;

	select	@rows_count = count(1)
	from	master_collateral_category mcc
			inner join dbo.sys_general_subcode sgs on (sgs.code = mcc.collateral_type_code)
	where	mcc.is_active				 = '1'
			and mcc.collateral_type_code = @p_collateral_type_code
			and (category_name like '%' + @p_keywords + '%') ;

	select		mcc.code
				,mcc.category_name
				,@rows_count 'rowcount'
	from		master_collateral_category mcc
				inner join dbo.sys_general_subcode sgs on (sgs.code = mcc.collateral_type_code)
	where		mcc.is_active				 = '1'
				and mcc.collateral_type_code = @p_collateral_type_code
				and (mcc.category_name like '%' + @p_keywords + '%')
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mcc.category_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then mcc.category_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
