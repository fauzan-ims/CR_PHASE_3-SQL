---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_deviation_lookup
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_facility_code nvarchar(50) = 'ALL'
	,@p_type		  nvarchar(15)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_deviation
	where	is_active		  = '1'
			and is_manual	  = '1'
			and facility_code = case @p_facility_code
									when 'ALL' then facility_code
									else @p_facility_code
								end
			and type		  = @p_type
			and (
					code			like '%' + @p_keywords + '%'
					or	description like '%' + @p_keywords + '%'
				) ;
				 
		select		code
					,description
					,position_code
					,position_name
					,@rows_count 'rowcount'
		from		master_deviation
		where		is_active		  = '1'
					and is_manual	  = '1'
					and facility_code = case @p_facility_code
											when 'ALL' then facility_code
											else @p_facility_code
										end
					and type		  = @p_type
					and (
							code			like '%' + @p_keywords + '%'
							or	description like '%' + @p_keywords + '%'
						) 
		Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then code
													when 2 then description
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then code
													when 2 then description
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
