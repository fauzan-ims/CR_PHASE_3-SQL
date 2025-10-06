--created by, Rian at 23/05/2023	

CREATE PROCEDURE dbo.xsp_agreement_main_getrows_for_monitoring_gts
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	--
	,@p_marketing_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.agreement_main am with (nolock)
			outer apply
			(
				select	SUM(lease_rounded_amount)'lease_rounded_amount'
				from	dbo.agreement_asset with (nolock)
				where	agreement_no						= am.agreement_no
						and isnull(replacement_fa_code, '') <> ''
			) aas
			outer apply
			(
				select	count(asset_no) 'count_asset_gts'
				from	dbo.agreement_asset with (nolock)
				where	agreement_no	   = am.agreement_no
						and is_request_gts = '1'
						and asset_status = 'RENTED'
			) aaa
			outer apply
			(
				select	count(aps.asset_no) 'unit_ready'
				from	dbo.agreement_asset aas with (nolock)
						inner join dbo.application_asset aps with (nolock) on (aps.asset_no = aas.asset_no)
				where	aas.agreement_no = am.agreement_no
				and		isnull(aps.fa_code, '') <> ''
				and		aps.is_request_gts = '1'
				and		aas.asset_status = 'RENTED'
			) apas
			-- (+) Ari 2023-09-14 ket : add application no
			outer apply
			(
				select	apm.application_external_no 
				from	dbo.application_main apm
				where	apm.application_no = am.application_no
			) apm
	where	aaa.count_asset_gts > 0
			and (
					am.agreement_external_no							like '%' + @p_keywords + '%'
					or	am.client_name									like '%' + @p_keywords + '%'
					or	convert(varchar(30), am.agreement_date, 103)	like '%' + @p_keywords + '%'
					or	am.branch_name									like '%' + @p_keywords + '%'
					or	am.facility_name								like '%' + @p_keywords + '%'
					or	am.currency_code								like '%' + @p_keywords + '%'
					or	aas.lease_rounded_amount						like '%' + @p_keywords + '%'
				) ;

	select	am.agreement_no
			,am.agreement_external_no
			,convert(varchar(30), am.agreement_date, 103) 'agreement_date'
			,am.branch_code
			,am.branch_name
			,am.facility_code
			,am.facility_name
			,am.currency_code
			,aas.lease_rounded_amount
			,am.client_name
			,aaa.count_asset_gts
			,apas.unit_ready
			,apm.application_external_no 'application_no' -- (+) Ari 2023-09-14 ket : add application no
			,@rows_count 'rowcount'
	from	dbo.agreement_main am with (nolock)
			outer apply
			(
				select	sum(lease_rounded_amount) 'lease_rounded_amount'
				from	dbo.agreement_asset with (nolock)
				where	agreement_no						= am.agreement_no
						and isnull(replacement_fa_code, '') <> ''
			) aas
			outer apply
			(
				select	count(asset_no) 'count_asset_gts'
				from	dbo.agreement_asset with (nolock)
				where	agreement_no	   = am.agreement_no
						and is_request_gts = '1'
						and asset_status = 'RENTED'
			) aaa
			outer apply
			(
				select	count(aps.asset_no) 'unit_ready'
				from	dbo.agreement_asset aas with (nolock)
						inner join dbo.application_asset aps with (nolock) on (aps.asset_no = aas.asset_no)
				where	aas.agreement_no = am.agreement_no
				and		isnull(aps.fa_code, '') <> ''
				and		aps.is_request_gts = '1'
				and		aas.asset_status = 'RENTED'
			) apas
			-- (+) Ari 2023-09-14 ket : add application no
			outer apply
			(
				select	apm.application_external_no 
				from	dbo.application_main apm
				where	apm.application_no = am.application_no
			) apm
	where		aaa.count_asset_gts > 0
				and (
						am.agreement_external_no							like '%' + @p_keywords + '%'
						or	am.client_name									like '%' + @p_keywords + '%'
						or	convert(varchar(30), am.agreement_date, 103)	like '%' + @p_keywords + '%'
						or	am.branch_name									like '%' + @p_keywords + '%'
						or	am.facility_name								like '%' + @p_keywords + '%'
						or	am.currency_code								like '%' + @p_keywords + '%'
						or	aas.lease_rounded_amount						like '%' + @p_keywords + '%'
						or	apm.application_external_no						like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then am.agreement_external_no + am.client_name
													 when 2 then apm.application_external_no
													 when 3 then am.branch_name
													 when 4 then cast(am.agreement_date as sql_variant)
													 when 5 then aaa.count_asset_gts
													 when 6 then apas.unit_ready
													 when 7 then am.currency_code
													 --when 7 then aaa.count_asset_gts
													 --when 4 then am.facility_name
													 --when 5 then am.currency_code
													 when 8 then cast(aas.lease_rounded_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then am.agreement_external_no + am.client_name
													   when 2 then apm.application_external_no
													   when 3 then am.branch_name
													   when 4 then cast(am.agreement_date as sql_variant)
													   when 5 then aaa.count_asset_gts
													   when 6 then apas.unit_ready
													   when 7 then am.currency_code
													   --when 7 then aaa.count_asset_gts
													   --when 4 then am.facility_name
													   --when 5 then am.currency_code
													   when 8 then cast(aas.lease_rounded_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
