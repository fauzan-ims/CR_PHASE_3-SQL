CREATE PROCEDURE dbo.xsp_quotation_review_getrows
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_company_code nvarchar(50)
	,@p_status		 nvarchar(50)
)
as
begin

declare @rowcount	INT

	declare @quotation_review table
	(
		quotation_review_code [nvarchar](50)
	)  

	insert	@quotation_review
	select	distinct quotation_review_code	collate latin1_general_ci_as 'quotation_review_code'
			from	quotation_review_detail d
			where	(spesification		like '%' + @p_keywords + '%'
			or		d.remark			like '%' + @p_keywords + '%')

	union all
    
	select		distinct qr.code collate latin1_general_ci_as			'quotation_review_code'
	from		quotation_review qr
				left join ifinsys.dbo.sys_employee_main em on (em.code = qr.mod_by collate database_default)
	where		qr.status		= case @p_status
										when 'all' then qr.status
										else @p_status
									end
				and
				(
					qr.code													like '%' + @p_keywords + '%'
					or	qr.branch_name										like '%' + @p_keywords + '%'
					or	convert(varchar(30), qr.quotation_review_date, 103)	like '%' + @p_keywords + '%'
					or	qr.remark											like '%' + @p_keywords + '%'
					or	qr.status											like '%' + @p_keywords + '%'
					or	qr.unit_from										like '%' + @p_keywords + '%'
					or	qr.division_name									like '%' + @p_keywords + '%'
					or	qr.department_name									like '%' + @p_keywords + '%'
					or	em.name												like '%' + @p_keywords + '%'
				)

select		@rowcount = count(1)													
from		quotation_review qr 
			inner join ifinsys.dbo.sys_employee_main em on (em.code = qr.mod_by collate database_default)
where		qr.status		= case @p_status
								when 'all' then qr.status
								else @p_status
							end
			and	qr.code in (select quotation_review_code from @quotation_review)

select		qr.code																				
			,qr.company_code																	
			,convert(varchar(30), qr.quotation_review_date, 103) 'quotation_review_date'		
			,convert(varchar(30), qr.expired_date, 103)		  'expired_date'					
			,branch_code																		
			,branch_name																		
			,qr.division_code																	
			,qr.division_name																	
			,qr.department_code																	
			,qr.department_name																	
			,qr.status																			
			,qr.remark																			
			,em.name 'mod_by'																	
			,@rowcount 'rowcount'																		
from		quotation_review qr 
			left join ifinsys.dbo.sys_employee_main em on (em.code = qr.mod_by collate database_default)
where		qr.status		= case @p_status
								when 'all' then qr.status
								else @p_status
							end
			and	qr.code in (select quotation_review_code from @quotation_review)
			order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then qr.code collate latin1_general_ci_as
													 when 2 then qr.branch_name
													 when 3 then cast(qr.quotation_review_date as sql_variant)
													 when 4 then em.name
													 when 5 then qr.remark
													 when 6 then qr.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then qr.code collate latin1_general_ci_as
													 when 2 then qr.branch_name
													 when 3 then cast(qr.quotation_review_date as sql_variant)
													 when 4 then em.name
													 when 5 then qr.remark
													 when 6 then qr.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end ;
