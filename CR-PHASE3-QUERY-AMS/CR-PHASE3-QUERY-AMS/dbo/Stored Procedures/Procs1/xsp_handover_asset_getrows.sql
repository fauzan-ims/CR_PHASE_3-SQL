CREATE PROCEDURE [dbo].[xsp_handover_asset_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_status			nvarchar(50)
	,@p_type			nvarchar(50)
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
	from	handover_asset has
	left join dbo.asset ass on (has.fa_code = ass.code)
	left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	where	has.branch_code	= case @p_branch_code
								when 'ALL' then has.branch_code
								else @p_branch_code
						  end
	and		has.status = case @p_status
						when 'ALL' then has.status
						else @p_status
					end
	and		has.type = case @p_type
							when 'ALL' then has.type
							else @p_type
						end
	and		(
				has.code											 like '%' + @p_keywords + '%'
				or	has.branch_name									 like '%' + @p_keywords + '%'
				or	has.status										 like '%' + @p_keywords + '%'
				or	convert(varchar(30),transaction_date,103)		 like '%' + @p_keywords + '%'
				or	type											 like '%' + @p_keywords + '%'
				or	has.remark										 like '%' + @p_keywords + '%'
				or	has.reff_code									 like '%' + @p_keywords + '%'
				or	has.fa_code										 like '%' + @p_keywords + '%'
				or	avh.plat_no										 like '%' + @p_keywords + '%'
				or	avh.engine_no									 like '%' + @p_keywords + '%'
				or	avh.chassis_no									 like '%' + @p_keywords + '%'
			) ;

	select		has.code
				,has.branch_code
				,has.branch_name
				,has.status
				,convert(varchar(30),transaction_date,103) 'transaction_date'
				,handover_date
				,case has.type
					when 'REPLACE IN' then ' REPLACE IN / ACTIVE'
					when 'REPLACE OUT' then 'REPLACE OUT / REPLACEMENT'
					when 'RETURN IN' then 'RETURN IN / REPLACEMENT'
					when 'RETURN OUT' then 'RETURN OUT / ACTIVE'
					else has.type
				end 'type'
				,has.remark
				,has.fa_code
				,handover_from
				,handover_to
				,unit_condition
				,reff_code
				,reff_name
				,ass.item_code	'asset_no'
				,ass.item_name	'asset_name'
				,avh.plat_no
				,avh.engine_no
				,avh.chassis_no
				,@rows_count 'rowcount'
	from		handover_asset has
	left join dbo.asset ass on (has.fa_code = ass.code)
	left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	where		has.branch_code	= case @p_branch_code
								when 'ALL' then has.branch_code
								else @p_branch_code
						  end
	and		has.status = case @p_status
						when 'ALL' then has.status
						else @p_status
					end
	and		has.type = case @p_type
							when 'ALL' then has.type
							else @p_type
						end
	and		(
					has.code											 like '%' + @p_keywords + '%'
					or	has.branch_name									 like '%' + @p_keywords + '%'
					or	has.status										 like '%' + @p_keywords + '%'
					or	convert(varchar(30),transaction_date,103)		 like '%' + @p_keywords + '%'
					or	type											 like '%' + @p_keywords + '%'
					or	has.remark										 like '%' + @p_keywords + '%'
					or	has.reff_code									 like '%' + @p_keywords + '%'
					or	has.fa_code										 like '%' + @p_keywords + '%'
					or	avh.plat_no										 like '%' + @p_keywords + '%'
					or	avh.engine_no									 like '%' + @p_keywords + '%'
					or	avh.chassis_no									 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then has.code
													 when 2 then has.branch_name
													 when 3 then case has.type
																		when 'REPLACE IN' then ' REPLACE IN / ACTIVE'
																		when 'REPLACE OUT' then 'REPLACE OUT / REPLACEMENT'
																		when 'RETURN IN' then 'RETURN IN / REPLACEMENT'
																		when 'RETURN OUT' then 'RETURN OUT / ACTIVE'
																		else has.type
																	end 
													 when 4 then cast(transaction_date as sql_variant)
													 when 5 then has.reff_code + has.reff_name
													 when 6 then has.fa_code
													 when 7 then has.remark
													 when 8 then has.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then has.code
													 when 2 then has.branch_name
													 when 3 then case has.type
																		when 'REPLACE IN' then ' REPLACE IN / ACTIVE'
																		when 'REPLACE OUT' then 'REPLACE OUT / REPLACEMENT'
																		when 'RETURN IN' then 'RETURN IN / REPLACEMENT'
																		when 'RETURN OUT' then 'RETURN OUT / ACTIVE'
																		else has.type
																	end 
													 when 4 then cast(transaction_date as sql_variant)
													 when 5 then has.reff_code + has.reff_name
													 when 6 then has.fa_code
													 when 7 then has.remark
													 when 8 then has.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
