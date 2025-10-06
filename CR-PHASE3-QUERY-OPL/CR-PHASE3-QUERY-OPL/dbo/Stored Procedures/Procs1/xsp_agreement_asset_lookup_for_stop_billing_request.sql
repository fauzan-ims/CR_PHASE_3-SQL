
CREATE PROCEDURE [dbo].[xsp_agreement_asset_lookup_for_stop_billing_request]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	--
	,@p_agreement_no		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.agreement_asset ast
			inner join dbo.agreement_main am on (am.agreement_no = ast.agreement_no)
	where	ast.agreement_no = @p_agreement_no
	and ast.asset_status = 'RENTED' -- Louis Kamis, 03 Juli 2025 15.33.51 -- 
	and		(
				ast.asset_no				like '%' + @p_keywords + '%'
				or	ast.fa_reff_no_01		like '%' + @p_keywords + '%'
				or	ast.fa_reff_no_02		like '%' + @p_keywords + '%'
				or	ast.fa_reff_no_03		like '%' + @p_keywords + '%'
				or	ast.asset_year			like '%' + @p_keywords + '%'
				or	ast.asset_condition		like '%' + @p_keywords + '%'
				or	ast.asset_status		like '%' + @p_keywords + '%'
			) ;

	select		ast.asset_no
				,ast.asset_name
				,ast.fa_reff_no_01 
				,ast.fa_reff_no_02 
				,ast.fa_reff_no_03 
				,ast.asset_year
				,ast.asset_condition
				,ast.lease_rounded_amount
				,ast.asset_status
				,@rows_count 'rowcount'
	from		dbo.agreement_asset ast
				inner join dbo.agreement_main am on (am.agreement_no = ast.agreement_no)
	where		ast.agreement_no = @p_agreement_no
	and ast.asset_status = 'RENTED' -- Louis Kamis, 03 Juli 2025 15.33.51 -- 
	and			(	 
					ast.asset_no				like '%' + @p_keywords + '%'
					or	ast.fa_reff_no_01		like '%' + @p_keywords + '%'
					or	ast.fa_reff_no_02		like '%' + @p_keywords + '%'
					or	ast.fa_reff_no_03		like '%' + @p_keywords + '%'
					or	ast.asset_year			like '%' + @p_keywords + '%'
					or	ast.asset_condition		like '%' + @p_keywords + '%'
					or	ast.asset_status		like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ast.asset_no
													 when 2 then ast.fa_reff_no_01
													 when 3 then ast.asset_year
													 when 4 then ast.asset_condition
													 when 5 then cast(lease_rounded_amount as sql_variant)
													 when 6 then ast.asset_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then ast.asset_no
														when 2 then ast.fa_reff_no_01
														when 3 then ast.asset_year
														when 4 then ast.asset_condition
														when 5 then cast(lease_rounded_amount as sql_variant)
														when 6 then ast.asset_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
