CREATE PROCEDURE dbo.xsp_master_charges_lookup
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_charges mc
	where	is_active = '1'
			and (
					mc.code				like '%' + @p_keywords + '%'
					or	mc.description	like '%' + @p_keywords + '%'
				) ;

	select		mc.code
				,mc.description
				,detail.charges_rate
				,detail.charges_amount
				,detail.calculate_by
				,@rows_count 'rowcount'
	from		master_charges mc
				outer apply (
						select	top 1 charge_code
								,mca.calculate_by
								,mca.charges_rate
								,mca.charges_amount
						from	dbo.master_charges_amount mca
								inner join dbo.master_facility mf on (mf.code = mca.facility_code)
						where	mca.charge_code = mc.code
								and mca.effective_date <= dbo.xfn_get_system_date()
						order by mca.effective_date desc
					) detail
	where		is_active = '1'
				and (
						mc.code				like '%' + @p_keywords + '%'
						or	mc.description	like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then mc.code
														when 2 then mc.description 
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then mc.code
														when 2 then mc.description 
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;  
end ;

