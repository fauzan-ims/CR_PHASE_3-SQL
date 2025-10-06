CREATE PROCEDURE [dbo].[xsp_termination_request_getrows]
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_branch_code	   nvarchar(50)
	,@p_request_status nvarchar(250)
	,@p_insurance_type  nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	termination_request tr
			inner join dbo.insurance_policy_main ipm on (ipm.code	= tr.policy_code)
			inner join dbo.master_insurance mi on (mi.code = ipm.insurance_code)
	where	tr.branch_code		   = case @p_branch_code
											when 'ALL' then tr.branch_code
											else @p_branch_code
										end
			and tr.request_status = case @p_request_status
											when 'ALL' then tr.request_status
											else @p_request_status
										end
			and ipm.insurance_type	= case @p_insurance_type
												when 'ALL' then ipm.insurance_type	
												else @p_insurance_type
									  end
			and (
					tr.branch_name									like '%' + @p_keywords + '%'
					or	request_status								like '%' + @p_keywords + '%' 
					or	convert(varchar(30), tr.request_date, 103)	like '%' + @p_keywords + '%'
					or	tr.request_reff_no							like '%' + @p_keywords + '%'
					or	tr.request_reff_name						like '%' + @p_keywords + '%'
					or	tr.request_status							like '%' + @p_keywords + '%'
					or	insurance_name								like '%' + @p_keywords + '%'
					or	case ipm.insurance_type
							when 'LIFE' then 'LIFE'
							else 'NON LIFE'
						end												like '%' + @p_keywords + '%'
				) ;
	
		select		 tr.code
					,tr.branch_name
					,tr.request_status 		
					,convert(varchar(30), tr.request_date, 103) 'request_date'
					,tr.request_reff_no
					,tr.request_reff_name
					,request_status
					,insurance_name
					,ipm.insurance_type
					,@rows_count 'rowcount'
		from	termination_request tr
				inner join dbo.insurance_policy_main ipm on (ipm.code	= tr.policy_code)
				inner join dbo.master_insurance mi ON (mi.code = ipm.insurance_code)
		where	tr.branch_code		   = case @p_branch_code
												when 'ALL' then tr.branch_code
												else @p_branch_code
											end
				and tr.request_status = case @p_request_status
												when 'ALL' then tr.request_status
												else @p_request_status
											end
				and ipm.insurance_type	= case @p_insurance_type
													when 'ALL' then ipm.insurance_type	
													else @p_insurance_type
										  end
				and (
						tr.branch_name									like '%' + @p_keywords + '%'
						or	request_status								like '%' + @p_keywords + '%' 
						or	convert(varchar(30), tr.request_date, 103)	like '%' + @p_keywords + '%'
						or	tr.request_reff_no							like '%' + @p_keywords + '%'
						or	tr.request_reff_name						like '%' + @p_keywords + '%'
						or	tr.request_status							like '%' + @p_keywords + '%'
						or	insurance_name								like '%' + @p_keywords + '%'
						or	case ipm.insurance_type
								when 'LIFE' then 'LIFE'
								else 'NON LIFE'
							end												like '%' + @p_keywords + '%'
					) 
		order by case when @p_sort_by = 'asc' then case @p_order_by
													when 1 then tr.branch_name					 
													when 2 then insurance_name + ipm.insurance_type
													when 3 then cast(tr.request_date as sql_variant)
													when 4 then tr.request_reff_no + tr.request_reff_name
													when 5 then tr.request_status	
												   end					
					end asc 
					,case when @p_sort_by = 'desc' then case @p_order_by
															when 1 then tr.branch_name					 
															when 2 then insurance_name + ipm.insurance_type
															when 3 then cast(tr.request_date as sql_variant)
															when 4 then tr.request_reff_no + tr.request_reff_name
															when 5 then tr.request_status	
													   end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;

