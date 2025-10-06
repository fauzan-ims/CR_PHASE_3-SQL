CREATE PROCEDURE [dbo].[xsp_et_main_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(20)
	,@p_et_status		nvarchar(10) 
)
as
begin
	declare @rows_count int = 0 ;

	
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)
	begin
		set @p_branch_code = 'ALL'
	END
    
	select	@rows_count = count(1)
	from	et_main em
			inner join dbo.agreement_main am on (am.agreement_no = em.agreement_no)
	where	em.branch_code	 = case @p_branch_code
								   when 'ALL' then em.branch_code
								   else @p_branch_code
							   end
			and em.et_status = case @p_et_status
								   when 'ALL' then em.et_status
								   else @p_et_status
							   end                          
			and (
					em.code										like '%' + @p_keywords + '%'
					or em.branch_name							like '%' + @p_keywords + '%'
					or am.agreement_external_no					like '%' + @p_keywords + '%'
					or am.client_name							like '%' + @p_keywords + '%'
					or convert(varchar(30), em.et_date, 103)	like '%' + @p_keywords + '%'
					or em.et_amount								like '%' + @p_keywords + '%'
					or em.et_status								like '%' + @p_keywords + '%'
				) ;

	select		em.code
				,em.branch_name
				,am.agreement_external_no
				,am.client_name
				,convert(varchar(30), em.et_date, 103) 'et_date'
				,em.et_amount
				,em.et_status
				,@rows_count 'rowcount'
	from		et_main em
				inner join dbo.agreement_main am on (am.agreement_no = em.agreement_no)
	where		em.branch_code	 = case @p_branch_code
										when 'ALL' then em.branch_code
										else @p_branch_code
									end
				and em.et_status = case @p_et_status
										when 'ALL' then em.et_status
										else @p_et_status
									end                          
				and (
						em.code										like '%' + @p_keywords + '%'
						or em.branch_name							like '%' + @p_keywords + '%'
						or am.agreement_external_no					like '%' + @p_keywords + '%'
						or am.client_name							like '%' + @p_keywords + '%'
						or convert(varchar(30), em.et_date, 103)	like '%' + @p_keywords + '%'
						or em.et_amount								like '%' + @p_keywords + '%'
						or em.et_status								like '%' + @p_keywords + '%'
					)
					
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
															when 1 then em.code
															when 2 then em.branch_name
															when 3 then am.agreement_external_no + am.client_name
															when 4 then cast(em.et_date as sql_variant)
															when 5 then cast(em.et_amount as sql_variant)
															when 6 then em.et_status
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
															when 1 then em.code
															when 2 then em.branch_name
															when 3 then am.agreement_external_no + am.client_name
															when 4 then cast(em.et_date as sql_variant)
															when 5 then cast(em.et_amount as sql_variant)
															when 6 then em.et_status
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

