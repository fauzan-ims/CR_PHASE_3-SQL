CREATE PROCEDURE dbo.xsp_agreement_main_lookup_for_deposit_allocation
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	,@p_branch_code		 nvarchar(50) = 'ALL'
	,@p_client_code		 nvarchar(50) = ''
	,@p_currency_code	 nvarchar(3)  = ''
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	agreement_main am
			inner join ifinopl.dbo.agreement_deposit_main adm on (adm.agreement_no = am.agreement_no)
	where	am.branch_code		= case @p_branch_code
									when 'ALL' then am.branch_code
									else @p_branch_code
							  end
			and am.client_code		= case @p_client_code
									when '' then am.client_code
									else @p_client_code
							  end
			and am.currency_code		= case @p_currency_code
									when '' then am.currency_code
									else @p_currency_code
							  end
			and adm.deposit_amount <> 0
			and (
					am.agreement_external_no		    like '%' + @p_keywords + '%'
					or	am.client_name				    like '%' + @p_keywords + '%'
					or	am.currency_code			    like '%' + @p_keywords + '%'
					or	adm.deposit_amount				like '%' + @p_keywords + '%'
					or	am.asset_description		    like '%' + @p_keywords + '%'
					or	am.facility_name			    like '%' + @p_keywords + '%'
					or	am.last_paid_installment_no		like '%' + @p_keywords + '%'
				) ;

		select		am.agreement_no
					,am.agreement_external_no
					,am.client_name
					,am.currency_code
					,am.client_code
					,am.asset_description
					,am.factoring_type
					,am.facility_name
					,am.last_paid_installment_no
					,adm.deposit_amount
					,@rows_count 'rowcount'
		from		agreement_main am
					inner join ifinopl.dbo.agreement_deposit_main adm on (adm.agreement_no = am.agreement_no)
		where		am.branch_code		= case @p_branch_code
											when 'ALL' then am.branch_code
											else @p_branch_code
									  end
					and am.client_code		= case @p_client_code
											when '' then am.client_code
											else @p_client_code
									  end
					and am.currency_code		= case @p_currency_code
											when '' then am.currency_code
											else @p_currency_code
									  end
					and adm.deposit_amount <> 0
					and (
							am.agreement_external_no		    like '%' + @p_keywords + '%'
							or	am.client_name				    like '%' + @p_keywords + '%'
							or	am.currency_code			    like '%' + @p_keywords + '%'
							or	adm.deposit_amount				like '%' + @p_keywords + '%'
							or	am.asset_description		    like '%' + @p_keywords + '%'
							or	am.facility_name			    like '%' + @p_keywords + '%'
							or	am.last_paid_installment_no		like '%' + @p_keywords + '%'
						) 
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then am.agreement_external_no
														when 2 then cast(adm.deposit_amount as sql_variant)
														when 3 then am.asset_description
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then am.agreement_external_no
														when 2 then cast(adm.deposit_amount as sql_variant)
														when 3 then am.asset_description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
