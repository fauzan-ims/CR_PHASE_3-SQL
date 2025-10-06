CREATE PROCEDURE dbo.xsp_interface_journal_gl_link_transaction_getrows
(
	@p_keywords			   nvarchar(50)
	,@p_pagenumber		   int
	,@p_rowspage		   int
	,@p_order_by		   int
	,@p_sort_by			   nvarchar(5)
	,@p_transaction_status nvarchar(10)
	,@p_branch_code		   nvarchar(50)
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
	from	OPL_INTERFACE_JOURNAL_GL_LINK_TRANSACTION oijglt
			--left join application_main am on (am.application_no = oijglt.reff_source_no)
			--left join  dm on (dm.drawdown_no		= oijglt.reff_source_no)
		--	left join plafond_main pm on (pm.code				= oijglt.reff_source_no)
	where	oijglt.branch_code			  = case @p_branch_code
												when 'ALL' then oijglt.branch_code
												else @p_branch_code
											end
			and oijglt.transaction_status = case @p_transaction_status
												when 'ALL' then oijglt.transaction_status
												else @p_transaction_status
											end
			and (
					oijglt.code																									 like '%' + @p_keywords + '%'
					or	oijglt.branch_name																						 like '%' + @p_keywords + '%'
					or	oijglt.transaction_status																				 like '%' + @p_keywords + '%'
					or	convert(varchar(30), oijglt.transaction_date, 103)														 like '%' + @p_keywords + '%'
					or	convert(varchar(30), oijglt.transaction_value_date, 103)												 like '%' + @p_keywords + '%'
					or	oijglt.transaction_name																					 like '%' + @p_keywords + '%'
				--	or	isnull(pm.plafond_no, '') + isnull(am.application_external_no, '') + isnull(dm.drawdown_external_no, '') like '%' + @p_keywords + '%'
					or	oijglt.reff_source_name																					 like '%' + @p_keywords + '%'
					or	oijglt.reff_source_no																					 like '%' + @p_keywords + '%'

				) ;

		select		oijglt.id
					,oijglt.code
					,oijglt.branch_name
					,oijglt.transaction_status
					,convert(varchar(30), oijglt.transaction_date, 103) 'transaction_date'
					,convert(varchar(30), oijglt.transaction_value_date, 103) 'transaction_value_date'
					,transaction_name
					,oijglt.reff_source_no
					--,isnull(pm.plafond_no, '') + isnull(am.application_external_no, '') + isnull(dm.drawdown_external_no, '') 'reff_source_no'
					,oijglt.reff_source_name
					,@rows_count 'rowcount'
		from		OPL_INTERFACE_JOURNAL_GL_LINK_TRANSACTION oijglt
					--left join application_main am on (am.application_no = oijglt.reff_source_no)
					--left join drawdown_main dm on (dm.drawdown_no		= oijglt.reff_source_no)
					--left join pl pm on (pm.code				= oijglt.reff_source_no)
		where		oijglt.branch_code			  = case @p_branch_code
														when 'ALL' then oijglt.branch_code
														else @p_branch_code
													end
					and oijglt.transaction_status = case @p_transaction_status
														when 'ALL' then oijglt.transaction_status
														else @p_transaction_status
													end
					and (
							oijglt.code																									 like '%' + @p_keywords + '%'
							or	oijglt.branch_name																						 like '%' + @p_keywords + '%'
							or	oijglt.transaction_status																				 like '%' + @p_keywords + '%'
							or	convert(varchar(30), oijglt.transaction_date, 103)														 like '%' + @p_keywords + '%'
							or	convert(varchar(30), oijglt.transaction_value_date, 103)												 like '%' + @p_keywords + '%'
							or	oijglt.transaction_name																					 like '%' + @p_keywords + '%'
							--or	isnull(pm.plafond_no, '') + isnull(am.application_external_no, '') + isnull(dm.drawdown_external_no, '') like '%' + @p_keywords + '%'
							or	oijglt.reff_source_name																					 like '%' + @p_keywords + '%'
							or	oijglt.reff_source_no																					 like '%' + @p_keywords + '%'
						)

		order by 	case  
						when @p_sort_by = 'asc' then case @p_order_by
														when 1 then oijglt.code
														when 2 then oijglt.branch_name
														when 3 then cast(oijglt.transaction_date as sql_variant)
														when 4 then cast(oijglt.transaction_value_date as sql_variant)
														when 5 then oijglt.transaction_name
													--	when 6 then isnull(pm.plafond_no, '') + isnull(am.application_external_no, '') + isnull(dm.drawdown_external_no, '') + oijglt.reff_source_name
														when 6 then oijglt.reff_source_no
														when 7 then oijglt.transaction_status

						  							end
					end asc 
					,case 
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then oijglt.code
														when 2 then oijglt.branch_name
														when 3 then cast(oijglt.transaction_date as sql_variant)
														when 4 then cast(oijglt.transaction_value_date as sql_variant)
														when 5 then oijglt.transaction_name
													--	when 6 then isnull(pm.plafond_no, '') + isnull(am.application_external_no, '') + isnull(dm.drawdown_external_no, '') + oijglt.reff_source_name
														when 6 then oijglt.reff_source_no
														when 7 then oijglt.transaction_status
						  							end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
