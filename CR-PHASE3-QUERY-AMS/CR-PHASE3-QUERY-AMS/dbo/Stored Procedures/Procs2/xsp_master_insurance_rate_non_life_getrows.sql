CREATE PROCEDURE dbo.xsp_master_insurance_rate_non_life_getrows
(
	@p_keywords				 nvarchar(50)
	,@p_pagenumber			 int
	,@p_rowspage			 int
	,@p_order_by			 int
	,@p_sort_by				 nvarchar(5)
	,@p_insurance_code		 nvarchar(50)
	,@p_collateral_type_code nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_insurance_rate_non_life mirnl
			inner join master_insurance mi on (mi.code			   = mirnl.insurance_code)
			inner join sys_general_subcode sgs on (sgs.code		   = mirnl.collateral_type_code)
			inner join master_collateral_category mcc on (mcc.code = mirnl.collateral_category_code)
			inner join master_coverage mc on (mc.code			   = mirnl.coverage_code)
			left join master_region mr on (mr.code				   = mirnl.region_code)
	where	mirnl.insurance_code		   = case @p_insurance_code
												 when 'ALL' then mirnl.insurance_code
												 else @p_insurance_code
											 end
			and mirnl.collateral_type_code = case @p_collateral_type_code
												 when 'ALL' then mirnl.collateral_type_code
												 else @p_collateral_type_code
											 end
			and (
					mi.insurance_name				like '%' + @p_keywords + '%'
					or	sgs.description				like '%' + @p_keywords + '%'
					or	mcc.category_name			like '%' + @p_keywords + '%'
					or	mc.coverage_name			like '%' + @p_keywords + '%'
					or	mr.region_name				like '%' + @p_keywords + '%'
					or	case mirnl.is_active
							when '1' then 'Yes'
							else 'No'
						end							like '%' + @p_keywords + '%'
				) ;

 
		select		mirnl.code
					,mi.insurance_name
					,sgs.description 'collateral_type'		
					,mcc.category_name	
					,mc.coverage_name	
					,mr.region_name		
					,case mirnl.is_active
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_active'
					,@rows_count 'rowcount'
		from		master_insurance_rate_non_life mirnl
					inner join master_insurance mi on (mi.code			   = mirnl.insurance_code)
					inner join sys_general_subcode sgs on (sgs.code		   = mirnl.collateral_type_code)
					inner join master_collateral_category mcc on (mcc.code = mirnl.collateral_category_code)
					inner join master_coverage mc on (mc.code			   = mirnl.coverage_code)
					left join master_region mr on (mr.code				   = mirnl.region_code)
		where		mirnl.insurance_code		   = case @p_insurance_code
														 when 'ALL' then mirnl.insurance_code
														 else @p_insurance_code
													 end
					and mirnl.collateral_type_code = case @p_collateral_type_code
														 when 'ALL' then mirnl.collateral_type_code
														 else @p_collateral_type_code
													 end
					and (
							mi.insurance_name				like '%' + @p_keywords + '%'
							or	sgs.description				like '%' + @p_keywords + '%'
							or	mcc.category_name			like '%' + @p_keywords + '%'
							or	mc.coverage_name			like '%' + @p_keywords + '%'
							or	mr.region_name				like '%' + @p_keywords + '%'
							or	case mirnl.is_active
									when '1' then 'Yes'
									else 'No'
								end							like '%' + @p_keywords + '%'
						)
 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mi.insurance_name
													when 2 then sgs.description	
													when 3 then mcc.category_name	
													when 4 then mc.coverage_name	
													when 5 then mr.region_name		
													when 6 then mirnl.is_active
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then mi.insurance_name
													when 2 then sgs.description	
													when 3 then mcc.category_name	
													when 4 then mc.coverage_name	
													when 5 then mr.region_name		
													when 6 then mirnl.is_active
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;


