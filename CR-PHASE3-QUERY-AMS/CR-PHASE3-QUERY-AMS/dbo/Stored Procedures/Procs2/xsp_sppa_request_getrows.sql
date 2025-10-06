CREATE PROCEDURE dbo.xsp_sppa_request_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_insurance_code	nvarchar(50)
	,@p_register_status nvarchar(10)
	--,@p_from_date		datetime
	--,@p_to_date			datetime
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
	from	sppa_request sr
			inner join dbo.insurance_register ir on (ir.code = sr.register_code)
			--inner join dbo.asset ass on (ass.code			 = ir.fa_code)
			inner join dbo.master_insurance mi on (mi.code	 = ir.insurance_code)
	where	ir.branch_code		   = case @p_branch_code
										 when 'ALL' then ir.branch_code
										 else @p_branch_code
									 end
			and sr.register_status = case @p_register_status
										 when 'ALL' then sr.register_status
										 else @p_register_status
									 end
			and ir.insurance_code  = case @p_insurance_code
										 when 'ALL' then ir.insurance_code
										 else @p_insurance_code
									 end
			--and cast(ir.from_date as date)
			--between cast(@p_from_date as date) and cast(@p_to_date as date)
			and (
					sr.code									    like '%' + @p_keywords + '%'
					or ir.branch_name						    like '%' + @p_keywords + '%'
					or	case ir.insurance_type
							when 'LIFE' then 'LIFE'
							when 'CREDIT' then 'CREDIT'
							else 'COLLATERAL'
						end										like '%' + @p_keywords + '%'
					or insurance_name						    like '%' + @p_keywords + '%'
					or ir.year_period						    like '%' + @p_keywords + '%'
					or mi.insurance_name						like '%' + @p_keywords + '%'
					or convert(varchar(30), ir.from_date, 103)	like '%' + @p_keywords + '%'
					or convert(varchar(30), ir.to_date, 103)	like '%' + @p_keywords + '%'
					or sr.register_status						like '%' + @p_keywords + '%'
					or ir.policy_code							like '%' + @p_keywords + '%'
					or ir.register_remarks						like '%' + @p_keywords + '%'
					or case ir.register_type
							when 'NEW' then 'NEW POLICY'
							when 'ADDITIONAL' then 'ADDITIONAL ASSET'
						else	ir.register_type
					end						 					like '%' + @p_keywords + '%'
				)

	select		sr.code
				,ir.branch_name
				,case ir.insurance_type
					 when 'LIFE' then 'LIFE'
					 when 'CREDIT' then 'CREDIT'
					 else 'COLLATERAL'
				 end 'insurance_type'
				,ir.year_period
				,sr.register_status
				,insurance_name
				,convert(varchar(30), ir.from_date, 103) 'from_date'
				,convert(varchar(30), ir.to_date, 103) 'to_date'
				,case ir.register_type
						when 'NEW' then 'NEW POLICY'
						when 'ADDITIONAL' then 'ADDITIONAL ASSET'
				else ir.register_type 
				end 'register_type'
				,ir.policy_code
				,ir.register_remarks
				,@rows_count 'rowcount'
	from		sppa_request sr
				inner join dbo.insurance_register ir on (ir.code = sr.register_code)
				inner join dbo.master_insurance mi on (mi.code	 = ir.insurance_code)
	where		ir.branch_code		   = case @p_branch_code
											 when 'ALL' then ir.branch_code
											 else @p_branch_code
										 end
				and sr.register_status = case @p_register_status
											 when 'ALL' then sr.register_status
											 else @p_register_status
										 end
				and ir.insurance_code  = case @p_insurance_code
											 when 'ALL' then ir.insurance_code
											 else @p_insurance_code
										 end
				--and cast(ir.from_date as date)
				--between cast(@p_from_date as date) and cast(@p_to_date as date)
				and (
						sr.code									    like '%' + @p_keywords + '%'
						or ir.branch_name						    like '%' + @p_keywords + '%'
						or	case ir.insurance_type
								when 'LIFE' then 'LIFE'
								when 'CREDIT' then 'CREDIT'
								else 'COLLATERAL'
							end										like '%' + @p_keywords + '%'
						or insurance_name						    like '%' + @p_keywords + '%'
						or ir.year_period						    like '%' + @p_keywords + '%'
						or mi.insurance_name						like '%' + @p_keywords + '%'
						or convert(varchar(30), ir.from_date, 103)	like '%' + @p_keywords + '%'
						or convert(varchar(30), ir.to_date, 103)	like '%' + @p_keywords + '%'
						or sr.register_status						like '%' + @p_keywords + '%'
						or ir.policy_code							like '%' + @p_keywords + '%'
						or ir.register_remarks						like '%' + @p_keywords + '%'
						or case ir.register_type
								when 'NEW' then 'NEW POLICY'
								when 'ADDITIONAL' then 'ADDITIONAL ASSET'
							else	ir.register_type
						end						 					like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ir.code
													 when 2 then ir.branch_name
													 when 3 then ir.insurance_type + mi.insurance_name
													 when 4 then ir.register_type
													 when 5 then cast(ir.year_period as sql_variant)
													 when 6 then ir.register_remarks
													 when 7 then sr.register_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ir.code
													 when 2 then ir.branch_name
													 when 3 then ir.insurance_type + mi.insurance_name
													 when 4 then ir.register_type
													 when 5 then cast(ir.year_period as sql_variant)
													 when 6 then ir.register_remarks
													 when 7 then sr.register_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
