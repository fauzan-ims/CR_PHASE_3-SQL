CREATE PROCEDURE [dbo].[xsp_asset_location_history_getrows]
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
	from	dbo.ASSET_LOCATION_HISTORY
	where	asset_code = @p_asset_code
	and		(
				id												LIKE '%' + @p_keywords + '%'
				or asset_code									LIKE '%' + @p_keywords + '%'
				or convert(nvarchar(30), transaction_date, 103) LIKE '%' + @p_keywords + '%'
				or convert(nvarchar(30), value_date, 103) 		LIKE '%' + @p_keywords + '%'
				or parking_location								LIKE '%' + @p_keywords + '%'
				or remark										LIKE '%' + @p_keywords + '%'
				or update_by									LIKE '%' + @p_keywords + '%'
			) ;

	select		id
				,asset_code
				,convert(nvarchar(30), transaction_date, 103) 'transaction_date'
				,convert(nvarchar(30), value_date, 103) 'value_date'
				,parking_location
				,remark
				,update_by
				,@rows_count 'rowcount'
	from		dbo.ASSET_LOCATION_HISTORY
	where		asset_code = @p_asset_code
	and			(
				id												LIKE '%' + @p_keywords + '%'
				or asset_code									LIKE '%' + @p_keywords + '%'
				or convert(nvarchar(30), transaction_date, 103) LIKE '%' + @p_keywords + '%'
				or convert(nvarchar(30), value_date, 103) 		LIKE '%' + @p_keywords + '%'
				or parking_location								LIKE '%' + @p_keywords + '%'
				or remark										LIKE '%' + @p_keywords + '%'
				or update_by									LIKE '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then cast(transaction_date as sql_variant)
													 when 2 then cast(value_date as sql_variant)
													 when 3 then parking_location
													 when 4 then remark
													 when 5 then update_by
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													when 1 then cast(transaction_date as sql_variant)
													when 2 then cast(value_date as sql_variant)
													when 3 then parking_location
													when 4 then remark
													when 5 then update_by
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
