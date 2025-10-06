CREATE PROCEDURE dbo.xsp_fin_interface_agreement_ap_thirdparty_history_getrows
(
	@p_keywords		    nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage	    int
	,@p_order_by	    int
	,@p_sort_by		    nvarchar(5)
	,@p_branch_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	if exists 	(		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code	)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	fin_interface_agreement_ap_thirdparty_history fiaath
			inner join dbo.agreement_main am on (am.agreement_no = fiaath.agreement_no)
	where	fiaath.branch_code = case @p_branch_code
									 when 'ALL' then fiaath.branch_code
									 else @p_branch_code
								 end 
			and(
				fiaath.branch_name											 like '%' + @p_keywords + '%'
				or	reff_code												 like '%' + @p_keywords + '%'
				or	reff_name												 like '%' + @p_keywords + '%'
				or	am.agreement_external_no								 like '%' + @p_keywords + '%'
				or	am.client_name											 like '%' + @p_keywords + '%'
				or	convert(nvarchar(30),transaction_date, 103)				 like '%' + @p_keywords + '%'
				or	orig_amount												 like '%' + @p_keywords + '%'
				or	orig_currency_code										 like '%' + @p_keywords + '%'
				or	exch_rate												 like '%' + @p_keywords + '%'
				or	base_amount												 like '%' + @p_keywords + '%'
				or	source_reff_module										 like '%' + @p_keywords + '%'
				or	source_reff_no											 like '%' + @p_keywords + '%'
				or	source_reff_remarks										 like '%' + @p_keywords + '%'
			) ;

	select		id
				,fiaath.branch_name
				,reff_code
				,reff_name
				,am.agreement_external_no
				,am.client_name			
				,convert(nvarchar(30),transaction_date, 103) 'transaction_date'
				,orig_amount
				,orig_currency_code
				,exch_rate
				,base_amount
				,source_reff_module
				,source_reff_no
				,source_reff_remarks
				,@rows_count 'rowcount'
	from	fin_interface_agreement_ap_thirdparty_history fiaath
			inner join dbo.agreement_main am on (am.agreement_no = fiaath.agreement_no)
	where	fiaath.branch_code = case @p_branch_code
									 when 'ALL' then fiaath.branch_code
									 else @p_branch_code
								 end 
			and(
					fiaath.branch_name									 like '%' + @p_keywords + '%'
					or	reff_code										 like '%' + @p_keywords + '%'
					or	reff_name										 like '%' + @p_keywords + '%'
					or	am.agreement_external_no						 like '%' + @p_keywords + '%'
					or	am.client_name									 like '%' + @p_keywords + '%'
					or	convert(nvarchar(30),transaction_date, 103)		 like '%' + @p_keywords + '%'
					or	orig_amount										 like '%' + @p_keywords + '%'
					or	orig_currency_code								 like '%' + @p_keywords + '%'
					or	exch_rate										 like '%' + @p_keywords + '%'
					or	base_amount										 like '%' + @p_keywords + '%'
					or	source_reff_module								 like '%' + @p_keywords + '%'
					or	source_reff_no									 like '%' + @p_keywords + '%'
					or	source_reff_remarks								 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then fiaath.branch_name
													 when 2 then am.agreement_external_no + am.client_name
													 when 3 then cast(transaction_date as sql_variant)
													 when 4 then reff_code + reff_name
													 when 5 then cast(orig_amount as sql_variant)
													 when 6 then source_reff_module + source_reff_no
													 when 7 then source_reff_remarks
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then fiaath.branch_name
													 when 2 then am.agreement_external_no + am.client_name
													 when 3 then cast(transaction_date as sql_variant)
													 when 4 then reff_code + reff_name
													 when 5 then cast(orig_amount as sql_variant)
													 when 6 then source_reff_module + source_reff_no
													 when 7 then source_reff_remarks
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
