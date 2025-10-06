create procedure dbo.xsp_agreement_main_for_return_asset_getrows
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	,@p_branch_code		 nvarchar(50)
	,@p_agreement_status nvarchar(20)
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
	from	agreement_main
	where	branch_code			 = case @p_branch_code
									   when 'ALL' then branch_code
									   else @p_branch_code
								   end
			and agreement_status = case @p_agreement_status
									   when 'ALL' then agreement_status
									   else @p_agreement_status
								   end
			and (
					agreement_external_no				            like '%' + @p_keywords + '%'
					or	client_name				                    like '%' + @p_keywords + '%'
					or	branch_name				                    like '%' + @p_keywords + '%'
					or	convert(varchar(30), agreement_date, 103)   like '%' + @p_keywords + '%'
					or	agreement_status		                    like '%' + @p_keywords + '%'
					or	agreement_sub_status		                like '%' + @p_keywords + '%'
					or	convert(varchar(30), termination_date, 103)	like '%' + @p_keywords + '%'
					or	termination_status		                    like '%' + @p_keywords + '%'
				) ;

	select		agreement_no
				,agreement_external_no
				,client_name
				,branch_name
				,convert(varchar(30), agreement_date, 103) 'agreement_date'
				,agreement_status
				,agreement_sub_status
				,convert(varchar(30), termination_date, 103) 'termination_date'
				,termination_status
				,@rows_count 'rowcount'
	from		agreement_main
	where		branch_code			 = case @p_branch_code
										   when 'ALL' then branch_code
										   else @p_branch_code
									   end
				and agreement_status = case @p_agreement_status
										   when 'ALL' then agreement_status
										   else @p_agreement_status
									   end
				and (
						agreement_external_no				            like '%' + @p_keywords + '%'
						or	client_name				                    like '%' + @p_keywords + '%'
						or	branch_name				                    like '%' + @p_keywords + '%'
						or	convert(varchar(30), agreement_date, 103)   like '%' + @p_keywords + '%'
						or	agreement_status		                    like '%' + @p_keywords + '%'
						or	agreement_sub_status		                like '%' + @p_keywords + '%'
						or	convert(varchar(30), termination_date, 103)	like '%' + @p_keywords + '%'
						or	termination_status		                    like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then agreement_external_no + client_name
													 when 2 then branch_name
													 when 3 then cast(agreement_date as sql_variant)
													 when 4 then agreement_status
													 when 5 then agreement_sub_status
													 when 6 then cast(termination_date as sql_variant)
													 when 7 then termination_status 
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then agreement_external_no + client_name
													   when 2 then branch_name
													   when 3 then cast(agreement_date as sql_variant)
													   when 4 then agreement_status
													   when 5 then agreement_sub_status
													   when 6 then cast(termination_date as sql_variant)
													   when 7 then termination_status 
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
