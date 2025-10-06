CREATE PROCEDURE [dbo].[xsp_document_movement_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_movement_status nvarchar(20)
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	document_movement
	where	@p_branch_code		= case @p_branch_code
									  when 'all' then @p_branch_code
									  else case movement_type + movement_location
											   when 'returnbranch' then branch_code
											   else branch_code
										   end
								  end
			and movement_status = case @p_movement_status
									  when 'ALL' then movement_status
									  else @p_movement_status
								  end
			and (
					branch_name					like '%' + @p_keywords + '%'
					or	code					like '%' + @p_keywords + '%'
					or	movement_date			like '%' + @p_keywords + '%'
					or	movement_status			like '%' + @p_keywords + '%'
					or	movement_type			like '%' + @p_keywords + '%'
					or	movement_location		like '%' + @p_keywords + '%'
					or	movement_from			like '%' + @p_keywords + '%'
					or	movement_to				like '%' + @p_keywords + '%'
					or	movement_to_client_name	like '%' + @p_keywords + '%'
					or	movement_by_emp_name	like '%' + @p_keywords + '%'
					or	movement_from_dept_name	like '%' + @p_keywords + '%'
					or	movement_to_dept_name	like '%' + @p_keywords + '%'
					or	movement_to_branch_name	like '%' + @p_keywords + '%'
				) ;

		select		code
					,branch_code
					,branch_name
					,convert(varchar(30), movement_date, 103) 'movement_date'
					,movement_status
					,movement_type
					,movement_location
					,case
						 when movement_type = 'entry' then movement_from
						 when movement_location = 'branch' then branch_name
						 when movement_location = 'department' then movement_from_dept_name
						 when movement_location = 'third party' then movement_from
						 else movement_from -- enrty , third party
					 end 'movement_from'
					,case
						 when movement_type = 'entry' then movement_to
						 when movement_location = 'branch' then MOVEMENT_TO_BRANCH_NAME
						 when movement_location = 'department' then 'BRANCH'
						 when movement_location = 'client' then MOVEMENT_TO_CLIENT_NAME
						 else movement_to -- enrty , third party
					 end 'movement_to'
					,movement_by_emp_code
					,movement_by_emp_name
					,movement_courier_code
					,movement_remarks
					,receive_status
					,convert(varchar(30), receive_date, 103) 'receive_date'
					,receive_remark
					,@rows_count 'rowcount'
		from		document_movement
		where		@p_branch_code		= case @p_branch_code
											  when 'all' then @p_branch_code
											  else case movement_type + movement_location
													   when 'returnbranch' then branch_code
													   else branch_code
												   end
										  end
					and movement_status = case @p_movement_status
											  when 'ALL' then movement_status
											  else @p_movement_status
										  end
					and (
							branch_name					like '%' + @p_keywords + '%'
							or	code					like '%' + @p_keywords + '%'
							or	movement_date			like '%' + @p_keywords + '%'
							or	movement_status			like '%' + @p_keywords + '%'
							or	movement_type			like '%' + @p_keywords + '%'
							or	movement_location		like '%' + @p_keywords + '%'
							or	movement_from			like '%' + @p_keywords + '%'
							or	movement_to				like '%' + @p_keywords + '%'
							or	movement_to_client_name	like '%' + @p_keywords + '%'
							or	movement_by_emp_name	like '%' + @p_keywords + '%'
							or	movement_from_dept_name	like '%' + @p_keywords + '%'
							or	movement_to_dept_name	like '%' + @p_keywords + '%'
							or	movement_to_branch_name	like '%' + @p_keywords + '%'
						)
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then code
													when 2 then branch_name
													when 3 then movement_type
													when 4 then case
																	when movement_type = 'entry' then movement_from
																	when movement_location = 'branch' then branch_name
																	when movement_location = 'department' then movement_from_dept_name
																	when movement_location = 'third party' then movement_from
																	else movement_from -- enrty , third party
																end
													when 5 then case
																	when movement_type = 'entry' then movement_to
																	when movement_location = 'branch' then MOVEMENT_TO_BRANCH_NAME
																	when movement_location = 'department' then 'BRANCH'
																	when movement_location = 'client' then MOVEMENT_TO_CLIENT_NAME
																	else movement_to -- enrty , third party
																end
													when 6 then cast(movement_date as sql_variant)
													when 7 then movement_status
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then branch_name
														when 3 then movement_type
														when 4 then case
																		when movement_type = 'entry' then movement_from
																		when movement_location = 'branch' then branch_name
																		when movement_location = 'department' then movement_from_dept_name
																		when movement_location = 'third party' then movement_from
																		else movement_from -- enrty , third party
																	end
														when 5 then case
																		when movement_type = 'entry' then movement_to
																		when movement_location = 'branch' then MOVEMENT_TO_BRANCH_NAME
																		when movement_location = 'department' then 'BRANCH'
																		when movement_location = 'client' then MOVEMENT_TO_CLIENT_NAME
																		else movement_to -- enrty , third party
																	end
														when 6 then cast(movement_date as sql_variant)
														when 7 then movement_status
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;
