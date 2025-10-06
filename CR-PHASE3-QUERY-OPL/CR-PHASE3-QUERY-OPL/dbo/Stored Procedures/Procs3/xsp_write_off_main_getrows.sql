CREATE PROCEDURE dbo.xsp_write_off_main_getrows
(
	@p_keywords	    nvarchar(50)
	,@p_pagenumber  int
	,@p_rowspage    int
	,@p_order_by    int
	,@p_sort_by	    nvarchar(5)
	,@p_branch_code nvarchar(50)
	,@p_wo_status   nvarchar(10)
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
	from	write_off_main wom 
	left join dbo.agreement_main am on (am.agreement_no = wom.agreement_no)
	where	wom.branch_code		= case @p_branch_code
										when 'ALL' then wom.branch_code
										else @p_branch_code
									end
	and		wom.wo_status	= case @p_wo_status
									when 'ALL' then wom.wo_status
									else @p_wo_status
								end
	and		(
				wom.code									like '%' + @p_keywords + '%'
				or	wom.branch_name							like '%' + @p_keywords + '%'
				or	am.client_name							like '%' + @p_keywords + '%'
				or	wom.wo_status							like '%' + @p_keywords + '%'
				or	convert(varchar(30), wom.wo_date, 103)	like '%' + @p_keywords + '%'
				or	wom.wo_amount							like '%' + @p_keywords + '%'
				or	am.agreement_external_no				like '%' + @p_keywords + '%'
			);

		select	wom.code
				,wom.branch_name
				,wom.wo_status
				,convert(varchar(30), wom.wo_date, 103) 'wo_date'
				,wom.wo_amount
				,am.agreement_external_no 'agreement_no'
				,am.client_name
				,@rows_count 'rowcount'
		from	write_off_main wom
				left join dbo.agreement_main am on (am.agreement_no = wom.agreement_no)
		where	wom.branch_code		= case @p_branch_code
								when 'ALL' then wom.branch_code
								else @p_branch_code
							end
		and		wom.wo_status	= case @p_wo_status
									when 'ALL' then wom.wo_status
									else @p_wo_status
								end
		and		(
					wom.code									like '%' + @p_keywords + '%'
					or	wom.branch_name							like '%' + @p_keywords + '%'
					or	am.client_name							like '%' + @p_keywords + '%'
					or	wom.wo_status							like '%' + @p_keywords + '%'
					or	convert(varchar(30), wom.wo_date, 103)	like '%' + @p_keywords + '%'
					or	wom.wo_amount							like '%' + @p_keywords + '%'
					or	am.agreement_external_no				like '%' + @p_keywords + '%'
							
				)
		order by	case 
						when @p_sort_by='asc' then
													case @p_order_by
														when 1 then wom.code
														when 2 then wom.branch_name
														when 3 then am.agreement_external_no
														when 4 then am.client_name
														when 5 then cast(wom.wo_date as sql_variant)
														when 6 then cast(wom.wo_amount as sql_variant)
														when 7 then wom.wo_status
													end
					end asc,
					case 
						when @p_sort_by='desc' then
													case @p_order_by
														when 1 then wom.code
														when 2 then wom.branch_name
														when 3 then am.agreement_external_no
														when 4 then am.client_name
														when 5 then cast(wom.wo_date as sql_variant)
														when 6 then cast(wom.wo_amount as sql_variant)
														when 7 then wom.wo_status
													end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	
end ;

