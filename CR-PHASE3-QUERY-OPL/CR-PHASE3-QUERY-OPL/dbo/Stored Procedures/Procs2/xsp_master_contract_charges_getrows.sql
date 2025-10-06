CREATE procedure [dbo].[xsp_master_contract_charges_getrows]
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	--
	,@p_main_contract_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.master_contract_charges	  moc
			inner join dbo.master_charges mca on mca.code = moc.charges_code
	where	main_contract_no = @p_main_contract_no
			and
			(
				mca.description				like '%' + @p_keywords + '%'
				or	case moc.calculate_by
					when 'PCT' then 'PERCENTAGE'
					when 'FUNCTION' then 'FUNCTION'
					else 'AMOUNT'
				end							like '%' + @p_keywords + '%'
				or	charges_rate			like '%' + @p_keywords + '%'
				or	charges_amount			like '%' + @p_keywords + '%'
				or	case moc.new_calculate_by
					when 'PCT' then 'PERCENTAGE'
					when 'FUNCTION' then 'FUNCTION'
					else 'AMOUNT'
				end							like '%' + @p_keywords + '%'
				or	moc.new_charges_rate	like '%' + @p_keywords + '%'
				or	moc.new_charges_amount	like '%' + @p_keywords + '%'
			) ;

	select		id
				,mca.description
				,case moc.calculate_by
					when 'PCT' then 'PERCENTAGE'
					when 'FUNCTION' then 'FUNCTION'
					else 'AMOUNT'
				end 'calculate_by'
				,charges_rate
				,moc.charges_amount
				,moc.new_charges_rate
				,moc.new_charges_amount
				,case moc.new_calculate_by
					when 'PCT' then 'PERCENTAGE'
					when 'FUNCTION' then 'FUNCTION'
					else 'AMOUNT'
				end 'new_calculate_by'
				,@rows_count 'rowcount'
	from		dbo.master_contract_charges	  moc
				inner join dbo.master_charges mca on mca.code = moc.charges_code
	where		main_contract_no = @p_main_contract_no
				and
				(
					mca.description				like '%' + @p_keywords + '%'
					or	case moc.calculate_by
						when 'PCT' then 'PERCENTAGE'
						when 'FUNCTION' then 'FUNCTION'
						else 'AMOUNT'
					end							like '%' + @p_keywords + '%'
					or	charges_rate			like '%' + @p_keywords + '%'
					or	charges_amount			like '%' + @p_keywords + '%'
					or	case moc.new_calculate_by
						when 'PCT' then 'PERCENTAGE'
						when 'FUNCTION' then 'FUNCTION'
						else 'AMOUNT'
					end							like '%' + @p_keywords + '%'
					or	moc.new_charges_rate	like '%' + @p_keywords + '%'
					or	moc.new_charges_amount	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mca.description
													 when 2 then moc.calculate_by
													 when 3 then cast(moc.charges_rate as sql_variant)
													 when 4 then cast(moc.charges_amount as sql_variant)
													 when 5 then moc.new_calculate_by
													 when 6 then cast(moc.new_charges_rate as sql_variant)
													 when 7 then cast(moc.new_charges_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then mca.description
													 when 2 then moc.calculate_by
													 when 3 then cast(moc.charges_rate as sql_variant)
													 when 4 then cast(moc.charges_amount as sql_variant)
													 when 5 then moc.new_calculate_by
													 when 6 then cast(moc.new_charges_rate as sql_variant)
													 when 7 then cast(moc.new_charges_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
