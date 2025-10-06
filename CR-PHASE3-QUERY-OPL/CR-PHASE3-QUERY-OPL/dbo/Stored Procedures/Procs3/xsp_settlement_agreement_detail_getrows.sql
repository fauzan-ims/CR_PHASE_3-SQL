CREATE PROCEDURE dbo.xsp_settlement_agreement_detail_getrows
(
	@p_keywords	    nvarchar(50)
	,@p_pagenumber  int
	,@p_rowspage    int
	,@p_order_by    int
	,@p_sort_by	    nvarchar(5)
	,@p_settlement_id bigint 
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	settlement_agreement_detail sad
			inner join dbo.agreement_asset aa on (aa.asset_no = sad.asset_no)
	where	sad.settlement_id = @p_settlement_id
			and (
					sad.asset_no										  like '%' + @p_keywords + '%'
					or	aa.asset_name									  like '%' + @p_keywords + '%'
					or	sad.confirmation_result							  like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), sad.confirmation_date, 103) like '%' + @p_keywords + '%'
					or	sad.confirmation_remark							  like '%' + @p_keywords + '%'
					or	sad.additional_periode							  like '%' + @p_keywords + '%'
				) ;

	select		id
				,sad.asset_no										 
				,aa.asset_name									 
				,sad.confirmation_result							 
				,convert(nvarchar(15), sad.confirmation_date, 103) 'confirmation_date'
				,sad.confirmation_remark		
				,sad.additional_periode					 
				,@rows_count 'rowcount'
	from		settlement_agreement_detail sad
				inner join dbo.agreement_asset aa on (aa.asset_no = sad.asset_no)
	where		sad.settlement_id = @p_settlement_id
				and (
						sad.asset_no										  like '%' + @p_keywords + '%'
						or	aa.asset_name									  like '%' + @p_keywords + '%'
						or	sad.confirmation_result							  like '%' + @p_keywords + '%'
						or	convert(nvarchar(15), sad.confirmation_date, 103) like '%' + @p_keywords + '%'
						or	sad.confirmation_remark							  like '%' + @p_keywords + '%'
						or	sad.additional_periode							  like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then sad.asset_no + aa.asset_name
													 when 2 then sad.confirmation_result
													 when 3 then convert(nvarchar(15), sad.confirmation_date, 103)
													 when 4 then sad.confirmation_remark 
													 when 5 then cast(sad.additional_periode as sql_variant) 
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then sad.asset_no + aa.asset_name
													 when 2 then sad.confirmation_result
													 when 3 then convert(nvarchar(15), sad.confirmation_date, 103)
													 when 4 then sad.confirmation_remark 
													 when 5 then cast(sad.additional_periode as sql_variant) 
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
