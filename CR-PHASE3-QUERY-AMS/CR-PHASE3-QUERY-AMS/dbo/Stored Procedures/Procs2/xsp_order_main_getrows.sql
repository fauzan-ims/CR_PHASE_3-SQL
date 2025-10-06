CREATE PROCEDURE dbo.xsp_order_main_getrows
(
	@p_keywords			  nvarchar(50)
	,@p_pagenumber		  int
	,@p_rowspage		  int
	,@p_order_by		  int
	,@p_sort_by			  nvarchar(5)
	,@p_branch_code		  nvarchar(50)
	,@p_public_service	  NVARCHAR(50) = ''
	,@p_order_main_status nvarchar(20)
	,@p_date			  datetime = ''
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	order_main om
			inner join dbo.master_public_service mps on (mps.code = om.public_service_code)
	where	om.branch_code		= case @p_branch_code
									  when 'ALL' then om.branch_code
									  else @p_branch_code
								  END
			and cast(order_date as date) = case cast(@p_date as date)
											  when '' then cast(order_date as date)
											  else cast(@p_date as date)
										  END
			and om.order_status = case @p_order_main_status
									  when 'ALL' then om.order_status
									  else @p_order_main_status
								  end
			and (
					om.order_no									like '%' + @p_keywords + '%'
					or	convert(varchar(30), order_date, 103)	like '%' + @p_keywords + '%'
					or	order_status							like '%' + @p_keywords + '%'
					or	order_amount							like '%' + @p_keywords + '%'
					or	order_remarks							like '%' + @p_keywords + '%'
					or	branch_name								like '%' + @p_keywords + '%'
					OR	mps.public_service_name					like '%' + @p_keywords + '%'
					OR	om.asset								like '%' + @p_keywords + '%'
				) ;

		select		om.code
					,convert(varchar(30), order_date, 103) 'order_date'
					,om.order_status							
					,om.order_amount								
					,om.order_remarks							
					,om.branch_name	
					,om.order_no
					,om.asset						
					,@rows_count 'rowcount'
					,mps.public_service_name
		from		order_main om
					INNER join dbo.master_public_service mps on (mps.code = om.public_service_code)
		where		om.branch_code		= case @p_branch_code
											  when 'ALL' then om.branch_code
											  else @p_branch_code
										  END
					and cast(order_date as date) = case cast(@p_date as date)
											  when '' then cast(order_date as date)
											  else cast(@p_date as date)
										  END
                    AND om.public_service_code = CASE @p_public_service 
										when '' then om.public_service_code
										else @p_public_service      
										END 
					and om.order_status = case @p_order_main_status
											  when 'ALL' then om.order_status
											  else @p_order_main_status
										  end
					and (
							om.order_no									like '%' + @p_keywords + '%'
							or	convert(varchar(30), order_date, 103)	like '%' + @p_keywords + '%'
							or	order_status							like '%' + @p_keywords + '%'
							or	order_amount							like '%' + @p_keywords + '%'
							or	order_remarks							like '%' + @p_keywords + '%'
							or	branch_name								like '%' + @p_keywords + '%'
							OR	mps.public_service_name					like '%' + @p_keywords + '%'
							OR	om.asset								like '%' + @p_keywords + '%'
						)
	
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then order_no
													WHEN 2 THEN public_service_name
													when 3 then cast(om.order_date as sql_variant)
													WHEN 4 THEN om.asset
													when 5 then cast(order_amount as sql_variant)							
													when 6 then order_remarks						
													when 7 then order_status	
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then order_no
														WHEN 2 THEN public_service_name
														when 3 then cast(om.order_date as sql_variant)
														WHEN 4 THEN om.asset
														when 5 then cast(order_amount as sql_variant)							
														when 6 then order_remarks						
														when 7 then order_status	
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	

end ;
