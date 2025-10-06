CREATE PROCEDURE dbo.xsp_sppa_main_getrows
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	,@p_sppa_branch_code nvarchar(50)
	,@p_insurance_code	 nvarchar(50)
	,@p_sppa_status		 nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;

	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_sppa_branch_code)	begin		set @p_sppa_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	sppa_main sm
			inner join master_insurance mi on (mi.code = sm.insurance_code)
	where	sm.sppa_branch_code	  = case @p_sppa_branch_code
										when 'ALL' then sm.sppa_branch_code
										else @p_sppa_branch_code
									end
			and sm.insurance_code = case @p_insurance_code
										when 'ALL' then sm.insurance_code
										when '' then sm.insurance_code
										else @p_insurance_code
									end
			and sm.sppa_status	  = case @p_sppa_status
										when 'ALL' then sm.sppa_status
										else @p_sppa_status
									end
			and (
					sm.code												like '%' + @p_keywords + '%'
					or	sm.sppa_branch_name								like '%' + @p_keywords + '%'
					or	sm.sppa_date									like '%' + @p_keywords + '%'
					or	sm.sppa_status									like '%' + @p_keywords + '%'
					or	sm.sppa_remarks									like '%' + @p_keywords + '%'
					or	case sm.insurance_type
							when 'LIFE' then 'LIFE'
							when 'CREDIT' then 'CREDIT'
							else 'COLLATERAL'
						end												like '%' + @p_keywords + '%'
					or	mi.insurance_name								like '%' + @p_keywords + '%'
					or	convert(varchar(30), sm.sppa_date, 103)			like '%' + @p_keywords + '%'
				) ;

		select		sm.code
					,sm.sppa_branch_name
					,convert(varchar(30), sm.sppa_date, 103) 'sppa_date'
					,sm.sppa_status
					,sm.sppa_remarks
					,mi.insurance_name
					,case sm.insurance_type	
						 when 'LIFE' then 'LIFE'
						 when 'CREDIT' then 'CREDIT'
						 else 'COLLATERAL'
					 end 'insurance_type'
					,@rows_count 'rowcount'
		from		sppa_main sm
					inner join master_insurance mi on (mi.code = sm.insurance_code)
		where		sm.sppa_branch_code	  = case @p_sppa_branch_code
												when 'ALL' then sm.sppa_branch_code
												else @p_sppa_branch_code
											end
					and sm.insurance_code = case @p_insurance_code
												when 'ALL' then sm.insurance_code
												when '' then sm.insurance_code
												else @p_insurance_code
											end
					and sm.sppa_status	  = case @p_sppa_status
												when 'ALL' then sm.sppa_status
												else @p_sppa_status
											end
					and (
							sm.code												like '%' + @p_keywords + '%'
							or	sm.sppa_branch_name								like '%' + @p_keywords + '%'
							or	sm.sppa_date									like '%' + @p_keywords + '%'
							or	sm.sppa_status									like '%' + @p_keywords + '%'
							or	sm.sppa_remarks									like '%' + @p_keywords + '%'
							or	case sm.insurance_type
									when 'LIFE' then 'LIFE'
									when 'CREDIT' then 'CREDIT'
									else 'COLLATERAL'
								end												like '%' + @p_keywords + '%'
							or	mi.insurance_name								like '%' + @p_keywords + '%'
							or	convert(varchar(30), sm.sppa_date, 103)			like '%' + @p_keywords + '%'
						)
		order by case when @p_sort_by = 'asc' then case @p_order_by
													when 1 then sm.code
													when 2 then sm.sppa_branch_name
													when 3 then cast(sm.sppa_date as sql_variant)
													when 4 then mi.insurance_name
													when 5 then sm.sppa_remarks
													when 6 then sm.sppa_status
												   end
					end asc
					,case  when @p_sort_by = 'desc' then case @p_order_by
															when 1 then sm.code
															when 2 then sm.sppa_branch_name
															when 3 then cast(sm.sppa_date as sql_variant)
															when 4 then mi.insurance_name
															when 5 then sm.sppa_remarks
															when 6 then sm.sppa_status
														 end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;

