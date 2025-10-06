CREATE PROCEDURE dbo.xsp_billing_generate_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	--
	,@p_status			nvarchar(10)
	,@p_branch_code		nvarchar(50)
	,@p_generate		nvarchar(1)
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
	from	billing_generate bg
			left join agreement_asset aa on (aa.asset_no = bg.asset_no and aa.agreement_no = bg.agreement_no)
			left join dbo.agreement_main am on (am.agreement_no = bg.agreement_no)
	where	status = case @p_status
						  		when 'ALL' then status
						  		else @p_status
						  end
	and		bg.branch_code = case @p_branch_code
								when 'ALL' then bg.branch_code
								else @p_branch_code 
							end
	and		is_eod = @p_generate
	and		(
				code										like '%' + @p_keywords + '%'
				or	bg.branch_name							like '%' + @p_keywords + '%'
				or	convert(varchar(30), date, 103)			like '%' + @p_keywords + '%'
				or	convert(varchar(30), as_off_date, 103)	like '%' + @p_keywords + '%'
				or	bg.remark								like '%' + @p_keywords + '%'
				or	bg.agreement_no							like '%' + @p_keywords + '%'
				or	bg.client_name							like '%' + @p_keywords + '%'
				or	bg.asset_no								like '%' + @p_keywords + '%'
				or	aa.asset_name							like '%' + @p_keywords + '%'
				or	status									like '%' + @p_keywords + '%'
				or	am.agreement_external_no				like '%' + @p_keywords + '%'
			) ;

	select	bg.code
			,bg.branch_name
			,convert(varchar(30), bg.date, 103) 'generate_date'
			,convert(varchar(30), bg.as_off_date, 103) 'as_off_date'
			,bg.remark
			,bg.agreement_no
			,bg.client_no
			,bg.client_name
			,bg.asset_no
			,aa.asset_name
			,bg.status
			,am.agreement_external_no
			,@rows_count 'rowcount'
	from	billing_generate bg
			left join agreement_asset aa on (aa.asset_no = bg.asset_no and aa.agreement_no = bg.agreement_no)
			left join dbo.agreement_main am on (am.agreement_no = bg.agreement_no)
	where	status = case @p_status
						  		when 'ALL' then status
						  		else @p_status
						  end
	and		bg.branch_code = case @p_branch_code
								when 'ALL' then bg.branch_code
								else @p_branch_code 
							end
	and		is_eod = @p_generate
	and		(
				code										like '%' + @p_keywords + '%'
				or	bg.branch_name							like '%' + @p_keywords + '%'
				or	convert(varchar(30), date, 103)			like '%' + @p_keywords + '%'
				or	convert(varchar(30), as_off_date, 103)	like '%' + @p_keywords + '%'
				or	bg.remark								like '%' + @p_keywords + '%'
				or	bg.agreement_no							like '%' + @p_keywords + '%'
				or	bg.client_name							like '%' + @p_keywords + '%'
				or	bg.asset_no								like '%' + @p_keywords + '%'
				or	aa.asset_name							like '%' + @p_keywords + '%'
				or	status									like '%' + @p_keywords + '%'
				or	am.agreement_external_no				like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then bg.branch_name
														when 3 then cast(date as sql_variant)
														when 4 then cast(as_off_date as sql_variant)
														when 5 then case when isnull(bg.client_no, '') = '' then am.agreement_external_no + bg.client_name + aa.asset_no + aa.asset_name else bg.remark end
														when 6 then status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then bg.branch_name
														when 3 then cast(date as sql_variant)
														when 4 then cast(as_off_date as sql_variant)
														when 5 then case when isnull(bg.client_no, '') = '' then am.agreement_external_no + bg.client_name + aa.asset_no + aa.asset_name else bg.remark end
														when 6 then status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
