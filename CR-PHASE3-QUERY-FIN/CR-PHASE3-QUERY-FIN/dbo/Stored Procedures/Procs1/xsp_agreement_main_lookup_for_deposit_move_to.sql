CREATE PROCEDURE [dbo].[xsp_agreement_main_lookup_for_deposit_move_to]
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_branch_code			nvarchar(50) = 'ALL'
	,@p_client_code			nvarchar(50) = ''
	,@p_currency_code		nvarchar(3)  = ''
	,@p_agreement_no		nvarchar(50)
	,@p_deposit_move_code	nvarchar(50) = ''
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)
	begin
		set @p_branch_code = 'ALL'
	end

	select	@rows_count = count(1)
	FROM	agreement_main am
			-- Louis Senin, 30 Juni 2025 18.10.12 -- 
			left join ifinopl.dbo.agreement_deposit_main iadm on (iadm.agreement_no = am.agreement_no and iadm.deposit_type = 'installment')
			left join ifinopl.dbo.agreement_deposit_main oadm on (oadm.agreement_no = am.agreement_no and oadm.deposit_type = 'other')
			-- Louis Senin, 30 Juni 2025 18.10.15 -- 
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
			--and adm.deposit_amount <> 0
			and am.agreement_no <> @p_agreement_no
			and am.agreement_no not in (select to_agreement_no from dbo.deposit_move_detail where deposit_move_code = @p_deposit_move_code)
			and (
					am.agreement_external_no		    like '%' + @p_keywords + '%'
					or	am.client_name				    like '%' + @p_keywords + '%'
					or	am.currency_code			    like '%' + @p_keywords + '%' 
					or	am.asset_description		    like '%' + @p_keywords + '%'
					or	am.facility_name			    like '%' + @p_keywords + '%'
					or	am.last_paid_installment_no		like '%' + @p_keywords + '%'
					-- Louis Senin, 30 Juni 2025 18.10.12 -- 
					or	isnull(iadm.deposit_amount, 0)	like '%' + @p_keywords + '%'
					or	isnull(oadm.deposit_amount, 0)	like '%' + @p_keywords + '%'
					-- Louis Senin, 30 Juni 2025 18.10.12 -- 
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
					-- Louis Senin, 30 Juni 2025 18.10.12 -- 
					,isnull(iadm.deposit_amount, 0) 'installment_deposit_amount'
					,isnull(oadm.deposit_amount, 0) 'other_deposit_amount'
					-- Louis Senin, 30 Juni 2025 18.10.12 -- 
					,@rows_count 'rowcount'
		from		agreement_main am
					-- Louis Senin, 30 Juni 2025 18.10.12 -- 
					left join ifinopl.dbo.agreement_deposit_main iadm on (iadm.agreement_no = am.agreement_no and iadm.deposit_type = 'installment')
					left join ifinopl.dbo.agreement_deposit_main oadm on (oadm.agreement_no = am.agreement_no and oadm.deposit_type = 'other')
					-- Louis Senin, 30 Juni 2025 18.10.15 -- 
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
									  END
					and am.agreement_no <> @p_agreement_no		
					and am.agreement_no not in (select to_agreement_no from dbo.deposit_move_detail where deposit_move_code = @p_deposit_move_code)		
					and (
							am.agreement_external_no		    like '%' + @p_keywords + '%'
							or	am.client_name				    like '%' + @p_keywords + '%'
							or	am.currency_code			    like '%' + @p_keywords + '%' 
							or	am.asset_description		    like '%' + @p_keywords + '%'
							or	am.facility_name			    like '%' + @p_keywords + '%'
							or	am.last_paid_installment_no		like '%' + @p_keywords + '%'
					-- Louis Senin, 30 Juni 2025 18.10.12 -- 
							or	isnull(iadm.deposit_amount, 0)	like '%' + @p_keywords + '%'
							or	isnull(oadm.deposit_amount, 0)	like '%' + @p_keywords + '%'
					-- Louis Senin, 30 Juni 2025 18.10.12 -- 
						) 
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then am.agreement_external_no
														when 2 then cast(isnull(iadm.deposit_amount, isnull(oadm.deposit_amount, 0)) as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then am.agreement_external_no 
														when 2 then cast(isnull(iadm.deposit_amount, isnull(oadm.deposit_amount, 0)) as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
