CREATE PROCEDURE dbo.xsp_agreement_asset_replacement_history_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	--
	,@p_asset_no		nvarchar(50)
)
as
begin

	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	agreement_asset_replacement_history ast
	where	asset_no = @p_asset_no
	and		(
				ast.new_fixed_asset_code							like '%' + @p_keywords + '%'
				or	new_fixed_asset_name 							like '%' + @p_keywords + '%'
				or	convert(varchar(30), replacement_date, 103)		like '%' + @p_keywords + '%'
				or	replacement_code								like '%' + @p_keywords + '%'
				or	case is_latest
		   					when '1' then 'Yes'
		   					else 'No'
						end											like '%' + @p_keywords + '%'
			) ;

	select	new_fixed_asset_code
		   ,new_fixed_asset_name
		   ,replacement_code
		   ,convert(varchar(30), replacement_date, 103) 'replacement_date'
		   ,case is_latest
		   		when '1' then 'Yes'
		   		else 'No'
			end	'is_latest'					
			,@rows_count 'rowcount'
	from	agreement_asset_replacement_history
	where	asset_no = @p_asset_no
	and		(
				new_fixed_asset_code								like '%' + @p_keywords + '%'
				or	new_fixed_asset_name 							like '%' + @p_keywords + '%'
				or	convert(varchar(30), replacement_date, 103)		like '%' + @p_keywords + '%'
				or	replacement_code								like '%' + @p_keywords + '%'
				or	case is_latest
		   					when '1' then 'Yes'
		   					else 'No'
						end											like '%' + @p_keywords + '%'
			)
	order by	case 
					when @p_sort_by='asc' then case @p_order_by
													when 1 then new_fixed_asset_code
													when 2 then new_fixed_asset_name
													when 3 then replacement_code
													when 4 then cast(replacement_date as sql_variant)
													when 5 then is_latest
												end
					end asc,
				case 
					when @p_sort_by='desc' then case @p_order_by 
													when 1 then new_fixed_asset_code
													when 2 then new_fixed_asset_name
													when 3 then replacement_code
													when 4 then cast(replacement_date as sql_variant)
													when 5 then is_latest
												end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only;
end ;
