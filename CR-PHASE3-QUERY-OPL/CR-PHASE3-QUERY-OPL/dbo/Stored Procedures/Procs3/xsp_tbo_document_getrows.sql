CREATE PROCEDURE dbo.xsp_tbo_document_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	--
	,@p_branch_code nvarchar(50)
	,@p_status		nvarchar(15)
	,@p_transaction_name	NVARCHAR(250)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.tbo_document td
			inner join dbo.application_main am on (am.application_no =  replace(td.application_no,'/','.'))
			inner join dbo.client_main cm on (cm.code				 = am.client_code)
			--left join dbo.realization rz on (rz.application_no		 = am.application_no)
	where	am.branch_code = case @p_branch_code
								 when '1000' then am.branch_code
								 else @p_branch_code
							 end
			and td.status  = case @p_status
								 when 'ALL' then td.status
								 else @p_status
							 END
            and td.transaction_name = CASE @p_transaction_name
									  	when 'ALL' then td.transaction_name
									  	else @p_transaction_name
									  END
			and
			(
				am.application_external_no like '%' + @p_keywords + '%'
				or	cm.client_name like '%' + @p_keywords + '%'
				or	td.agreement_external_no like '%' + @p_keywords + '%'
				or	td.branch_name like '%' + @p_keywords + '%'
				--or	convert(varchar(15), rz.date, 103) like '%' + @p_keywords + '%'
				or	td.status like '%' + @p_keywords + '%'
				or	td.transaction_name like '%' + @p_keywords + '%'
				or	td.transaction_no like '%' + @p_keywords + '%'
				or	convert(varchar(15), td.transaction_date, 103) like '%' + @p_keywords + '%'
				or	convert(varchar(15), td.cre_date, 103) like '%' + @p_keywords + '%'

			) ;

	select		td.id
				,td.branch_code
				,td.branch_name
				,td.application_no
				,td.transaction_name
				,td.transaction_no
				,td.transaction_date
				,convert(varchar(15), td.cre_date, 103)'date'
				,convert(varchar(15), td.transaction_date, 103)'transaction_date'
				,am.application_external_no 
				,cm.client_name
				,td.status
				,@rows_count 'rowcount'
	from		dbo.tbo_document td
				inner join dbo.application_main am on (am.application_no = replace(td.application_no,'/','.'))
				inner join dbo.client_main cm on (cm.code				 = am.client_code)
				--left join dbo.realization rz on (rz.application_no		 = am.application_no)
	where		am.branch_code = case @p_branch_code
									 when '1000' then am.branch_code
									 else @p_branch_code
								 end
				and td.status  = case @p_status
									 when 'ALL' then td.status
									 else @p_status
								 END
                and td.transaction_name =  case @p_transaction_name
									 when 'all' then td.transaction_name
									 else @p_transaction_name
								 end
				and
				(
					am.application_external_no like '%' + @p_keywords + '%'
					or	cm.client_name like '%' + @p_keywords + '%'
					or	td.agreement_external_no like '%' + @p_keywords + '%'
					or	td.branch_name like '%' + @p_keywords + '%'
					--or	convert(varchar(15), rz.date, 103) like '%' + @p_keywords + '%'
					or	td.status like '%' + @p_keywords + '%'
					or	td.transaction_name like '%' + @p_keywords + '%'
					or	td.transaction_no like '%' + @p_keywords + '%'
					or	convert(varchar(15), td.transaction_date, 103) like '%' + @p_keywords + '%'
					or	convert(varchar(15), td.cre_date, 103) like '%' + @p_keywords + '%'

				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													   WHEN 1 then td.branch_name
													   when 2 then CAST(td.cre_date AS sql_variant)  
													   when 3 then cm.client_name
													   WHEN 4 then td.application_no
													   when 5 then td.transaction_name
													   WHEN 6 THEN td.transaction_no
													   WHEN 7 THEN CAST(td.transaction_date AS sql_variant) 
													   WHEN 8 THEN td.STATUS
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    WHEN 1 then td.branch_name
													   when 2 then CAST(td.cre_date AS sql_variant)  
													   when 3 then cm.client_name
													   WHEN 4 then td.application_no
													   when 5 then td.transaction_name
													   WHEN 6 THEN td.transaction_no
													   WHEN 7 THEN CAST(td.transaction_date AS sql_variant) 
													   WHEN 8 THEN td.STATUS
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
