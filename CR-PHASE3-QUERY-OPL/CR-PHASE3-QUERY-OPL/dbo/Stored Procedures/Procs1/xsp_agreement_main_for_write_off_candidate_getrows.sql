
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_agreement_main_for_write_off_candidate_getrows]
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
)
as
begin
	declare @rows_count	   int = 0
			,@value_wocinv int ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@value_wocinv = cast(value as int)
	from	dbo.sys_global_param
	where	code = 'WOCINV' ;

	select	@rows_count = count(1)
	from	agreement_main am
			inner join dbo.agreement_information ai with(nolock) on (ai.agreement_no = am.agreement_no)
			outer apply
			(
				select	count(1) 'count_terminate_asset'
				from	dbo.agreement_asset aa  with(nolock)
				where	aa.agreement_no		= am.agreement_no
						and aa.asset_status <> 'TERMINATE'
			) aa
	where	--(ai.ovd_days					 >= @value_wocinv
			--and 
			branch_code				 = case @p_branch_code
											   when 'ALL' then branch_code
											   else @p_branch_code
										   end
			and am.agreement_no not in
				(
					select	agreement_no
					from	dbo.write_off_main wom
					where	wom.wo_status <> 'CANCEL'
				)
			and am.agreement_status		 <> 'TERMINATE'
			and aa.count_terminate_asset > 0--) OR (am.AGREEMENT_EXTERNAL_NO = '0001183/4/08/10/2023')
			and (
					am.branch_name														   like '%' + @p_keywords + '%'
					or	am.agreement_external_no										   like '%' + @p_keywords + '%'
					or	am.client_name													   like '%' + @p_keywords + '%'
					or	convert(varchar(30), am.agreement_date, 103)					   like '%' + @p_keywords + '%'
					or	am.agreement_status												   like '%' + @p_keywords + '%'
					--or	dbo.xfn_agreement_get_ovd_rental_amount(ai.agreement_no, null)	   like '%' + @p_keywords + '%'
					or	ai.ovd_days														   like '%' + @p_keywords + '%'
					--or	dbo.xfn_agreement_get_all_os_principal(am.agreement_no, '', null)  like '%' + @p_keywords + '%'
				) ;

	select		am.agreement_no
				,am.branch_name
				,am.agreement_external_no
				,am.agreement_status
				,convert(varchar(30), am.agreement_date, 103) 'agreement_date'
				,am.client_name
				--,dbo.xfn_agreement_get_ovd_rental_amount(ai.agreement_no, null)
				,0'total_overdue_invoice'
				,ai.ovd_days 'overdue_days'
				--,dbo.xfn_agreement_get_all_os_principal(am.agreement_no, '', null) 
				,0'outstanding_rental'
				,@rows_count 'rowcount'
	from		agreement_main am
				inner join dbo.agreement_information ai  with(nolock) on (ai.agreement_no = am.agreement_no)
				outer apply
				(
					select	count(1) 'count_terminate_asset'
					from	dbo.agreement_asset aa  with(nolock)
					where	aa.agreement_no		= am.agreement_no
							and aa.asset_status <> 'TERMINATE'
				) aa
	where		--(ai.ovd_days				>= @value_wocinv
				--and 
				branch_code			= case @p_branch_code
											  when 'ALL' then branch_code
											  else @p_branch_code
										  end
				and am.agreement_no not in
					(
						select	agreement_no
						from	dbo.write_off_main wom
						where	wom.wo_status <> 'CANCEL'
					)
				--and am.agreement_status <> 'TERMINATE'
				and aa.count_terminate_asset > 0--)  OR (am.AGREEMENT_EXTERNAL_NO = '0001183/4/08/10/2023')
				and (
						am.branch_name														   like '%' + @p_keywords + '%'
						or	am.agreement_external_no										   like '%' + @p_keywords + '%'
						or	am.client_name													   like '%' + @p_keywords + '%'
						or	convert(varchar(30), am.agreement_date, 103)					   like '%' + @p_keywords + '%'
						or	am.agreement_status												   like '%' + @p_keywords + '%'
						--or	dbo.xfn_agreement_get_ovd_rental_amount(ai.agreement_no, null)	   like '%' + @p_keywords + '%'
						or	ai.ovd_days														   like '%' + @p_keywords + '%'
						--or	dbo.xfn_agreement_get_all_os_principal(am.agreement_no, '', null)  like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then am.branch_name
													 when 2 then am.agreement_external_no + am.client_name
													 when 3 then cast(agreement_date as sql_variant)
													 --when 4 then --total_overdue_invoice --cast(dbo.xfn_agreement_get_ovd_rental_amount(ai.agreement_no, null) as sql_variant)
													 --when 5 then outstanding_rental--CAST(dbo.xfn_agreement_get_all_os_principal(am.agreement_no, '', null) as sql_variant)
													 when 6 then cast(ai.ovd_days as sql_variant)
													 when 7 then am.agreement_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then am.branch_name
													   when 2 then am.agreement_external_no + am.client_name
													   when 3 then cast(agreement_date as sql_variant)
													   --when 4 THEN total_overdue_invoice --then cast(dbo.xfn_agreement_get_ovd_rental_amount(ai.agreement_no, null) as sql_variant)
													   --when 5 THEN outstanding_rental --then cast(dbo.xfn_agreement_get_all_os_principal(am.agreement_no, '', null) as sql_variant)
													   when 6 then cast(ai.ovd_days as sql_variant)
													   when 7 then am.agreement_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
