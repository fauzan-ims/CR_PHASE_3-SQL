CREATE PROCEDURE dbo.xsp_interface_journal_gl_link_transaction_detail_getrows
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
	from	OPL_INTERFACE_JOURNAL_GL_LINK_TRANSACTION_DETAIL jtd
			left join dbo.journal_gl_link  jgl on (jgl.code = jtd.gl_link_code)
			left join dbo.agreement_main am on (am.agreement_no = jtd.agreement_no)
	where	jtd.gl_link_transaction_code = @p_gl_link_transaction_code
			and	(
					jtd.branch_name					like '%' + @p_keywords + '%'
					or	jgl.gl_link_name			like '%' + @p_keywords + '%'
					or	am.agreement_external_no	like '%' + @p_keywords + '%'
					or	orig_currency_code			like '%' + @p_keywords + '%'
					or	orig_amount_db				like '%' + @p_keywords + '%'
					or	orig_amount_cr				like '%' + @p_keywords + '%'
					or	division_name				like '%' + @p_keywords + '%'
					or	department_name				like '%' + @p_keywords + '%'
					or	jtd.remarks					like '%' + @p_keywords + '%'
				) ;

		select		id
					,jtd.branch_name
					,jgl.gl_link_name 
					,jtd.remarks
					--,jtd.agreement_no
					,am.agreement_external_no 'agreement_no'
					,orig_currency_code
					,orig_amount_db
					,orig_amount_cr
					,division_name
					,department_name
					,@rows_count 'rowcount'
		from		opl_interface_journal_gl_link_transaction_detail jtd
					left join dbo.journal_gl_link  jgl on (jgl.code = jtd.gl_link_code)
					left join dbo.agreement_main am on (am.agreement_no = jtd.agreement_no)
		where		jtd.gl_link_transaction_code = @p_gl_link_transaction_code
					and	(
							jtd.branch_name					like '%' + @p_keywords + '%'
							or	jgl.gl_link_name			like '%' + @p_keywords + '%'
							or	am.agreement_external_no	like '%' + @p_keywords + '%'
							or	orig_currency_code			like '%' + @p_keywords + '%'
							or	orig_amount_db				like '%' + @p_keywords + '%'
							or	orig_amount_cr				like '%' + @p_keywords + '%'
							or	division_name				like '%' + @p_keywords + '%'
							or	department_name				like '%' + @p_keywords + '%'
							or	jtd.remarks					like '%' + @p_keywords + '%'
						)

		order by 	case  
						when @p_sort_by = 'asc' then case @p_order_by
														when 1 then jtd.branch_name
														when 2 then jgl.gl_link_name
														when 3 then jtd.remarks
														when 4 then am.agreement_external_no
														when 5 then jtd.orig_currency_code
														when 6 then cast(jtd.orig_amount_db as sql_variant)
														when 7 then cast(jtd.orig_amount_cr as sql_variant)
														when 8 then jtd.division_name
						  							end
					end asc 
					,case 
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then jtd.branch_name
														when 2 then jgl.gl_link_name
														when 3 then jtd.remarks
														when 4 then am.agreement_external_no
														when 5 then jtd.orig_currency_code
														when 6 then cast(jtd.orig_amount_db as sql_variant)
														when 7 then cast(jtd.orig_amount_cr as sql_variant)
														when 8 then jtd.division_name
						  							end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
