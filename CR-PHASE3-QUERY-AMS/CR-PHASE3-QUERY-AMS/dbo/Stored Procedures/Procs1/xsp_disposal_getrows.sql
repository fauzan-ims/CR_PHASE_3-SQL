CREATE PROCEDURE dbo.xsp_disposal_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	--
	,@p_branch_code		nvarchar(50)
	,@p_status			nvarchar(20)
	,@p_company_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
		and		value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	disposal ds
			left join dbo.sys_general_subcode sgs on (ds.reason_type = sgs.code) and (sgs.company_code = ds.company_code)
	where	ds.branch_code = case @p_branch_code
								 when 'ALL' then ds.branch_code
								 else @p_branch_code
							end
	and		status = case @p_status
						when 'ALL' then status
						else @p_status
					end
	and		ds.company_code = @p_company_code
	and		(
				ds.code											 like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), disposal_date, 103)	 like '%' + @p_keywords + '%'
				or	ds.branch_name								 like '%' + @p_keywords + '%'
				or	reason_type									 like '%' + @p_keywords + '%'
				or	sgs.description								 like '%' + @p_keywords + '%'
				or	status										 like '%' + @p_keywords + '%'
				or	ds.remarks									 like '%' + @p_keywords + '%'
			) ;

	select		ds.code
				,ds.company_code
				,convert(nvarchar(30), disposal_date, 103) 'disposal_date'
				,ds.branch_code
				,ds.branch_name
				,ds.description
				,reason_type
				,sgs.description 'general_subcode_desc'
				,remarks
				,status
				,@rows_count 'rowcount'
	from		disposal ds
				left join dbo.sys_general_subcode sgs on (ds.reason_type = sgs.code) and (sgs.company_code = ds.company_code)
	where		ds.branch_code = case @p_branch_code
								 when 'ALL' then ds.branch_code
								 else @p_branch_code
							end
	and			status = case @p_status
							when 'ALL' then status
							else @p_status
						end
	and			ds.company_code = @p_company_code
	and			(
					ds.code											 like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), disposal_date, 103)	 like '%' + @p_keywords + '%'
					or	ds.branch_name								 like '%' + @p_keywords + '%'
					or	reason_type									 like '%' + @p_keywords + '%'
					or	sgs.description								 like '%' + @p_keywords + '%'
					or	status										 like '%' + @p_keywords + '%'
					or	ds.remarks									 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ds.code
													 when 2 then ds.branch_name
													 when 3 then cast(disposal_date as sql_variant)
													 when 4 then sgs.description
													 when 5 then ds.remarks
													 when 6 then status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													  when 1 then ds.code
													  when 2 then ds.branch_name
													  when 3 then cast(disposal_date as sql_variant)
													  when 4 then sgs.description
													  when 5 then ds.remarks
													  when 6 then status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
