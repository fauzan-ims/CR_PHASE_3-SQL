CREATE PROCEDURE dbo.xsp_write_off_main_lookup_for_write_off_recovery
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_branch_code				nvarchar(20)
)
as
begin

	declare @rows_count int = 0 ; 

	select	@rows_count = count(1)
	from	write_off_main wom
			inner join dbo.agreement_main am on (am.agreement_no = wom.agreement_no)
	where	wom.wo_status			= 'APPROVE' 
	and		wom.branch_code			 = case @p_branch_code
										   when 'ALL' then wom.branch_code
										   else @p_branch_code
									   end
	and		(
				wom.code						like '%' + @p_keywords + '%'
				or	wom.wo_status				like '%' + @p_keywords + '%'
				or	am.agreement_external_no	like '%' + @p_keywords + '%'
				or	am.client_name				like '%' + @p_keywords + '%'
			) ;

	select		wom.code
				,wom.wo_status
				,wom.agreement_no
				,am.agreement_external_no 
				,am.client_name			 
				,@rows_count 'rowcount'
	from		write_off_main wom
				inner join dbo.agreement_main am on (am.agreement_no = wom.agreement_no)
	where		wom.wo_status='APPROVE' 
	and			wom.branch_code			 = case @p_branch_code
										   when 'ALL' then wom.branch_code
										   else @p_branch_code
									   end
	and			(
					wom.code						like '%' + @p_keywords + '%'
					or	wom.wo_status				like '%' + @p_keywords + '%'
					or	am.agreement_external_no	like '%' + @p_keywords + '%'
					or	am.client_name				like '%' + @p_keywords + '%'
				) 
	order by	case
					when @p_sort_by = 'asc'
							then
								case @p_order_by
									when 1 then wom.code
									when 2 then	am.agreement_external_no 
									when 3 then am.client_name
									when 4 then wom.wo_status			
								end 
							end asc,
				 case
					when @p_sort_by = 'desc'
							then
									case @p_order_by
										when 1 then wom.code
										when 2 then	am.agreement_external_no 
										when 3 then am.client_name
										when 4 then wom.wo_status			
									end 
								end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;


end ;

