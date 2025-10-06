CREATE PROCEDURE [dbo].[xsp_main_contract_charges_getrows]
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_main_contract_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	main_contract_charges ac
			inner join master_charges mc on (mc.code = ac.charges_code)
	where	main_contract_no = @p_main_contract_no
			and
			(
				mc.description						like '%' + @p_keywords + '%'
				or	case ac.calculate_by
						when 'PCT' then 'PERCENTAGE'
						when 'FUNCTION' then 'FUNCTION'
						else 'AMOUNT'
						end							like '%' + @p_keywords + '%'
				or	ac.charges_rate					like '%' + @p_keywords + '%'
				or	ac.charges_amount				like '%' + @p_keywords + '%'
				or	case ac.new_calculate_by
						when 'PCT' then 'PERCENTAGE'
						when 'FUNCTION' then 'FUNCTION'
						else 'AMOUNT'
						end							like '%' + @p_keywords + '%'
				or	ac.new_charges_rate				like '%' + @p_keywords + '%'
				or	ac.new_charges_amount			like '%' + @p_keywords + '%'
			) ;

	select		id
				,mc.description 'charges_desc'
				,case ac.calculate_by
					 when 'PCT' then 'PERCENTAGE'
					 when 'FUNCTION' then 'FUNCTION'
					 else 'AMOUNT'
				 end 'calculate_by'
				,ac.charges_rate
				,ac.charges_amount
				,case ac.new_calculate_by
					 when 'PCT' then 'PERCENTAGE'
					 when 'FUNCTION' then 'FUNCTION'
					 else 'AMOUNT'
				 end 'new_calculate_by'
				,ac.new_charges_rate
				,ac.new_charges_amount
				,@rows_count 'rowcount'
	from		main_contract_charges ac
				inner join dbo.master_charges mc on (mc.code = ac.charges_code)
	where		main_contract_no = @p_main_contract_no
				and
				(
					mc.description						like '%' + @p_keywords + '%'
					or	case ac.calculate_by
							when 'PCT' then 'PERCENTAGE'
							when 'FUNCTION' then 'FUNCTION'
							else 'AMOUNT'
							end							like '%' + @p_keywords + '%'
					or	ac.charges_rate					like '%' + @p_keywords + '%'
					or	ac.charges_amount				like '%' + @p_keywords + '%'
					or	case ac.new_calculate_by
							when 'PCT' then 'PERCENTAGE'
							when 'FUNCTION' then 'FUNCTION'
							else 'AMOUNT'
							end							like '%' + @p_keywords + '%'
					or	ac.new_charges_rate				like '%' + @p_keywords + '%'
					or	ac.new_charges_amount			like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mc.description
													 when 2 then ac.new_calculate_by
													 when 3 then cast(ac.new_charges_rate as sql_variant)
													 when 4 then cast(ac.new_charges_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then mc.description
													 when 2 then ac.new_calculate_by
													 when 3 then cast(ac.new_charges_rate as sql_variant)
													 when 4 then cast(ac.new_charges_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
