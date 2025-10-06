--(+) Dicky R, 08/08/2023 
CREATE PROCEDURE [dbo].[xsp_finance_transaction_lookup_report]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50) = ''
)
as
begin

	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	ifinsys.dbo.sys_branch_bank sbb  
			
	where	(
					code						like '%' + @p_keywords + '%'
					or	sbb.bank_branch_name	like '%' + @p_keywords + '%'
					or	sbb.bank_account_no		like '%' + @p_keywords + '%'
				)and sbb.branch_code = case @p_branch_code 
										when 'ALL' then branch_code
										else @p_branch_code
								  end
	select	code 'code'
			,sbb.bank_branch_name 'name'
			,sbb.bank_account_no 'account_no'
			,@rows_count 'rowcount'
	from	ifinsys.dbo.sys_branch_bank sbb  
	where	(
					code						like '%' + @p_keywords + '%'
					or	sbb.bank_branch_name	like '%' + @p_keywords + '%'
					or	sbb.bank_account_no		like '%' + @p_keywords + '%'
				)
				and sbb.branch_code = case @p_branch_code 
										when 'ALL' then branch_code
										else @p_branch_code
								  end
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then sbb.bank_branch_name 
														when 3 then sbb.bank_account_no
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then sbb.bank_branch_name
														when 3 then sbb.bank_account_no
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
