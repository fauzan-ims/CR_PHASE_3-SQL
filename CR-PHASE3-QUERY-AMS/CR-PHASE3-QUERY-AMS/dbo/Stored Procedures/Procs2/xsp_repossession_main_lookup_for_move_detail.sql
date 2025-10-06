create PROCEDURE dbo.xsp_repossession_main_lookup_for_move_detail
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_repossession_move_code	nvarchar(50)
	,@p_branch_code				nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	repossession_main rmn
			left join dbo.agreement_main amn on (amn.agreement_no		 = rmn.agreement_no)
			left join dbo.agreement_collateral acl on (acl.collateral_no = rmn.collateral_no)
			left join dbo.master_warehouse mwe on (mwe.code = rmn.warehouse_code)
	where	rmn.exit_date is null
			and (rmn.repossession_status_process <> 'MOVE POOL' and rmn.repossession_status_process <> 'SOLD' and rmn.repossession_status_process <> 'BACK TO CURRENT')
			and rmn.exit_status = ''
			and rmn.warehouse_code is not null
			and rmn.branch_code = @p_branch_code
			and rmn.code not in
			(
					select	repossessition_code
					from	dbo.repossession_move_detail rmd
					where	rmd.repossessition_code			= rmn.code
							and rmd.repossession_move_code  = @p_repossession_move_code
			)
			and	(
					rmn.code								like '%' + @p_keywords + '%'
					or	amn.agreement_external_no			like '%' + @p_keywords + '%'
					or	amn.client_name						like '%' + @p_keywords + '%'
					or	acl.collateral_external_no			like '%' + @p_keywords + '%'
					or	acl.collateral_name					like '%' + @p_keywords + '%'
					or	rmn.warehouse_code					like '%' + @p_keywords + '%'
					or	mwe.warehouse_name					like '%' + @p_keywords + '%'
				) ;

		select		rmn.code
					,amn.agreement_external_no		
					,amn.client_name					
					,acl.collateral_external_no		
					,acl.collateral_name
					,rmn.warehouse_code
					,mwe.warehouse_name			
					,@rows_count 'rowcount'
		from		repossession_main rmn
					left join dbo.agreement_main amn on (amn.agreement_no		 = rmn.agreement_no)
					left join dbo.agreement_collateral acl on (acl.collateral_no = rmn.collateral_no)
					left join dbo.master_warehouse mwe on (mwe.code = rmn.warehouse_code)
		where		rmn.exit_date is null
					and (rmn.repossession_status_process <> 'MOVE POOL' and rmn.repossession_status_process <> 'SOLD' and rmn.repossession_status_process <> 'BACK TO CURRENT')
					and rmn.exit_status = ''
					and rmn.warehouse_code is not null
					and rmn.branch_code = @p_branch_code
					and rmn.code not in
					(
							select	repossessition_code
							from	dbo.repossession_move_detail rmd
							where	rmd.repossessition_code			= rmn.code
									and rmd.repossession_move_code  = @p_repossession_move_code
					)
					and	(
							rmn.code								like '%' + @p_keywords + '%'
							or	amn.agreement_external_no			like '%' + @p_keywords + '%'
							or	amn.client_name						like '%' + @p_keywords + '%'
							or	acl.collateral_external_no			like '%' + @p_keywords + '%'
							or	acl.collateral_name					like '%' + @p_keywords + '%'
							or	rmn.warehouse_code					like '%' + @p_keywords + '%'
							or	mwe.warehouse_name					like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then rmn.code
													 when 2 then amn.agreement_external_no
													 when 3 then acl.collateral_external_no
													 when 4 then rmn.warehouse_code
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then rmn.code
													   when 2 then amn.agreement_external_no
													   when 3 then acl.collateral_external_no
													   when 4 then rmn.warehouse_code
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
