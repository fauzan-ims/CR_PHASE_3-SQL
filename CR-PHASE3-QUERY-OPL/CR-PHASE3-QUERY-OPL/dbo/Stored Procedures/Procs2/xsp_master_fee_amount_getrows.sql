CREATE PROCEDURE dbo.xsp_master_fee_amount_getrows
(
	@p_keywords	      nvarchar(50)
	,@p_pagenumber    int
	,@p_rowspage      int
	,@p_order_by      int
	,@p_sort_by	      nvarchar(5)
	,@p_fee_code      nvarchar(50)
	,@p_facility_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_fee_amount mfa 
			inner join dbo.master_facility mf on (mf.code = mfa.facility_code)
	where	fee_code = @p_fee_code
			and facility_code	= case @p_facility_code
									when 'ALL' then facility_code
									else @p_facility_code
								  end
			and (
					mfa.code										like '%' + @p_keywords + '%'
					or mf.description								like '%' + @p_keywords + '%'
					or  convert(varchar(30), effective_date, 103)	like '%' + @p_keywords + '%'
					or	case mfa.calculate_base
							when 'APP' then 'APPLICATION'
							else 'ASSET' end 						like '%' + @p_keywords + '%'
					or	calculate_by								like '%' + @p_keywords + '%'
					or	fee_rate									like '%' + @p_keywords + '%'
					or	fee_amount									like '%' + @p_keywords + '%'
					or	mfa.currency_code							like '%' + @p_keywords + '%'
				) ; 
		select		mfa.code
					,mf.description 'facility_desc'
					,convert(varchar(30), effective_date, 103) 'effective_date'
					,case mfa.calculate_base
						when 'APP' then 'APPLICATION'
					 else 'ASSET' end 'calculate_base'
					,calculate_by	
					,fee_rate		
					,fee_amount		
					,mfa.currency_code
					,@rows_count 'rowcount'
		from		master_fee_amount mfa 
					inner join dbo.master_facility mf on (mf.code = mfa.facility_code)
		where		fee_code = @p_fee_code
					and facility_code	= case @p_facility_code
											when 'ALL' then facility_code
											else @p_facility_code
										  end
					and (
							mfa.code										like '%' + @p_keywords + '%'
							or mf.description								like '%' + @p_keywords + '%'
							or  convert(varchar(30), effective_date, 103)	like '%' + @p_keywords + '%'
							or	case mfa.calculate_base
									when 'APP' then 'APPLICATION'
								 else 'ASSET' end 							like '%' + @p_keywords + '%'
							or	calculate_by								like '%' + @p_keywords + '%'
							or	fee_rate									like '%' + @p_keywords + '%'
							or	fee_amount									like '%' + @p_keywords + '%'
							or	mfa.currency_code							like '%' + @p_keywords + '%'
					) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then cast(effective_date as sql_variant)
													when 2 then mf.description	
													when 3 then mfa.currency_code
													when 4 then calculate_base	
													when 5 then calculate_by	
													when 6 then cast(fee_rate as sql_variant)		
													when 7 then cast(fee_amount as sql_variant)
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then cast(effective_date as sql_variant)
													when 2 then mf.description	
													when 3 then mfa.currency_code
													when 4 then calculate_base	
													when 5 then calculate_by	
													when 6 then cast(fee_rate as sql_variant)		
													when 7 then cast(fee_amount as sql_variant)
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

