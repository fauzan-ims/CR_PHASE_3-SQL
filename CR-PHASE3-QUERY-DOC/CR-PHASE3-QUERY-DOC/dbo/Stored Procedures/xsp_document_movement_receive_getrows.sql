CREATE PROCEDURE [dbo].[xsp_document_movement_receive_getrows]
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
	where	movement_status						= case @p_movement_status
													  when 'ALL' then movement_status
													  else @p_movement_status
												  end
			and (
					branch_code					= case @p_branch_code
													  when 'ALL' then branch_code
													  else @p_branch_code
												  end
					or	movement_to_branch_code = case @p_branch_code
													  when 'ALL' then movement_to_branch_code
													  else @p_branch_code
												  end
				)
			--and movement_status	<> 'HOLD' 
			and (
					(
						movement_type			= 'RECEIVED'
						and movement_location in
						(
							'ENTRY', 'THIRD PARTY'
						)
						and movement_status		= case @p_movement_status
													  when 'ALL' then movement_status
													  else @p_movement_status
												  end
					)
					--jika send tampil di menu received ambil yang movement send and return
					or	
					(
						movement_type		= 'SEND'
						and movement_status not in ( 'HOLD','CANCEL', 'ON PROCESS')
					)
					or	
					(
						movement_type		= 'RETURN'
						and movement_status in ('ON PROCESS')
					)
				)
			and movement_status <> 'REJECT'
			and (
					branch_name																							like '%' + @p_keywords + '%'
					or	code																							like '%' + @p_keywords + '%'
					or	convert(varchar(30), movement_date, 103)														like '%' + @p_keywords + '%'
					or	movement_status																					like '%' + @p_keywords + '%'
					or	movement_type																					like '%' + @p_keywords + '%'
					or	movement_location																				like '%' + @p_keywords + '%'
					or	case
							when movement_location = 'branch' then branch_name
							when movement_location = 'department' then isnull(movement_from_dept_name, branch_name)
							when movement_location = 'third party' then branch_name
							when movement_location = 'client' then branch_name
							else movement_from -- enrty , third party
						end																								like '%' + @p_keywords + '%'
					or	case
							when movement_location = 'branch' then MOVEMENT_TO_BRANCH_NAME
							when movement_location = 'department' then isnull(movement_to_dept_name, branch_name)
							when movement_location = 'client' then MOVEMENT_TO_CLIENT_NAME
							else movement_to -- enrty , third party
						end																								like '%' + @p_keywords + '%'
					or	movement_to_client_name																			like '%' + @p_keywords + '%'
				) ;

	select		code
				,branch_code
				,branch_name
				,convert(varchar(30), movement_date, 103) 'movement_date'
				,movement_status
				,movement_type
				,case
					when movement_location = 'client' then 'RELEASE CUSTOMER'
					when movement_location = 'borrow client' then 'BORROW CUSTOMER'
					when movement_location = 'third party' then 'BORROW THIRD PARTY'
					else movement_location
				end 'movement_location'
				,case
					 when movement_location = 'branch' then branch_name
					 when movement_location = 'department' then isnull(movement_from_dept_name, branch_name)
					 when movement_location = 'third party' then movement_from
					 when movement_location = 'client' then branch_name
					 else movement_from -- enrty , third party
				 end 'movement_from'
				,case
					 when movement_location = 'branch' then movement_to_branch_name
					 when movement_location = 'department' then isnull(movement_to_dept_name, branch_name)
					 when movement_location = 'client' then movement_to_client_name
					 when movement_location = 'third party' then branch_name
					 else movement_to -- enrty , third party
				 end 'movement_to'
				,movement_to_client_name
				,movement_by_emp_code
				,movement_by_emp_name
				,movement_courier_code
				,movement_remarks
				,receive_status
				,convert(varchar(30), receive_date, 103) 'receive_date'
				,receive_remark
				,@rows_count 'rowcount'
	from		document_movement
	where		movement_status						= case @p_movement_status
														  when 'ALL' then movement_status
														  else @p_movement_status
													  end
				and (
						branch_code					= case @p_branch_code
														  when 'ALL' then branch_code
														  else @p_branch_code
													  end
						or	movement_to_branch_code = case @p_branch_code
														  when 'ALL' then movement_to_branch_code
														  else @p_branch_code
													  end
					)
				--and movement_status	<> 'HOLD' 
				and (
						(
							movement_type			= 'RECEIVED'
							and movement_location in
							(
								'ENTRY', 'THIRD PARTY'
							)
							and movement_status		= case @p_movement_status
														  when 'ALL' then movement_status
														  else @p_movement_status
													  end
						)
						--jika send tampil di menu received ambil yang movement send and return
						or	
						(
							movement_type		= 'SEND'
							and movement_status not in ( 'HOLD','CANCEL', 'ON PROCESS')
						)
						or	
						(
							movement_type		= 'RETURN'
							and movement_status in ('ON PROCESS')
						)
					)
				and movement_status <> 'REJECT'
				and (
						branch_name																							like '%' + @p_keywords + '%'
						or	code																							like '%' + @p_keywords + '%'
						or	convert(varchar(30), movement_date, 103)														like '%' + @p_keywords + '%'
						or	movement_status																					like '%' + @p_keywords + '%'
						or	movement_type																					like '%' + @p_keywords + '%'
						or	movement_location																				like '%' + @p_keywords + '%'
						or	case
								when movement_location = 'branch' then branch_name
								when movement_location = 'department' then isnull(movement_from_dept_name, branch_name)
								when movement_location = 'third party' then branch_name
								when movement_location = 'client' then branch_name
								else movement_from -- enrty , third party
							end																								like '%' + @p_keywords + '%'
						or	case
								when movement_location = 'branch' then MOVEMENT_TO_BRANCH_NAME
								when movement_location = 'department' then isnull(movement_to_dept_name, branch_name)
								when movement_location = 'client' then MOVEMENT_TO_CLIENT_NAME
								else movement_to -- enrty , third party
							end																								like '%' + @p_keywords + '%'
						or	movement_to_client_name																			like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													   when 1 then code
													   when 2 then branch_name
													   WHEN 3 THEN movement_to_client_name
													   when 4 then (movement_type + movement_location)
													   when 5 then case
																	   when movement_location = 'entry' then isnull(movement_from, '')
																	   when movement_location = 'branch' then isnull(branch_name, '')
																	   when movement_location = 'department' then isnull(movement_from_dept_name, '')
																	   when movement_location = 'third party' then isnull(branch_name, '')
																	   else isnull(movement_from, '') -- entry , third party
																   end
													   when 6 then case
																	   when movement_location = 'entry' then isnull(movement_to, '')
																	   when movement_location = 'branch' then isnull(movement_to_branch_name, '')
																	   when movement_location = 'department' then isnull(movement_to_dept_name, branch_name)
																	   when movement_location = 'client' then isnull(movement_to_client_name, '')
																	   else isnull(movement_to, '') -- entry , third party  
																   end
													   when 7 then cast(movement_date as sql_variant)
													   when 8 then movement_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then branch_name
													   WHEN 3 THEN movement_to_client_name
													   when 4 then (movement_type + movement_location)
													   when 5 then case
																	   when movement_location = 'entry' then isnull(movement_from, '')
																	   when movement_location = 'branch' then isnull(branch_name, '')
																	   when movement_location = 'department' then isnull(movement_from_dept_name, '')
																	   when movement_location = 'third party' then isnull(branch_name, '')
																	   else isnull(movement_from, '') -- entry , third party
																   end
													   when 6 then case
																	   when movement_location = 'entry' then isnull(movement_to, '')
																	   when movement_location = 'branch' then isnull(movement_to_branch_name, '')
																	   when movement_location = 'department' then isnull(movement_to_dept_name, branch_name)
																	   when movement_location = 'client' then isnull(movement_to_client_name, '')
																	   else isnull(movement_to, '') -- entry , third party  
																   end
													   when 7 then cast(movement_date as sql_variant)
													   when 8 then movement_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
