create PROCEDURE dbo.xsp_doc_interface_agreement_main_getrows
(
	@p_keywords	         nvarchar(50)
	,@p_pagenumber       int
	,@p_rowspage         int
	,@p_order_by         int
	,@p_sort_by	         nvarchar(5)
	,@p_branch_code	     nvarchar(50)
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
	from	doc_interface_agreement_main 
	where	branch_code = case @p_branch_code
								when 'ALL' then branch_code
								else @p_branch_code
						  end
			and  (
				branch_code										    like '%' + @p_keywords + '%'
				or	branch_name									    like '%' + @p_keywords + '%'
				or	agreement_external_no						    like '%' + @p_keywords + '%'
				or	client_name									    like '%' + @p_keywords + '%'
				or	convert(varchar(30), agreement_date, 103)	    like '%' + @p_keywords + '%'
				or	agreement_status							    like '%' + @p_keywords + '%'
				or	convert(varchar(30), termination_date, 103)	    like '%' + @p_keywords + '%'
				or	termination_status							    like '%' + @p_keywords + '%'
				or	asset_description							    like '%' + @p_keywords + '%'
				or	collateral_description						    like '%' + @p_keywords + '%'
			) ;

		select		agreement_external_no
                    ,branch_code
                    ,branch_name
                    ,agreement_date
                    ,agreement_status
                    ,termination_date
                    ,termination_status
                    ,client_name
                    ,asset_description
                    ,collateral_description
					,@rows_count 'rowcount'
		from		doc_interface_agreement_main 
		where		branch_code = case @p_branch_code
										when 'ALL' then branch_code
										else @p_branch_code
								  end
					and (
							branch_code										    like '%' + @p_keywords + '%'
							or	branch_name									    like '%' + @p_keywords + '%'
							or	agreement_external_no						    like '%' + @p_keywords + '%'
							or	client_name									    like '%' + @p_keywords + '%'
							or	convert(varchar(30), agreement_date, 103)	    like '%' + @p_keywords + '%'
							or	agreement_status							    like '%' + @p_keywords + '%'
							or	convert(varchar(30), termination_date, 103)	    like '%' + @p_keywords + '%'
							or	termination_status							    like '%' + @p_keywords + '%'
							or	asset_description							    like '%' + @p_keywords + '%'
							or	collateral_description						    like '%' + @p_keywords + '%'
					)
		order by case	
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then branch_code + branch_name
													when 2 then agreement_external_no + client_name
													when 3 then cast(agreement_date as sql_variant)
													when 4 then cast(termination_date as sql_variant)
													when 5 then termination_status
													when 6 then asset_description
													when 7 then collateral_description
													when 8 then agreement_status
												end
					end asc 
					,case when @p_sort_by = 'desc' then case @p_order_by
															when 1 then branch_code + branch_name
															when 2 then agreement_external_no + client_name
															when 3 then cast(agreement_date as sql_variant)
															when 4 then cast(termination_date as sql_variant)
															when 5 then termination_status
															when 6 then asset_description
															when 7 then collateral_description
															when 8 then agreement_status
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
