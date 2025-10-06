CREATE PROCEDURE dbo.xsp_deskcoll_staff_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	--
	,@p_agreement_status	nvarchar(50)
	,@p_branch_code			nvarchar(50)
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
	from	dbo.agreement_main am
			inner join dbo.agreement_information ai on (ai.agreement_no = am.agreement_no)
	where	am.agreement_status =	case @p_agreement_status
										when 'ALL' then am.agreement_status 
										else @p_agreement_status
									end	
	and		branch_code = case @p_branch_code
								when 'ALL' then branch_code
								else @p_branch_code 
							end
	and		(
				ai.agreement_no				                    like '%' + @p_keywords + '%'
				or client_name				                    like '%' + @p_keywords + '%'
				or am.agreement_external_no						like '%' + @p_keywords + '%'
				or client_name									like '%' + @p_keywords + '%'
				or am.facility_name								like '%' + @p_keywords + '%'
				or	convert(varchar,cast(ai.installment_amount as money), 1) like '%' + @p_keywords + '%'
				or format(cast(ai.next_due_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')	like '%' + @p_keywords + '%'
				or ai.ovd_days									like '%' + @p_keywords + '%'
				or ai.deskcoll_staff_code						like '%' + @p_keywords + '%'
				or ai.deskcoll_staff_name						like '%' + @p_keywords + '%'
				or am.agreement_status							like '%' + @p_keywords + '%'
				or am.agreement_sub_status						like '%' + @p_keywords + '%'
			) ;

	select	ai.agreement_no
			 ,am.agreement_external_no
			,client_name
			,facility_name
			,installment_amount
			,convert(varchar(30), next_due_date, 103) 'next_due_date'
			,ovd_days
			,deskcoll_staff_code
			,deskcoll_staff_name
			,agreement_status
			,agreement_sub_status
			,am.branch_name
			,@rows_count 'rowcount'
	from	dbo.agreement_main am
			inner join dbo.agreement_information ai on (ai.agreement_no = am.agreement_no)
	where	am.agreement_status =	case @p_agreement_status
										when 'ALL' then am.agreement_status 
										else @p_agreement_status
									end	
	and		branch_code = case @p_branch_code
								when 'ALL' then branch_code
								else @p_branch_code 
							end
	and		(
				ai.agreement_no				                    like '%' + @p_keywords + '%'
				or client_name				                    like '%' + @p_keywords + '%'
				or am.agreement_external_no						like '%' + @p_keywords + '%'
				or client_name									like '%' + @p_keywords + '%'
				or am.facility_name								like '%' + @p_keywords + '%'
				or	convert(varchar,cast(ai.installment_amount as money), 1) like '%' + @p_keywords + '%'
				or format(cast(ai.next_due_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')	like '%' + @p_keywords + '%'
				or ai.ovd_days									like '%' + @p_keywords + '%'
				or ai.deskcoll_staff_code						like '%' + @p_keywords + '%'
				or ai.deskcoll_staff_name						like '%' + @p_keywords + '%'
				or am.agreement_status							like '%' + @p_keywords + '%'
				or am.agreement_sub_status						like '%' + @p_keywords + '%'
			)
	order by	case 
					when @p_sort_by = 'asc' then 
												case @p_order_by
													when 1 then am.agreement_external_no	                    
													when 2 then am.facility_name
													when 3 then ai.installment_amount
													when 4 then cast(ai.next_due_date as sql_variant)
													when 5 then ai.ovd_days
													when 6 then am.agreement_status
													when 7 then am.agreement_sub_status
													when 8 then ai.deskcoll_staff_name
												end
											end asc, 
				case
					when @p_sort_by = 'desc' then 
												case @p_order_by
													when 1 then am.agreement_external_no	                    
													when 2 then am.facility_name
													when 3 then ai.installment_amount
													when 4 then cast(ai.next_due_date as sql_variant)
													when 5 then ai.ovd_days
													when 6 then am.agreement_status
													when 7 then am.agreement_sub_status
													when 8 then ai.deskcoll_staff_name
												end
											end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
