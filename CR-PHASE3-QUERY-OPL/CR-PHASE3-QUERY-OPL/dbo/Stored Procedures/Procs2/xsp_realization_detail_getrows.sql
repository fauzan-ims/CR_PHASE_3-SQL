CREATE PROCEDURE [dbo].[xsp_realization_detail_getrows]
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_realization_code nvarchar(50)
)
as
begin
	declare		@rows_count int = 0 ;

	select		@rows_count = count(1)
	from		realization_detail rd
				inner join dbo.application_asset aa on (aa.asset_no = rd.asset_no)
				inner join dbo.application_amortization aam on (aam.asset_no = aa.asset_no and aam.installment_no = 1)
	where		rd.realization_code = @p_realization_code
				and (
						rd.asset_no													like '%' + @p_keywords + '%'
						or	aa.asset_name											like '%' + @p_keywords + '%'
						or	aa.asset_year											like '%' + @p_keywords + '%'
						or	aa.asset_condition										like '%' + @p_keywords + '%'
						or	aa.fa_code												like '%' + @p_keywords + '%'
						or	aa.fa_name												like '%' + @p_keywords + '%'
						or	aa.replacement_fa_code									like '%' + @p_keywords + '%'
						or	aa.replacement_fa_name									like '%' + @p_keywords + '%'
						or convert(varchar(30), aa.bast_date,103)					like '%' + @p_keywords + '%'
						or aam.billing_amount										like '%' + @p_keywords + '%'
						or	aa.fa_reff_no_01										like '%' + @p_keywords + '%'
						or	aa.fa_reff_no_02										like '%' + @p_keywords + '%'
						or	aa.fa_reff_no_03										like '%' + @p_keywords + '%'
						or	aa.replacement_fa_reff_no_01							like '%' + @p_keywords + '%'
						or	aa.replacement_fa_reff_no_02							like '%' + @p_keywords + '%'
						or	aa.replacement_fa_reff_no_03							like '%' + @p_keywords + '%'
						or aa.deliver_to_name										like '%' + @p_keywords + '%' 
						or aa.deliver_to_area_no + ' ' + aa.deliver_to_phone_no		like '%' + @p_keywords + '%' 
						or aa.deliver_to_address									like '%' + @p_keywords + '%' 
					)  ;

	select		rd.id
				,rd.asset_no
				,aa.asset_name
				,aa.asset_year
				,aa.asset_condition
				,aa.unit_code
				,aa.fa_code
				,aa.fa_name
				,aam.billing_amount
				,convert(varchar(30), aa.bast_date,103) 'bast_date'
				,aa.fa_reff_no_01
				,aa.fa_reff_no_02
				,aa.fa_reff_no_03
				-- (+) Ari 2023-09-20 ket : add asset gts
				,isnull(aa.replacement_fa_code, '') 'fa_code_gts'
				,isnull(aa.replacement_fa_name,'') 'fa_name_gts'
				,isnull(aa.replacement_fa_reff_no_01, '') 'fa_reff_no_01_gts'
				,isnull(aa.replacement_fa_reff_no_02, '') 'fa_reff_no_02_gts'
				,isnull(aa.replacement_fa_reff_no_03,'') 'fa_reff_no_03_gts'
				,'Name : ' + aa.deliver_to_name 'deliver_to_name'
				,'Phone : ' + aa.deliver_to_area_no + ' ' + aa.deliver_to_phone_no 'deliver_phone_no'
				,'Address : ' + aa.deliver_to_address 'deliver_to_address'
				,@rows_count 'rowcount'
	from		realization_detail rd
				inner join dbo.application_asset aa on (aa.asset_no = rd.asset_no)
				inner join dbo.application_amortization aam on (aam.asset_no = aa.asset_no and aam.installment_no = 1)
	where		rd.realization_code = @p_realization_code
				and (
						rd.asset_no													like '%' + @p_keywords + '%'
						or	aa.asset_name											like '%' + @p_keywords + '%'
						or	aa.asset_year											like '%' + @p_keywords + '%'
						or	aa.asset_condition										like '%' + @p_keywords + '%'
						or	aa.fa_code												like '%' + @p_keywords + '%'
						or	aa.fa_name												like '%' + @p_keywords + '%'
						or	aa.replacement_fa_code									like '%' + @p_keywords + '%'
						or	aa.replacement_fa_name									like '%' + @p_keywords + '%'
						or convert(varchar(30), aa.bast_date,103)					like '%' + @p_keywords + '%'
						or aam.billing_amount										like '%' + @p_keywords + '%'
						or	aa.fa_reff_no_01										like '%' + @p_keywords + '%'
						or	aa.fa_reff_no_02										like '%' + @p_keywords + '%'
						or	aa.fa_reff_no_03										like '%' + @p_keywords + '%'
						or	aa.replacement_fa_reff_no_01							like '%' + @p_keywords + '%'
						or	aa.replacement_fa_reff_no_02							like '%' + @p_keywords + '%'
						or	aa.replacement_fa_reff_no_03							like '%' + @p_keywords + '%'
						or aa.deliver_to_name										like '%' + @p_keywords + '%' 
						or aa.deliver_to_area_no + ' ' + aa.deliver_to_phone_no		like '%' + @p_keywords + '%' 
						or aa.deliver_to_address									like '%' + @p_keywords + '%' 
					) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then rd.asset_no + aa.asset_name
													 when 2 then cast(aa.bast_date as sql_variant)
													 when 3 then aa.asset_year + aa.asset_condition 
													 --when 4 then aa.asset_condition 
													 when 4 then isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01) + isnull(aa.fa_reff_no_02, aa.replacement_fa_reff_no_02) + isnull(aa.fa_reff_no_03,aa.replacement_fa_reff_no_03)
													 when 5 then aa.fa_reff_no_01 + aa.fa_reff_no_02 + aa.fa_reff_no_03
													 when 6 then isnull(aa.replacement_fa_reff_no_01,'') + isnull(aa.replacement_fa_reff_no_02,'') + isnull(aa.replacement_fa_reff_no_03,'')
													 when 7 then aa.replacement_fa_reff_no_01 + aa.replacement_fa_reff_no_02 + aa.replacement_fa_reff_no_03
													 when 8 then cast(aam.billing_amount as sql_variant)
													 when 9 then aa.deliver_to_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then rd.asset_no + aa.asset_name
													 when 2 then cast(aa.bast_date as sql_variant)
													 when 3 then aa.asset_year + aa.asset_condition 
													 --when 4 then aa.asset_condition 
													 when 4 then isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01) + isnull(aa.fa_reff_no_02, aa.replacement_fa_reff_no_02) + isnull(aa.fa_reff_no_03,aa.replacement_fa_reff_no_03)
													 when 5 then aa.fa_reff_no_01 + aa.fa_reff_no_02 + aa.fa_reff_no_03
													 when 6 then isnull(aa.replacement_fa_reff_no_01,'') + isnull(aa.replacement_fa_reff_no_02,'') + isnull(aa.replacement_fa_reff_no_03,'')
													 when 7 then aa.replacement_fa_reff_no_01 + aa.replacement_fa_reff_no_02 + aa.replacement_fa_reff_no_03
													 when 8 then cast(aam.billing_amount as sql_variant)
													 when 9 then aa.deliver_to_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

