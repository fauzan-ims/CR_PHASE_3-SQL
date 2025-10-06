CREATE PROCEDURE dbo.xsp_master_insurance_coverage_loading_getrows
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_insurance_coverage_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_insurance_coverage_loading micl
			inner join dbo.master_coverage_loading mcl on (mcl.code = micl.loading_code)
	where	insurance_coverage_code = @p_insurance_coverage_code
			and (
					micl.loading_code		        like '%' + @p_keywords + '%'
					or	mcl.loading_name	        like '%' + @p_keywords + '%'
					or	micl.age_from		        like '%' + @p_keywords + '%'
					or	micl.age_to			        like '%' + @p_keywords + '%'
					or	case micl.loading_type
						when 'AGE' then 'AGE'
						when 'RENTAL' then 'RENTAL'
						else 'AUTHORIZED DEALER'
					end								like '%' + @p_keywords + '%'
					or	case micl.is_active
						when '1' then 'Yes'
						else 'No'
					end								like '%' + @p_keywords + '%'
				) ;
		select		micl.id
					,micl.loading_code
					,mcl.loading_name
					,micl.age_from	
					,micl.age_to
					,case micl.loading_type
						 when 'AGE' then 'AGE'
						 when 'RENTAL' then 'RENTAL'
						 else 'AUTHORIZED DEALER'
					 end 'loading_type'
					,case micl.is_active
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_active'
					,@rows_count 'rowcount'
		from		master_insurance_coverage_loading micl
					inner join dbo.master_coverage_loading mcl on (mcl.code = micl.loading_code)
		where		insurance_coverage_code = @p_insurance_coverage_code
					and (
							micl.loading_code					like '%' + @p_keywords + '%'
							or	mcl.loading_name				like '%' + @p_keywords + '%'
							or	micl.age_from					like '%' + @p_keywords + '%'
							or	micl.age_to						like '%' + @p_keywords + '%'
							or	case micl.loading_type
									when 'AGE' then 'AGE'
									when 'RENTAL' then 'RENTAL'
									else 'AUTHORIZED DEALER'
								end								like '%' + @p_keywords + '%'
							or	case micl.is_active
									when '1' then 'Yes'
									else 'No'
								end								like '%' + @p_keywords + '%'
						)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mcl.loading_name 		
													when 2 then micl.age_from 		
													when 3 then micl.age_to
													when 4 then micl.loading_type
													when 5 then micl.is_active
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then mcl.loading_name 		
													when 2 then micl.age_from 		
													when 3 then micl.age_to
													when 4 then micl.loading_type
													when 5 then micl.is_active
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
	
	
end ;


