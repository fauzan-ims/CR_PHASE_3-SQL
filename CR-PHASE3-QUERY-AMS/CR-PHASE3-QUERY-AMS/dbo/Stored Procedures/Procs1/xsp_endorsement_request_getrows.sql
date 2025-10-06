CREATE PROCEDURE [dbo].[xsp_endorsement_request_getrows]
(
	@p_keywords					   nvarchar(50)
	,@p_pagenumber				   int
	,@p_rowspage				   int
	,@p_order_by				   int
	,@p_sort_by					   nvarchar(5)
	,@p_branch_code				   nvarchar(50)
	,@p_endorsement_request_status nvarchar(10)
	,@p_insurance_type			   nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	endorsement_request er
			inner join dbo.insurance_policy_main ipm on (ipm.code		= er.policy_code)
			inner join dbo.master_insurance mi on (mi.code = ipm.insurance_code)
	where	er.branch_code					  = case @p_branch_code
													when 'ALL' then er.branch_code
													else @p_branch_code
												end
			and er.endorsement_request_status = case @p_endorsement_request_status
													when 'ALL' then er.endorsement_request_status
													else @p_endorsement_request_status
												end
			and ipm.insurance_type	= case @p_insurance_type
												when 'ALL' then ipm.insurance_type	
												else @p_insurance_type
									  end
			and (
					er.branch_name													like '%' + @p_keywords + '%'
					or  er.code														like '%' + @p_keywords + '%' 
					or	convert(varchar(30), er.endorsement_request_date, 103)		like '%' + @p_keywords + '%'
					or	case er.endorsement_request_type
							when 'FN' then 'FINANCIAL'
							else 'NON FINANCIAL'
						end															like '%' + @p_keywords + '%'
					or	er.request_reff_no											like '%' + @p_keywords + '%'
					or	er.request_reff_name										like '%' + @p_keywords + '%'
					or	er.endorsement_request_status								like '%' + @p_keywords + '%'
					or	insurance_name												like '%' + @p_keywords + '%'
					or	case ipm.insurance_type	
							when 'LIFE' then 'LIFE'
							else 'NON LIFE'
						end															like '%' + @p_keywords + '%'
				) ;

	
		select		er.code
					,er.branch_name 
					,convert(varchar(30), er.endorsement_request_date, 103) 'endorsement_request_date'
					,case er.endorsement_request_type
						 when 'FN' then 'FINANCIAL'
						 else 'NON FINANCIAL'
					 end 'endorsement_request_type'
					,er.request_reff_no
					,er.request_reff_name
					,er.endorsement_request_status
					,insurance_name
					,case ipm.insurance_type	
						 when 'LIFE' then 'LIFE'
						 else 'NON LIFE'
					 end 'insurance_type'
					,@rows_count 'rowcount'
		from	endorsement_request er
				inner join dbo.insurance_policy_main ipm on (ipm.code		= er.policy_code)
				inner join dbo.master_insurance mi on (mi.code = ipm.insurance_code)
		where	er.branch_code					  = case @p_branch_code
														when 'ALL' then er.branch_code
														else @p_branch_code
													end
				and er.endorsement_request_status = case @p_endorsement_request_status
														when 'ALL' then er.endorsement_request_status
														else @p_endorsement_request_status
													end
				and ipm.insurance_type	= case @p_insurance_type
													when 'ALL' then ipm.insurance_type	
													else @p_insurance_type
										  end
				and (
						er.branch_name													like '%' + @p_keywords + '%'
						or  er.code														like '%' + @p_keywords + '%' 
						or	convert(varchar(30), er.endorsement_request_date, 103)		like '%' + @p_keywords + '%'
						or	case er.endorsement_request_type
								when 'FN' then 'FINANCIAL'
								else 'NON FINANCIAL'
							end															like '%' + @p_keywords + '%'
						or	er.request_reff_no											like '%' + @p_keywords + '%'
						or	er.request_reff_name										like '%' + @p_keywords + '%'
						or	er.endorsement_request_status								like '%' + @p_keywords + '%'
						or	insurance_name												like '%' + @p_keywords + '%'
						or	case ipm.insurance_type	
								when 'LIFE' then 'LIFE'
								else 'NON LIFE'
							end															like '%' + @p_keywords + '%'
					)
		order by case when @p_sort_by = 'asc' then case @p_order_by
													when 1 then er.code
													when 2 then er.branch_name 
													when 3 then insurance_name + ipm.insurance_type	
													when 4 then  cast(er.endorsement_request_date as sql_variant)
													when 5 then er.endorsement_request_type
													when 6 then er.request_reff_no + er.request_reff_name
													when 7 then er.endorsement_request_status
												   end
					end asc 
					,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then er.code
													when 2 then er.branch_name 
													when 3 then insurance_name + ipm.insurance_type	
													when 4 then  cast(er.endorsement_request_date as sql_variant)
													when 5 then er.endorsement_request_type
													when 6 then er.request_reff_no + er.request_reff_name
													when 7 then er.endorsement_request_status
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;

