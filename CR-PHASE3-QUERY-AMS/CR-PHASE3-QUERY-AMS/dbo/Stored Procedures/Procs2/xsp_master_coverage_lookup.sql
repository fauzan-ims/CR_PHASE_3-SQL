CREATE PROCEDURE dbo.xsp_master_coverage_lookup
(
	@p_keywords	       nvarchar(50)
	,@p_pagenumber     int
	,@p_rowspage       int
	,@p_order_by       int
	,@p_sort_by	       nvarchar(5)
	,@p_insurance_type nvarchar(10) = 'ALL'
	,@p_currency_code  nvarchar(10) = 'ALL'
	,@p_array_data     varchar(max) = ''
	,@p_is_main_only   nvarchar(1) = ''
)
as
begin
	declare @rows_count int = 0 ;

	declare @temptable table
	(
		code nvarchar(50),
		stringvalue nvarchar(250)
	);

	if isnull(@p_is_main_only,'') = ''
	begin
			set @p_is_main_only = null
	end


	if isnull(@p_array_data,'') = ''
	begin
		insert into @temptable
		(
			code,
			stringvalue
		)
		values
		(   '', -- code - nvarchar(50)
			''  -- stringvalue - nvarchar(250)
		)
    end
	else
	begin
		insert into @temptable
		(
			code,
			stringvalue
		)
		select name,
			   stringvalue
		from dbo.parsejson(@p_array_data) ;
	end	

	select	@rows_count = count(1)
	from	master_coverage
	where	is_active = '1'
			and is_main_coverage = isnull( @p_is_main_only , is_main_coverage)
			and currency_code = case @p_currency_code
									when 'ALL' then currency_code
									else @p_currency_code
								end
			and	code not in (
					select stringvalue
					from @temptable
					where isnull(code, '') = 'coverage_code'
				)
			--and insurance_type = case @p_insurance_type
			--						 when 'ALL' then insurance_type
			--						 else @p_insurance_type
			--					 end
			and(
				code							like '%' + @p_keywords + '%'
				or	coverage_name				like '%' + @p_keywords + '%'
				or	coverage_short_name			like '%' + @p_keywords + '%'
				or	insurance_type				like '%' + @p_keywords + '%'
				or	case is_active
							when '1' then 'Yes'
							else 'No'
						end 					like '%' + @p_keywords + '%'
			) ;


		select		code
					,currency_code
					,coverage_name
					,case is_active
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_active'
					,is_main_coverage
					,insurance_type
					,@rows_count 'rowcount'
		from		master_coverage
		where		is_active = '1'
					and is_main_coverage = isnull( @p_is_main_only , is_main_coverage)
					and currency_code = case @p_currency_code
											when 'ALL' then currency_code
											else @p_currency_code
										end
					and	code not in (
							select stringvalue
							from @temptable
							where isnull(code, '') = 'coverage_code'
						)
					--and insurance_type = case @p_insurance_type
					--						 when 'ALL' then insurance_type
					--						 else @p_insurance_type
					--					 end
					and (
						code							like '%' + @p_keywords + '%'
						or	coverage_name				like '%' + @p_keywords + '%'
						or	insurance_type				like '%' + @p_keywords + '%'
						or	coverage_short_name			like '%' + @p_keywords + '%'
						or	case is_active
								 when '1' then 'Yes'
								 else 'No'
							 end 						like '%' + @p_keywords + '%'
					)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then coverage_name
													when 2 then insurance_type
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then coverage_name
													when 2 then insurance_type
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;


