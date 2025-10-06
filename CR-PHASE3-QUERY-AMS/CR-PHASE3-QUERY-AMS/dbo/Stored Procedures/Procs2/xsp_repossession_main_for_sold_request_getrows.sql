create PROCEDURE dbo.xsp_repossession_main_for_sold_request_getrows
(
	@p_keywords				 nvarchar(50)
	,@p_pagenumber			 int
	,@p_rowspage			 int
	,@p_order_by			 int
	,@p_sort_by				 nvarchar(5)
	,@p_branch_code			 nvarchar(50)
	,@p_repossession_status  nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end
	select	@rows_count = count(1)
	from	repossession_main rmn
			left join dbo.agreement_main amn on (amn.agreement_no		 = rmn.agreement_no)
			left join dbo.agreement_collateral acl on (acl.collateral_no = rmn.collateral_no)
	where	rmn.branch_code	=	case @p_branch_code
									when 'ALL' then rmn.branch_code
									else @p_branch_code
								end
			and rmn.repossession_status		=	case @p_repossession_status
													when 'ALL' then rmn.repossession_status
													else @p_repossession_status
												end
			and rmn.repossession_status <> 'FA'
			and rmn.is_permit_to_sell = 1
			and rmn.exit_date is null
			and rmn.pricing_amount > 0
			and rmn.repossession_status_process = ''
			and	(
					rmn.code										like '%' + @p_keywords + '%'
					or	amn.agreement_external_no					like '%' + @p_keywords + '%'
					or	amn.client_name								like '%' + @p_keywords + '%'
					or	acl.collateral_external_no					like '%' + @p_keywords + '%'
					or	acl.collateral_name							like '%' + @p_keywords + '%'
					or	convert(varchar(30), rmn.repo_i_date, 103)	like '%' + @p_keywords + '%'
					or	rmn.repossession_status						like '%' + @p_keywords + '%'
				) ;

		select		rmn.code
					,amn.agreement_external_no
					,amn.client_name
					,acl.collateral_external_no
					,acl.collateral_name
					,convert(varchar(30), rmn.repo_i_date, 103) 'repo_i_date'
					,rmn.repossession_status					
					,@rows_count 'rowcount'
		from		repossession_main rmn
					left join dbo.agreement_main amn on (amn.agreement_no		 = rmn.agreement_no)
					left join dbo.agreement_collateral acl on (acl.collateral_no = rmn.collateral_no)
		where		rmn.branch_code	=	case @p_branch_code
											when 'ALL' then rmn.branch_code
											else @p_branch_code
										end
					and rmn.repossession_status		=	case @p_repossession_status
															when 'ALL' then rmn.repossession_status
															else @p_repossession_status
														end
					and rmn.repossession_status <> 'FA'
					and rmn.is_permit_to_sell = 1
					and rmn.exit_date is null
					and rmn.pricing_amount > 0
					and rmn.repossession_status_process = ''
					and	(
							rmn.code										like '%' + @p_keywords + '%'
							or	amn.agreement_external_no					like '%' + @p_keywords + '%'
							or	amn.client_name								like '%' + @p_keywords + '%'
							or	acl.collateral_external_no					like '%' + @p_keywords + '%'
							or	acl.collateral_name							like '%' + @p_keywords + '%'
							or	convert(varchar(30), rmn.repo_i_date, 103)	like '%' + @p_keywords + '%'
							or	rmn.repossession_status						like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then rmn.code
													 when 2 then amn.agreement_external_no
													 when 3 then acl.collateral_external_no
													 when 4 then cast(rmn.repo_i_date as sql_variant)
													 when 5 then rmn.repossession_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then rmn.code
													   when 2 then amn.agreement_external_no
													   when 3 then acl.collateral_external_no
													   when 4 then cast(rmn.repo_i_date as sql_variant)
													   when 5 then rmn.repossession_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
