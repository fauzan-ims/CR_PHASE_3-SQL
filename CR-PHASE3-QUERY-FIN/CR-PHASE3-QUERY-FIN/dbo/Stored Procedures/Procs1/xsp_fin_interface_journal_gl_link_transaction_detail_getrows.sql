CREATE PROCEDURE dbo.xsp_fin_interface_journal_gl_link_transaction_detail_getrows
(
	@p_keywords						nvarchar(50)
	,@p_pagenumber					int
	,@p_rowspage					int
	,@p_order_by					int
	,@p_sort_by						nvarchar(5)
	,@p_gl_link_transaction_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	fin_interface_journal_gl_link_transaction_detail jtd
			left join dbo.journal_gl_link  jgl on (jgl.code = jtd.gl_link_code)
			left join dbo.agreement_main am on (am.agreement_no = jtd.agreement_no)
	where	jtd.gl_link_transaction_code = @p_gl_link_transaction_code
			and	(
					jtd.branch_name					like '%' + @p_keywords + '%'
					or	jgl.gl_link_name			like '%' + @p_keywords + '%'
					--or	am.agreement_external_no	like '%' + @p_keywords + '%'
					or	am.client_name				like '%' + @p_keywords + '%'
					or	orig_currency_code			like '%' + @p_keywords + '%'
					or	jtd.base_amount_cr			like '%' + @p_keywords + '%'
					or	jtd.base_amount_db			like '%' + @p_keywords + '%'
					or	jtd.orig_amount_cr			like '%' + @p_keywords + '%'
					or	jtd.orig_amount_db			like '%' + @p_keywords + '%'
					or	jtd.exch_rate				like '%' + @p_keywords + '%'
					or	division_name				like '%' + @p_keywords + '%'
					or	department_name				like '%' + @p_keywords + '%'
					or	jtd.remarks					like '%' + @p_keywords + '%'
					or	jtd.AGREEMENT_NO			like '%' + @p_keywords + '%'
				) ;

		select		id
					,jtd.branch_name
					,isnull(jgl.gl_link_name ,jtd.gl_link_code) 'gl_link_name'
					,jtd.remarks
					--,am.agreement_external_no
					,am.client_name
					,orig_currency_code
					,jtd.base_amount_db
					,jtd.base_amount_cr
					,jtd.orig_amount_db
					,jtd.orig_amount_cr
					,jtd.exch_rate
					,division_name
					,department_name
					,jtd.agreement_no 'agreement_external_no'
					,@rows_count 'rowcount'
		from		fin_interface_journal_gl_link_transaction_detail jtd
					left join dbo.journal_gl_link  jgl on (jgl.code = jtd.gl_link_code)
					left join dbo.agreement_main am on (am.agreement_no = jtd.agreement_no)
		where		jtd.gl_link_transaction_code = @p_gl_link_transaction_code
					and	(
							jtd.branch_name					like '%' + @p_keywords + '%'
							or	jgl.gl_link_name			like '%' + @p_keywords + '%'
							--or	am.agreement_external_no	like '%' + @p_keywords + '%'
							or	jtd.AGREEMENT_NO			like '%' + @p_keywords + '%'
							or	am.client_name				like '%' + @p_keywords + '%'
							or	orig_currency_code			like '%' + @p_keywords + '%'
							or	jtd.base_amount_cr			like '%' + @p_keywords + '%'
							or	jtd.base_amount_db			like '%' + @p_keywords + '%'
							or	jtd.orig_amount_cr			like '%' + @p_keywords + '%'
							or	jtd.orig_amount_db			like '%' + @p_keywords + '%'
							or	jtd.exch_rate				like '%' + @p_keywords + '%'
							or	division_name				like '%' + @p_keywords + '%'
							or	department_name				like '%' + @p_keywords + '%'
							or	jtd.remarks					like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then jtd.branch_name
														when 2 then jgl.gl_link_name
														when 3 then jtd.remarks
														when 4 then jtd.agreement_no--am.agreement_external_no
														when 5 then jtd.orig_currency_code
														when 6 then cast(jtd.base_amount_db as sql_variant)
														when 7 then cast(jtd.base_amount_cr as sql_variant)
														when 8 then jtd.division_name
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then jtd.branch_name
														when 2 then jgl.gl_link_name
														when 3 then jtd.remarks
														when 4 then jtd.agreement_no--am.agreement_external_no
														when 5 then jtd.orig_currency_code
														when 6 then cast(jtd.base_amount_db as sql_variant)
														when 7 then cast(jtd.base_amount_cr as sql_variant)
														when 8 then jtd.division_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
