CREATE PROCEDURE [dbo].[xsp_sppa_detail_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_sppa_code  nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sppa_detail sd
			inner join dbo.sppa_request sr on (sr.code = sd.sppa_request_code)
			inner join dbo.insurance_register ir on (ir.code = sr.register_code)
			inner join asset ass on (ass.code = sd.fa_code)
			inner join dbo.asset_vehicle asv on (asv.asset_code = ass.code)
	where	sd.sppa_code = @p_sppa_code
			and (
					sd.from_year					like '%' + @p_keywords + '%'
					or	sd.to_year					like '%' + @p_keywords + '%'
					or	result_status				like '%' + @p_keywords + '%'
					or	sd.fa_code					like '%' + @p_keywords + '%'
					or	ass.item_name				like '%' + @p_keywords + '%'
					or	sd.sum_insured_amount		like '%' + @p_keywords + '%'
					or	sd.result_total_buy_amount	like '%' + @p_keywords + '%'
					or	sd.result_policy_no			like '%' + @p_keywords + '%'
					or	sd.accessories				like '%' + @p_keywords + '%'
				) ;

	select		sd.id
				,sd.insured_name
				,sd.from_year
				,sd.to_year
				,result_status
				,sd.fa_code
				,item_name 'fa_name'
				,asv.colour
				,asv.plat_no
				,sd.sum_insured_amount
				,sd.result_total_buy_amount
				,sd.result_policy_no
				,sd.accessories
				,@rows_count 'rowcount'
	from		sppa_detail sd
				inner join dbo.sppa_request sr on (sr.code = sd.sppa_request_code)
				inner join dbo.insurance_register ir on (ir.code = sr.register_code)
				inner join asset ass on (ass.code = sd.fa_code)
				inner join dbo.asset_vehicle asv on (asv.asset_code = ass.code)
	where		sd.sppa_code = @p_sppa_code
				and (
						sd.from_year					like '%' + @p_keywords + '%'
						or	sd.to_year					like '%' + @p_keywords + '%'
						or	result_status				like '%' + @p_keywords + '%'
						or	sd.fa_code					like '%' + @p_keywords + '%'
						or	ass.item_name				like '%' + @p_keywords + '%'
						or	sd.sum_insured_amount		like '%' + @p_keywords + '%'
						or	sd.result_total_buy_amount	like '%' + @p_keywords + '%'
						or	sd.result_policy_no			like '%' + @p_keywords + '%'
						or	sd.accessories				like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then sd.fa_code + ass.item_name
													 when 2 then sd.result_policy_no
													 when 3 then cast(sd.result_total_buy_amount as sql_variant)
													 when 4 then cast(sd.sum_insured_amount as sql_variant)
													 when 5 then cast(sd.from_year as sql_variant)
													 when 6 then cast(sd.to_year as sql_variant)
													 when 7 then result_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then sd.fa_code + ass.item_name
													    when 2 then sd.result_policy_no
													    when 3 then cast(sd.result_total_buy_amount as sql_variant)
													    when 4 then cast(sd.sum_insured_amount as sql_variant)
													    when 5 then cast(sd.from_year as sql_variant)
													    when 6 then cast(sd.to_year as sql_variant)
													    when 7 then result_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
