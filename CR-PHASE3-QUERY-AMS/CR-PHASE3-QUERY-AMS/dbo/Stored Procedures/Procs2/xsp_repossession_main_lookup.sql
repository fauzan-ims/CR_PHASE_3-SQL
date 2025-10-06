create PROCEDURE dbo.xsp_repossession_main_lookup
(
	@p_keywords						nvarchar(50)
	,@p_pagenumber					int
	,@p_rowspage					int
	,@p_order_by					int
	,@p_sort_by						nvarchar(5)
	,@p_branch_code					nvarchar(50)
	,@p_repossession_status			nvarchar(10)
	,@p_repossession_process_status nvarchar(10)
	,@p_exit_status					nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	repossession_main rmn
			left join dbo.agreement_main amn on (amn.agreement_no		 = rmn.agreement_no)
			left join dbo.agreement_collateral acl on (acl.collateral_no = rmn.collateral_no)
	where	rmn.repossession_status				= @p_repossession_status
			and rmn.branch_code					= @p_branch_code
			and rmn.repossession_status_process	= @p_repossession_process_status
			and rmn.exit_status					= @p_exit_status
			and	(
					rmn.code												like '%' + @p_keywords + '%'
					or	amn.agreement_external_no							like '%' + @p_keywords + '%'
					or	amn.client_name										like '%' + @p_keywords + '%'
					or	convert(varchar(30), rmn.estimate_repoii_date, 103)	like '%' + @p_keywords + '%'
					or	acl.collateral_external_no							like '%' + @p_keywords + '%'
					or	acl.collateral_name									like '%' + @p_keywords + '%'
					or	rmn.extension_count									like '%' + @p_keywords + '%'
				) ;

		select		rmn.code
					,amn.agreement_external_no		
					,amn.agreement_no		
					,amn.client_name					
					,convert(varchar(30), rmn.estimate_repoii_date, 103) 'estimate_repoii_date'
					,acl.collateral_external_no
					,acl.collateral_name
					,rmn.extension_count				
					,@rows_count 'rowcount'
		from		repossession_main rmn
					left join dbo.agreement_main amn on (amn.agreement_no		 = rmn.agreement_no)
					left join dbo.agreement_collateral acl on (acl.collateral_no = rmn.collateral_no)
		where		rmn.repossession_status				= @p_repossession_status
					and rmn.branch_code					= @p_branch_code
					and rmn.repossession_status_process	= @p_repossession_process_status
					and rmn.exit_status					= @p_exit_status
					and	(
							rmn.code												like '%' + @p_keywords + '%'
							or	amn.agreement_external_no							like '%' + @p_keywords + '%'
							or	amn.client_name										like '%' + @p_keywords + '%'
							or	convert(varchar(30), rmn.estimate_repoii_date, 103)	like '%' + @p_keywords + '%'
							or	acl.collateral_external_no							like '%' + @p_keywords + '%'
							or	acl.collateral_name									like '%' + @p_keywords + '%'
							or	rmn.extension_count									like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then rmn.code
													 when 2 then amn.agreement_external_no
													 when 3 then cast(rmn.estimate_repoii_date as sql_variant)
													 when 4 then amn.client_name
													 when 5 then acl.collateral_name	
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then rmn.code
													   when 2 then amn.agreement_external_no
													   when 3 then cast(rmn.estimate_repoii_date as sql_variant)
													   when 4 then amn.client_name
													   when 5 then acl.collateral_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
