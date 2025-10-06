---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_charges_amount_getrows
(
	@p_keywords	      nvarchar(50)
	,@p_pagenumber    int
	,@p_rowspage      int
	,@p_order_by      int
	,@p_sort_by	      nvarchar(5)
	,@p_charge_code   nvarchar(50)
	,@p_facility_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_charges_amount mca
			inner join dbo.master_facility mf on (mf.code = mca.facility_code)
	where	charge_code = @p_charge_code
			and facility_code	= case @p_facility_code
									when 'ALL' then facility_code
									else @p_facility_code
								  end
			and (
					mca.code										like '%' + @p_keywords + '%'
					or	mf.description								like '%' + @p_keywords + '%'
					or  convert(varchar(30), effective_date, 103)	like '%' + @p_keywords + '%'
					or	calculate_by								like '%' + @p_keywords + '%'
					or	charges_rate								like '%' + @p_keywords + '%'
					or	mca.currency_code							like '%' + @p_keywords + '%'
					or	charges_amount								like '%' + @p_keywords + '%'
				) ;
				 
		select		mca.code
					,mf.description 'facility_desc'
					,convert(varchar(30), effective_date, 103) 'effective_date'
					,calculate_by	
					,charges_rate	
					,charges_amount	
					,mca.currency_code
					,@rows_count 'rowcount'
		from	master_charges_amount mca
				inner join dbo.master_facility mf on (mf.code = mca.facility_code)
		where	charge_code = @p_charge_code
				and facility_code	= case @p_facility_code
										when 'ALL' then facility_code
										else @p_facility_code
									  end
				and (
						mca.code										like '%' + @p_keywords + '%'
						or	mf.description								like '%' + @p_keywords + '%'
						or  convert(varchar(30), effective_date, 103)	like '%' + @p_keywords + '%'
						or	calculate_by								like '%' + @p_keywords + '%'
						or	charges_rate								like '%' + @p_keywords + '%'
						or	mca.currency_code							like '%' + @p_keywords + '%'
						or	charges_amount								like '%' + @p_keywords + '%'
					) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then cast(effective_date as sql_variant)	
													when 2 then mf.description		
													when 3 then calculate_by	
													when 4 then cast(charges_rate as sql_variant)	
													when 5 then mca.currency_code + cast(charges_amount as nvarchar(50))	
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then cast(effective_date as sql_variant)	
													when 2 then mf.description		
													when 3 then calculate_by	
													when 4 then cast(charges_rate as sql_variant)	
													when 5 then mca.currency_code + cast(charges_amount as nvarchar(50))	
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

