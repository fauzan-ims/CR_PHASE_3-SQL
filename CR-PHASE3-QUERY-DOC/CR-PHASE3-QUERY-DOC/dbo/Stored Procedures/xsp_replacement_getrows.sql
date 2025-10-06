CREATE PROCEDURE dbo.xsp_replacement_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
	,@p_status		nvarchar(10)
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
	from	replacement rpl
	left join dbo.replacement_request rr on (rr.replacement_code = rpl.code)
			outer apply
	(
		select	count(1) 'total_asset'
		from	dbo.replacement_detail rpd
		where	rpd.replacement_code = rpl.code
	) rpd
	where		rpl.branch_code = case @p_branch_code
									  when 'ALL' then rpl.branch_code
									  else @p_branch_code
								  end
				and rpl.status		= case @p_status
									  when 'ALL' then rpl.status
									  else @p_status
								  end
				and (
						rpl.cover_note_no   + rr.vendor_name 						LIKE '%' + @p_keywords + '%'
						or	rpl.branch_name											like '%' + @p_keywords + '%'
						or	convert(varchar(30), rpl.replacement_date, 103)			like '%' + @p_keywords + '%'
						or	convert(varchar(30), rpl.cover_note_date, 103)			like '%' + @p_keywords + '%'
						or	convert(varchar(30), rpl.cover_note_exp_date, 103)		like '%' + @p_keywords + '%'
						or	rpl.type												LIKE '%' + @p_keywords + '%'
						OR	rpl.status												LIKE '%' + @p_keywords + '%'
						OR	rpd.total_asset											LIKE '%' + @p_keywords + '%'
					)

	SELECT		rpl.code
				,rpl.branch_code
				,rpl.branch_name
				,CONVERT(VARCHAR(30), rpl.replacement_date, 103) 'date'
				,rpl.status
				,rpl.type
				,rr.vendor_name + ' - ' + rpl.cover_note_no  'cover_note_no'
				,CONVERT(VARCHAR(30), rpl.cover_note_date, 103) 'cover_note_date'
				,CONVERT(VARCHAR(30), rpl.cover_note_exp_date, 103) 'cover_note_exp_date'
				,rpl.new_cover_note_no
				,CONVERT(VARCHAR(30), rpl.new_cover_note_date, 103) 'new_cover_note_date'
				,CONVERT(VARCHAR(30), rpl.new_cover_note_exp_date, 103) 'new_cover_note_exp_date'
				,rpl.file_name
				,rpl.paths
				,rpl.remarks
				,rpd.total_asset
				,@rows_count 'rowcount'
	FROM		replacement rpl
	left join dbo.replacement_request rr on (rr.replacement_code = rpl.code)
				outer apply
	(
		select	count(1) 'total_asset'
		from	dbo.replacement_detail rpd
		where	rpd.replacement_code = rpl.code
	) rpd
	where		rpl.branch_code = case @p_branch_code
									  when 'ALL' then rpl.branch_code
									  else @p_branch_code
								  end
				and rpl.status		= case @p_status
									  when 'ALL' then rpl.status
									  else @p_status
								  end
				and (
						rpl.cover_note_no + rr.vendor_name 							LIKE '%' + @p_keywords + '%'
						or	rpl.branch_name											like '%' + @p_keywords + '%'
						or	convert(varchar(30), rpl.replacement_date, 103)			like '%' + @p_keywords + '%'
						or	convert(varchar(30), rpl.cover_note_date, 103)			like '%' + @p_keywords + '%'
						or	convert(varchar(30), rpl.cover_note_exp_date, 103)		like '%' + @p_keywords + '%'
						or	rpl.type												like '%' + @p_keywords + '%'
						or	rpl.status												like '%' + @p_keywords + '%'
						or	rpd.total_asset											like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													   when 1 then rpl.branch_name
													   when 2 then cast(rpl.replacement_date as sql_variant)
													   when 3 then rpl.cover_note_no + rr.vendor_name
													   when 4 then cast(rpl.cover_note_date as sql_variant)
													   when 5 then cast(rpl.cover_note_exp_date as sql_variant)
													   when 6 then rpl.type	
													   when 7 then rpd.total_asset	
													   when 8 then rpl.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then rpl.branch_name
													   when 2 then cast(rpl.replacement_date as sql_variant)
													   when 3 then rpl.cover_note_no + rr.vendor_name
													   when 4 then cast(rpl.cover_note_date as sql_variant)
													   when 5 then cast(rpl.cover_note_exp_date as sql_variant)
													   when 6 then rpl.type	
													   when 7 then rpd.total_asset	
													   when 8 then rpl.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
