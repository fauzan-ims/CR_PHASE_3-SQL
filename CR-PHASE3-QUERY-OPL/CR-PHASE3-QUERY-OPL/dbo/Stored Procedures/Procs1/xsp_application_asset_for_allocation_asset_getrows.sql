CREATE PROCEDURE dbo.xsp_application_asset_for_allocation_asset_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_application_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_asset aa
			inner join dbo.sys_general_subcode sgs with (nolock) on (sgs.code			  = aa.asset_type_code)
			left join dbo.realization rz with (nolock) on (rz.code					  = aa.realization_code and rz.status = 'POST')
			left join dbo.application_asset_vehicle aav with (nolock) on (aav.asset_no	  = aa.asset_no)
			left join dbo.application_asset_he aah with (nolock) on (aah.asset_no		  = aa.asset_no)
			left join dbo.application_asset_machine aam with (nolock) on (aam.asset_no	  = aa.asset_no)
			left join dbo.application_asset_electronic aae with (nolock) on (aae.asset_no = aa.asset_no)
			left join dbo.master_vehicle_unit mvu with (nolock) on (mvu.code			  = aav.vehicle_unit_code)
			left join dbo.master_he_unit mhu with (nolock) on (mhu.code					  = aah.he_unit_code)
			left join dbo.master_machinery_unit mmu with (nolock) on (mmu.code			  = aam.machinery_unit_code)
			left join dbo.master_electronic_unit meu with (nolock) on (meu.code			  = aae.electronic_unit_code)
	where	aa.application_no = @p_application_no
			and	aa.is_cancel = '0'
			and
			(
				aa.asset_no																						like '%' + @p_keywords + '%'
				or	aa.asset_name																				like '%' + @p_keywords + '%'
				or	aa.asset_year																				like '%' + @p_keywords + '%'
				or	aa.asset_condition																			like '%' + @p_keywords + '%'
				or	aa.fa_code																					like '%' + @p_keywords + '%'
				or	aa.fa_name																					like '%' + @p_keywords + '%'
				or	aa.fa_reff_no_01																			like '%' + @p_keywords + '%'
				or	aa.fa_reff_no_02																			like '%' + @p_keywords + '%'
				or	aa.fa_reff_no_03																			like '%' + @p_keywords + '%'
				or	aa.replacement_fa_code																		like '%' + @p_keywords + '%'
				or	aa.replacement_fa_name																		like '%' + @p_keywords + '%'
				or	aa.replacement_fa_reff_no_01																like '%' + @p_keywords + '%'
				or	aa.replacement_fa_reff_no_02																like '%' + @p_keywords + '%'
				or	aa.replacement_fa_reff_no_03																like '%' + @p_keywords + '%'
				or	rz.agreement_external_no																	like '%' + @p_keywords + '%'
				or	convert(varchar(30), aa.request_delivery_date,103)											like '%' + @p_keywords + '%'
				or	convert(varchar(30), aa.estimate_po_date,103)												like '%' + @p_keywords + '%'
				or	aa.purchase_status																			like '%' + @p_keywords + '%'
				or	aa.lease_rounded_amount																		like '%' + @p_keywords + '%'
				or	isnull(mvu.description, isnull(mhu.description, isnull(mmu.description, meu.description)))	like '%' + @p_keywords + '%'
				or	datediff(day, aa.request_delivery_date,  aa.estimate_po_date)								like '%' + @p_keywords + '%'
				or aa.deliver_to_name																			like '%' + @p_keywords + '%' 
				or aa.deliver_to_area_no + ' ' + aa.deliver_to_phone_no											like '%' + @p_keywords + '%' 
				or aa.deliver_to_address																		like '%' + @p_keywords + '%' 
				or case when aa.asset_type_code = 'VHCL' then aav.transmisi else '' end							like '%' + @p_keywords + '%' 
				or isnull(aav.colour,isnull(aae.colour,isnull(aah.colour, aam.colour)))							like '%' + @p_keywords + '%' 
			) ;

	select		aa.asset_no
				,aa.asset_name
				,sgs.description 'asset_type'
				,aa.asset_year
				,aa.asset_condition
				,case when aa.asset_type_code = 'VHCL' then aav.transmisi else '' end 'transmisi'
				,isnull(aav.colour,isnull(aae.colour,isnull(aah.colour, aam.colour))) 'colour'
				,aa.lease_rounded_amount
				,aa.net_margin_amount
				,aa.purchase_status
				,isnull(mvu.code, isnull(mhu.code, isnull(mmu.code, meu.code))) 'unit_code'
				,isnull(mvu.description, isnull(mhu.description, isnull(mmu.description, meu.description))) 'unit_desc'
				,aa.fa_code
				,aa.fa_name
				,aa.fa_reff_no_01
				,aa.fa_reff_no_02
				,aa.fa_reff_no_03
				,aa.replacement_fa_code
				,aa.replacement_fa_name
				,aa.replacement_fa_reff_no_01
				,aa.replacement_fa_reff_no_02
				,aa.replacement_fa_reff_no_03
				,aa.asset_type_code
				,aa.is_request_gts
				,aa.purchase_gts_status
				,rz.agreement_external_no
				,case
					 when aa.is_request_gts = '1' then '- REQUEST GTS'
					 when aa.is_request_gts = '0' then ''
				 end 'request_gts'
				,convert(varchar(30), aa.request_delivery_date, 103) 'request_delivery_date'
				,convert(varchar(30), aa.estimate_po_date, 103) 'estimate_po_date'
				,datediff(day, aa.request_delivery_date, aa.estimate_po_date) 'aging_day'
				,isnull(aav.vehicle_merk_code, isnull(aae.electronic_merk_code, isnull(aah.he_merk_code, isnull(aam.machinery_merk_code, '')))) 'merk_code'
				,isnull(aav.vehicle_model_code, isnull(aae.electronic_model_code, isnull(aah.he_model_code, isnull(aam.machinery_model_code, '')))) 'model_code'
				,isnull(aav.vehicle_type_code, isnull(aah.he_type_code, isnull(aam.machinery_type_code, ''))) 'type_code'
				,'Name : ' + aa.deliver_to_name 'deliver_to_name'
				,'Phone : ' + aa.deliver_to_area_no + ' ' + aa.deliver_to_phone_no 'deliver_phone_no'
				,'Address : ' + aa.deliver_to_address 'deliver_to_address'
				,aa.unit_source
				,@rows_count 'rowcount'
	from		application_asset aa
				inner join dbo.sys_general_subcode sgs with (nolock) on (sgs.code			  = aa.asset_type_code)
				left join dbo.realization rz with (nolock) on (rz.code						  = aa.realization_code and rz.status = 'POST')
				left join dbo.application_asset_vehicle aav with (nolock) on (aav.asset_no	  = aa.asset_no)
				left join dbo.application_asset_he aah with (nolock) on (aah.asset_no		  = aa.asset_no)
				left join dbo.application_asset_machine aam with (nolock) on (aam.asset_no	  = aa.asset_no)
				left join dbo.application_asset_electronic aae with (nolock) on (aae.asset_no = aa.asset_no)
				left join dbo.master_vehicle_unit mvu with (nolock) on (mvu.code			  = aav.vehicle_unit_code)
				left join dbo.master_he_unit mhu with (nolock) on (mhu.code					  = aah.he_unit_code)
				left join dbo.master_machinery_unit mmu with (nolock) on (mmu.code			  = aam.machinery_unit_code)
				left join dbo.master_electronic_unit meu with (nolock) on (meu.code			  = aae.electronic_unit_code)
	where		aa.application_no = @p_application_no
				and	aa.is_cancel = '0'
				and
				(
					aa.asset_no																						like '%' + @p_keywords + '%'
					or	aa.asset_name																				like '%' + @p_keywords + '%'
					or	aa.asset_year																				like '%' + @p_keywords + '%'
					or	aa.asset_condition																			like '%' + @p_keywords + '%'
					or	aa.fa_code																					like '%' + @p_keywords + '%'
					or	aa.fa_name																					like '%' + @p_keywords + '%'
					or	aa.fa_reff_no_01																			like '%' + @p_keywords + '%'
					or	aa.fa_reff_no_02																			like '%' + @p_keywords + '%'
					or	aa.fa_reff_no_03																			like '%' + @p_keywords + '%'
					or	aa.replacement_fa_code																		like '%' + @p_keywords + '%'
					or	aa.replacement_fa_name																		like '%' + @p_keywords + '%'
					or	aa.replacement_fa_reff_no_01																like '%' + @p_keywords + '%'
					or	aa.replacement_fa_reff_no_02																like '%' + @p_keywords + '%'
					or	aa.replacement_fa_reff_no_03																like '%' + @p_keywords + '%'
					or	rz.agreement_external_no																	like '%' + @p_keywords + '%'
					or	convert(varchar(30), aa.request_delivery_date,103)											like '%' + @p_keywords + '%'
					or	convert(varchar(30), aa.estimate_po_date,103)												like '%' + @p_keywords + '%'
					or	aa.purchase_status																			like '%' + @p_keywords + '%'
					or	aa.lease_rounded_amount																		like '%' + @p_keywords + '%'
					or	isnull(mvu.description, isnull(mhu.description, isnull(mmu.description, meu.description)))	like '%' + @p_keywords + '%'
					or	datediff(day, aa.request_delivery_date,  aa.estimate_po_date)								like '%' + @p_keywords + '%'
					or aa.deliver_to_name																			like '%' + @p_keywords + '%' 
					or aa.deliver_to_area_no + ' ' + aa.deliver_to_phone_no											like '%' + @p_keywords + '%' 
					or aa.deliver_to_address																		like '%' + @p_keywords + '%' 
					or case when aa.asset_type_code = 'VHCL' then aav.transmisi else '' end							like '%' + @p_keywords + '%' 
					or isnull(aav.colour,isnull(aae.colour,isnull(aah.colour, aam.colour)))							like '%' + @p_keywords + '%' 
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then aa.asset_no + aa.asset_name + aa.asset_year + aa.asset_condition
													 when 2 then aa.fa_code + aa.fa_name
													 --when 3 then aa.fa_reff_no_01 + aa.fa_reff_no_02 + aa.fa_reff_no_03
													 when 3 then aa.replacement_fa_code + aa.replacement_fa_name
													 --when 5 then aa.replacement_fa_reff_no_01 + aa.replacement_fa_reff_no_02 + aa.replacement_fa_reff_no_03
													 when 4 then aa.deliver_to_name
													 when 5 then aa.asset_year
													 when 6 then cast(aa.estimate_po_date as sql_variant)
													 when 7 then cast(datediff(day, aa.request_delivery_date, aa.estimate_po_date) as sql_variant)
													 when 8 then cast(aa.request_delivery_date as sql_variant)
													 when 9 then aa.purchase_status
													 when 9 then aa.purchase_gts_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then aa.asset_no + aa.asset_name + aa.asset_year + aa.asset_condition
													 when 2 then aa.fa_code + aa.fa_name
													 --when 3 then aa.fa_reff_no_01 + aa.fa_reff_no_02 + aa.fa_reff_no_03
													 when 3 then aa.replacement_fa_code + aa.replacement_fa_name
													 --when 5 then aa.replacement_fa_reff_no_01 + aa.replacement_fa_reff_no_02 + aa.replacement_fa_reff_no_03
													 when 4 then aa.deliver_to_name
													 when 5 then aa.asset_year
													 when 6 then cast(aa.estimate_po_date as sql_variant)
													 when 7 then cast(datediff(day, aa.request_delivery_date, aa.estimate_po_date) as sql_variant)
													 when 8 then cast(aa.request_delivery_date as sql_variant)
													 when 9 then aa.purchase_status
													 when 9 then aa.purchase_gts_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;