CREATE PROCEDURE [dbo].[xsp_insurance_register_period_getrows]
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_register_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0
			,@type		nvarchar(20)

	select @type = register_type 
	from dbo.insurance_register
	where code = @p_register_code


	if (@type <> 'PERIOD')
	begin
		select	@rows_count = count(1)
		from	insurance_register_period irp
				inner join dbo.master_coverage mc on (mc.code = irp.coverage_code)
				outer apply(select isnull(sum(sum_insured_amount),0) 'sum_insured_amount' from dbo.insurance_register_asset ira where ira.register_code = irp.register_code and ira.insert_type = 'NEW') asset
		where	register_code = @p_register_code
				and (
						mc.coverage_name				like '%' + @p_keywords + '%'
						or irp.year_periode				like '%' + @p_keywords + '%'
						or	case irp.is_main_coverage	
							when '1' then 'Yes'
							else 'No'
						end								like '%' + @p_keywords + '%'
						or irp.total_buy_amount			like '%' + @p_keywords + '%'
						or asset.sum_insured_amount		like '%' + @p_keywords + '%'
					) ;
 
			select		irp.id
						,mc.coverage_name
						,case irp.is_main_coverage
							 when '1' then 'Yes'
							 else 'No'
						 end 'is_main_coverage'	
						,irp.year_periode		
						,irp.total_buy_amount
						,asset.sum_insured_amount --* (irp.rate_depreciation/100) 'sum_insured_amount'
						,case 
							when mc.coverage_short_name like 'TPL%' then isnull(irp.sum_insured,0)
							when mc.coverage_short_name = 'PERSPASS' then isnull(irp.sum_insured,0)
							when mc.coverage_short_name = 'PERSDRI' then isnull(irp.sum_insured,0)
							else asset.sum_insured_amount
						end 'sum_insured'
						,case 
							when mc.coverage_short_name like 'TPL%' then 'TPL'
							else mc.coverage_short_name
						end 'coverage_short_name'
						,@rows_count 'rowcount'
			from		insurance_register_period irp
						inner join dbo.master_coverage mc on (mc.code = irp.coverage_code)
						outer apply(select isnull(sum(sum_insured_amount),0) 'sum_insured_amount' from dbo.insurance_register_asset ira where ira.register_code = irp.register_code and ira.insert_type = 'NEW') asset
			where		register_code = @p_register_code
						and (
								mc.coverage_name					like '%' + @p_keywords + '%'
								or irp.year_periode					like '%' + @p_keywords + '%'
									or	case irp.is_main_coverage	
									when '1' then 'Yes'
									else 'No'
								end									like '%' + @p_keywords + '%'
								or irp.total_buy_amount				like '%' + @p_keywords + '%'
								or asset.sum_insured_amount			like '%' + @p_keywords + '%'
							)
 
		order by case  
						when @p_sort_by = 'asc' then case @p_order_by
														when 1 then cast(irp.year_periode as sql_variant)
														when 2 then cast(asset.sum_insured_amount as sql_variant)
														when 3 then	mc.coverage_name
														when 4 then irp.is_main_coverage
														when 5 then mc.insurance_type
													 end
					end asc 
					,case when @p_sort_by = 'desc' then case @p_order_by
															when 1 then cast(irp.year_periode as sql_variant)
															when 2 then cast(asset.sum_insured_amount as sql_variant)
															when 3 then	mc.coverage_name
															when 4 then irp.is_main_coverage
															when 5 then mc.insurance_type
														end
			end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
	end
	else
	begin
		select	@rows_count = count(1)
		from	insurance_register_period irp
				inner join dbo.master_coverage mc on (mc.code = irp.coverage_code)
				outer apply(select isnull(sum(sum_insured_amount),0) 'sum_insured_amount' from dbo.insurance_register_asset ira where ira.register_code = irp.register_code) asset
		where	register_code = @p_register_code
				and (
						mc.coverage_name				like '%' + @p_keywords + '%'
						or irp.year_periode				like '%' + @p_keywords + '%'
						or	case irp.is_main_coverage	
							when '1' then 'Yes'
							else 'No'
						end								like '%' + @p_keywords + '%'
						or irp.total_buy_amount			like '%' + @p_keywords + '%'
						or asset.sum_insured_amount		like '%' + @p_keywords + '%'
					) ;
 
			select		irp.id
						,mc.coverage_name
						,case irp.is_main_coverage
							 when '1' then 'Yes'
							 else 'No'
						 end 'is_main_coverage'	
						,irp.year_periode		
						,irp.total_buy_amount
						,asset.sum_insured_amount --* (irp.rate_depreciation/100) 'sum_insured_amount'
						,case 
							when mc.coverage_short_name like 'TPL%' then isnull(irp.sum_insured,0)
							when mc.coverage_short_name = 'PERSPASS' then isnull(irp.sum_insured,0)
							when mc.coverage_short_name = 'PERSDRI' then isnull(irp.sum_insured,0)
							else asset.sum_insured_amount
						end 'sum_insured'
						,case 
							when mc.coverage_short_name like 'TPL%' then 'TPL'
							else mc.coverage_short_name
						end 'coverage_short_name'
						,@rows_count 'rowcount'
			from		insurance_register_period irp
						inner join dbo.master_coverage mc on (mc.code = irp.coverage_code)
						outer apply(select isnull(sum(sum_insured_amount),0) 'sum_insured_amount' from dbo.insurance_register_asset ira where ira.register_code = irp.register_code) asset
			where		register_code = @p_register_code
						and (
								mc.coverage_name					like '%' + @p_keywords + '%'
								or irp.year_periode					like '%' + @p_keywords + '%'
									or	case irp.is_main_coverage	
									when '1' then 'Yes'
									else 'No'
								end									like '%' + @p_keywords + '%'
								or irp.total_buy_amount				like '%' + @p_keywords + '%'
								or asset.sum_insured_amount			like '%' + @p_keywords + '%'
							)
 
		order by case  
						when @p_sort_by = 'asc' then case @p_order_by
														when 1 then cast(irp.year_periode as sql_variant)
														when 2 then cast(asset.sum_insured_amount as sql_variant)
														when 3 then	mc.coverage_name
														when 4 then irp.is_main_coverage
														when 5 then mc.insurance_type
													 end
					end asc 
					,case when @p_sort_by = 'desc' then case @p_order_by
															when 1 then cast(irp.year_periode as sql_variant)
															when 2 then cast(asset.sum_insured_amount as sql_variant)
															when 3 then	mc.coverage_name
															when 4 then irp.is_main_coverage
															when 5 then mc.insurance_type
														end
			end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end
end ;

