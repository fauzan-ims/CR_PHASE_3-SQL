CREATE PROCEDURE dbo.xsp_termination_main_getrows
(
	@p_keywords			   nvarchar(50)
	,@p_pagenumber		   int
	,@p_rowspage		   int
	,@p_order_by		   int
	,@p_sort_by			   nvarchar(5)
	,@p_branch_code		   nvarchar(50)
	,@p_termination_status nvarchar(10)
	,@p_insurance_type     nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	termination_main tm
			inner join dbo.insurance_policy_main ipm on (ipm.code = tm.policy_code)
			--inner join dbo.asset ass on (ass.code				  = ipm.fa_code)
			inner join dbo.master_insurance mi ON (mi.CODE = ipm.insurance_code)
	where	tm.branch_code			   = case @p_branch_code
											when 'ALL' then tm.branch_code
											else @p_branch_code
										end
			and tm.termination_status = case @p_termination_status
											when 'ALL' then tm.termination_status
											else @p_termination_status
										end
			and ipm.insurance_type	= case @p_insurance_type
												when 'ALL' then ipm.insurance_type	
												else @p_insurance_type
									  end
			and (
					    tm.code											like '%' + @p_keywords + '%'
					or  tm.termination_request_code						like '%' + @p_keywords + '%'
					or  ipm.policy_no									like '%' + @p_keywords + '%'
					or  tm.branch_name									like '%' + @p_keywords + '%'
					or	convert(varchar(30), tm.termination_date, 103)	like '%' + @p_keywords + '%'
					or	tm.termination_approved_amount					like '%' + @p_keywords + '%'
					or	tm.termination_status							like '%' + @p_keywords + '%'
					or	insurance_name									like '%' + @p_keywords + '%'
					or	case ipm.insurance_type	
							when 'LIFE' then 'LIFE'
							when 'CREDIT' then 'CREDIT'
							else 'COLLATERAL'
						end												like '%' + @p_keywords + '%'
					--or ipm.fa_code										like '%' + @p_keywords + '%'
					--or ass.item_name									like '%' + @p_keywords + '%'
				) ;

	
	select		 tm.code
				,tm.termination_request_code	
				,ipm.policy_no
				,tm.branch_name
				,convert(varchar(30), tm.termination_date, 103) 'termination_date'
				,tm.termination_approved_amount
				,tm.termination_status
				,insurance_name
				,case ipm.insurance_type	
						when 'LIFE' then 'LIFE'
						when 'CREDIT' then 'CREDIT'
						else 'COLLATERAL'
					end 'insurance_type'
				--,ipm.fa_code
				--,ass.item_name 'fa_name'
				,@rows_count 'rowcount'
		from	termination_main tm
				inner join dbo.insurance_policy_main ipm on (ipm.code = tm.policy_code)
				--inner join dbo.asset ass on (ass.code				  = ipm.fa_code)
				inner join dbo.master_insurance mi ON (mi.CODE = ipm.insurance_code)
		where	tm.branch_code			   = case @p_branch_code
												when 'ALL' then tm.branch_code
												else @p_branch_code
											end
				and tm.termination_status = case @p_termination_status
												when 'ALL' then tm.termination_status
												else @p_termination_status
											end
				and ipm.insurance_type	= case @p_insurance_type
													when 'ALL' then ipm.insurance_type	
													else @p_insurance_type
										  end
				and (
							tm.code											like '%' + @p_keywords + '%'
						or  tm.termination_request_code						like '%' + @p_keywords + '%'
						or  ipm.policy_no									like '%' + @p_keywords + '%'
						or  tm.branch_name									like '%' + @p_keywords + '%'
						or	convert(varchar(30), tm.termination_date, 103)	like '%' + @p_keywords + '%'
						or	tm.termination_approved_amount					like '%' + @p_keywords + '%'
						or	tm.termination_status							like '%' + @p_keywords + '%'
						or	insurance_name									like '%' + @p_keywords + '%'
						or	case ipm.insurance_type	
								when 'LIFE' then 'LIFE'
								when 'CREDIT' then 'CREDIT'
								else 'COLLATERAL'
							end												like '%' + @p_keywords + '%'
						--or ipm.fa_code										like '%' + @p_keywords + '%'
						--or ass.item_name									like '%' + @p_keywords + '%'
					)
		order by case when @p_sort_by = 'asc' then case @p_order_by
														when 1 then tm.code 
														when 2 then tm.branch_name 
														when 3 then ipm.policy_no 
														when 4 then insurance_name	 
														--when 5 then ipm.fa_code + ass.item_name
														when 5 then cast(tm.termination_date as sql_variant) 
														when 6 then tm.termination_status
												   end
					end asc 
					,case when @p_sort_by = 'desc' then case @p_order_by
															when 1 then tm.code 
															when 2 then tm.branch_name 
															when 3 then ipm.policy_no 
															when 4 then insurance_name	 
															--when 5 then ipm.fa_code + ass.item_name
															when 5 then cast(tm.termination_date as sql_variant) 
															when 6 then tm.termination_status
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;

