CREATE PROCEDURE [dbo].[xsp_handover_request_getrows]
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
	,@p_status		nvarchar(50)
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
	from	handover_request hr
			left join asset ass on (ass.code = hr.fa_code)
			left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	where	hr.branch_code = case @p_branch_code
								 when 'ALL' then hr.branch_code
								 else @p_branch_code
							 end
			and hr.status  = case @p_status
								 when 'ALL' then hr.status
								 else @p_status
							 end
			and (
					hr.code										like '%' + @p_keywords + '%'
					or	hr.branch_name							like '%' + @p_keywords + '%'
					or	hr.type									like '%' + @p_keywords + '%'
					or	hr.status								like '%' + @p_keywords + '%'
					or	convert(varchar(30),hr.date,103)		like '%' + @p_keywords + '%'
					or	hr.fa_code								like '%' + @p_keywords + '%'
					or	ass.item_name							like '%' + @p_keywords + '%'
					or	hr.remark								like '%' + @p_keywords + '%'
					or	hr.handover_from						like '%' + @p_keywords + '%'
					or	hr.handover_to							like '%' + @p_keywords + '%'
					or	convert(varchar(30),hr.eta_date,103)	like '%' + @p_keywords + '%'
					or	avh.plat_no								like '%' + @p_keywords + '%'
					or	avh.engine_no							like '%' + @p_keywords + '%'
					or	avh.chassis_no							like '%' + @p_keywords + '%'
				) ;

	select		hr.code
				,hr.branch_code
				,hr.branch_name
				,hr.type
				,hr.status
				,convert(varchar(30), hr.date, 103) 'date'
				,convert(varchar(30), hr.eta_date, 103) 'eta_date'
				,hr.handover_from
				,hr.handover_to
				,hr.fa_code
				,hr.remark
				,hr.handover_code
				,ass.item_name 'fa_name'
				,avh.plat_no
				,avh.engine_no
				,avh.chassis_no
				,@rows_count 'rowcount'
	from		handover_request hr
				left join asset ass on (ass.code = hr.fa_code)			
				left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	where		hr.branch_code = case @p_branch_code
									 when 'ALL' then hr.branch_code
									 else @p_branch_code
								 end
				and hr.status  = case @p_status
									 when 'ALL' then hr.status
									 else @p_status
								 end
				and (
						hr.code										like '%' + @p_keywords + '%'
						or	hr.branch_name							like '%' + @p_keywords + '%'
						or	hr.type									like '%' + @p_keywords + '%'
						or	hr.status								like '%' + @p_keywords + '%'
						or	convert(varchar(30),hr.date,103)		like '%' + @p_keywords + '%'
						or	hr.fa_code								like '%' + @p_keywords + '%'
						or	ass.item_name							like '%' + @p_keywords + '%'
						or	hr.remark								like '%' + @p_keywords + '%'
						or	hr.handover_from						like '%' + @p_keywords + '%'
						or	hr.handover_to							like '%' + @p_keywords + '%'
						or	convert(varchar(30),hr.eta_date,103)	like '%' + @p_keywords + '%'
						or	avh.plat_no								like '%' + @p_keywords + '%'
						or	avh.engine_no							like '%' + @p_keywords + '%'
						or	avh.chassis_no							like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then hr.code
													 when 2 then hr.branch_name
													 when 3 then hr.type
													 when 4 then cast(hr.date as sql_variant)
													 when 5 then cast(hr.eta_date as sql_variant)
													 when 6 then hr.handover_from + hr.handover_to
													 when 7 then hr.fa_code + ass.item_name
													 when 8 then hr.status
													 when 9 then hr.remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then hr.code
													   when 2 then hr.branch_name
													   when 3 then hr.type
													   when 4 then cast(hr.date as sql_variant)
													   when 5 then cast(hr.eta_date as sql_variant)
													   when 6 then hr.handover_from + hr.handover_to
													   when 7 then hr.fa_code + ass.item_name
													   when 8 then hr.status
													   when 9 then hr.remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
