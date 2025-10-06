--created by, Rian at 04/05/2023 

CREATE procedure xsp_due_date_change_detail_getrows_for_lookup
(
	@p_keywords				 nvarchar(50)
	,@p_pagenumber			 int
	,@p_rowspage			 int
	,@p_order_by			 int
	,@p_sort_by				 nvarchar(5)
	--
	,@p_due_date_change_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.due_date_change_detail dcd
			inner join dbo.agreement_asset aa on (aa.asset_no = dcd.asset_no)
	where	dcd.due_date_change_code = @p_due_date_change_code
			and	dcd.is_change = '1'
			and (
					dcd.id				like '%' + @p_keywords + '%'
					or	dcd.asset_no	like '%' + @p_keywords + '%'
					or	aa.asset_name	like '%' + @p_keywords + '%'
				) ;

	select		dcd.id
				,dcd.asset_no
				,aa.asset_name
				,@rows_count 'rowcount'
	from		dbo.due_date_change_detail dcd
				inner join dbo.agreement_asset aa on (aa.asset_no = dcd.asset_no)
	where		dcd.due_date_change_code = @p_due_date_change_code
				and	dcd.is_change = '1'
				and (
						dcd.id				like '%' + @p_keywords + '%'
						or	dcd.asset_no	like '%' + @p_keywords + '%'
						or	aa.asset_name	like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then dcd.asset_no
													 when 2 then aa.asset_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then dcd.asset_no
													   when 2 then aa.asset_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
