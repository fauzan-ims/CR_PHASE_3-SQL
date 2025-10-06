CREATE PROCEDURE [dbo].[xsp_maturity_detail_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_code			nvarchar(50)
)
as
begin
	declare @rows_count int = 0 
	,@system_date datetime = dbo.xfn_get_system_date()

	select	@rows_count = count(1)
	from		maturity_detail md
				inner join dbo.maturity m on (m.code = md.maturity_code)
				inner join dbo.agreement_asset aa on (aa.asset_no = md.asset_no)
	where		md.maturity_code = @p_code
				and (
						md.asset_no																				like '%' + @p_keywords + '%'
						or	aa.asset_name																		like '%' + @p_keywords + '%'
						or	md.result																			like '%' + @p_keywords + '%'
						or	md.remark																			like '%' + @p_keywords + '%'
						or	md.additional_periode																like '%' + @p_keywords + '%'
						or	md.additional_periode																like '%' + @p_keywords + '%'
						or	dbo.xfn_agreement_get_os_principal(aa.agreement_no, @system_date, md.asset_no)		like '%' + @p_keywords + '%'
						or	dbo.xfn_agreement_get_ovd_rental_amount(aa.agreement_no, md.asset_no)				like '%' + @p_keywords + '%'
						or	aa.lease_rounded_amount																like '%' + @p_keywords + '%'
						or	isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01)								like '%' + @p_keywords + '%'
						or	isnull(aa.fa_reff_no_02, aa.replacement_fa_reff_no_02)								like '%' + @p_keywords + '%'
						or	isnull(aa.fa_reff_no_03, aa.replacement_fa_reff_no_03)								like '%' + @p_keywords + '%'
						or	convert(nvarchar(15), m.maturity_date, 103)											like '%' + @p_keywords + '%'
					) ;

	select		id
				,dbo.xfn_agreement_get_os_principal(aa.agreement_no, @system_date, md.asset_no) 'outstanding_rental'
				,dbo.xfn_agreement_get_ovd_rental_amount(aa.agreement_no, md.asset_no) 'overdue_invice'
				,md.maturity_code
				,md.asset_no								 
				,aa.asset_name									 
				,md.result
				,md.remark
				,md.additional_periode
				,convert(nvarchar(15), md.pickup_date, 103) 'pickup_date' 
				,convert(nvarchar(15), m.maturity_date, 103) 'maturity_date'
				,aa.lease_rounded_amount 'rental_amount'
				,'Plat No : ' + isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01) 'plat_no' 
				,'Chassis No : '+isnull(aa.fa_reff_no_02, aa.replacement_fa_reff_no_02)	'chassis_no' 
				,'Engine No : '+isnull(aa.fa_reff_no_03, aa.replacement_fa_reff_no_03)  'engine_no'
				,@rows_count 'rowcount'
	from		maturity_detail md
				inner join dbo.maturity m on (m.code = md.maturity_code)
				inner join dbo.agreement_asset aa on (aa.asset_no = md.asset_no)
	where		md.maturity_code = @p_code
				and (
						md.asset_no																				like '%' + @p_keywords + '%'
						or	aa.asset_name																		like '%' + @p_keywords + '%'
						or	md.result																			like '%' + @p_keywords + '%'
						or	md.remark																			like '%' + @p_keywords + '%'
						or	md.additional_periode																like '%' + @p_keywords + '%'
						or	md.additional_periode																like '%' + @p_keywords + '%'
						or	dbo.xfn_agreement_get_os_principal(aa.agreement_no, @system_date, md.asset_no)		like '%' + @p_keywords + '%'
						or	dbo.xfn_agreement_get_ovd_rental_amount(aa.agreement_no, md.asset_no)				like '%' + @p_keywords + '%'
						or	aa.lease_rounded_amount																like '%' + @p_keywords + '%'
						or	isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01)								like '%' + @p_keywords + '%'
						or	isnull(aa.fa_reff_no_02, aa.replacement_fa_reff_no_02)								like '%' + @p_keywords + '%'
						or	isnull(aa.fa_reff_no_03, aa.replacement_fa_reff_no_03)								like '%' + @p_keywords + '%'
						or	convert(nvarchar(15), m.maturity_date, 103)											like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then md.asset_no + aa.asset_name
													 when 2 then cast(m.maturity_date as sql_variant)
													 when 3 then cast(dbo.xfn_agreement_get_ovd_rental_amount(aa.agreement_no, md.asset_no) as sql_variant)
													 when 4 then cast(dbo.xfn_agreement_get_os_principal(aa.agreement_no, @system_date, md.asset_no) as sql_variant)
													 when 5 then cast(aa.lease_rounded_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then md.asset_no + aa.asset_name
													 when 2 then cast(m.maturity_date as sql_variant)
													 when 3 then cast(dbo.xfn_agreement_get_ovd_rental_amount(aa.agreement_no, md.asset_no) as sql_variant)
													 when 4 then cast(dbo.xfn_agreement_get_os_principal(aa.agreement_no, @system_date, md.asset_no) as sql_variant)
													 when 5 then cast(aa.lease_rounded_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
