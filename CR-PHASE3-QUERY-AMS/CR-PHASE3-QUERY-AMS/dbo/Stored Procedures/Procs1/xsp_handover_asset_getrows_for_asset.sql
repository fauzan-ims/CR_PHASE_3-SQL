create PROCEDURE dbo.xsp_handover_asset_getrows_for_asset
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_asset_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	handover_asset has
	inner join dbo.asset ass on (has.fa_code = ass.code)
	where	has.fa_code = @p_asset_code
	and		has.status = 'POST'
	and		(
				has.code											 like '%' + @p_keywords + '%'
				or	has.branch_name									 like '%' + @p_keywords + '%'
				or	has.status										 like '%' + @p_keywords + '%'
				or	convert(varchar(30),transaction_date,103)		 like '%' + @p_keywords + '%'
				or	type											 like '%' + @p_keywords + '%'
				or	remark											 like '%' + @p_keywords + '%'
			) ;

	select		has.code
				,has.branch_code
				,has.branch_name
				,has.status
				,convert(varchar(30),transaction_date,103) 'transaction_date'
				,handover_date
				,type
				,remark
				,fa_code
				,handover_from
				,handover_to
				,unit_condition
				,reff_code
				,reff_name
				,ass.item_code	'asset_no'
				,ass.item_name	'asset_name'
				,@rows_count 'rowcount'
	from		handover_asset has
	inner join dbo.asset ass on (has.fa_code = ass.code)
	where		has.fa_code = @p_asset_code
	and		has.status = 'POST'
	and		(
					has.code											 like '%' + @p_keywords + '%'
					or	has.branch_name									 like '%' + @p_keywords + '%'
					or	has.status										 like '%' + @p_keywords + '%'
					or	convert(varchar(30),transaction_date,103)		 like '%' + @p_keywords + '%'
					or	type											 like '%' + @p_keywords + '%'
					or	remark											 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then has.code
													 when 2 then has.branch_name
													 when 3 then has.type
													 when 4 then cast(transaction_date as sql_variant)
													 when 5 then ass.item_name
													 when 6 then has.remark
													 when 7 then has.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then has.code
													 when 2 then has.branch_name
													 when 3 then has.type
													 when 4 then cast(transaction_date as sql_variant)
													 when 5 then ass.item_name
													 when 6 then has.remark
													 when 7 then has.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
