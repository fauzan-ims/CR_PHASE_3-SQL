--[
--    {
--        "p_type_code": "VHCL",
--        "p_merk_code": "MBL01",
--        "p_model_code": "MBL02",
--        "p_type_item_code": "MBL02"
--    }
--]


CREATE PROCEDURE dbo.xsp_asset_for_fixed_asset_lookup_backup
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_asset_status   nvarchar(50) = 'STOCK'
	,@p_type_code	   nvarchar(50) = null
	,@p_merk_code	   nvarchar(50) = null
	,@p_model_code	   nvarchar(50) = null
	,@p_type_item_code nvarchar(50) = null 
	,@p_condition		nvarchar(50) = 'ALL'

)
as
begin
	if (isnull(@p_type_code, '') = '')
	begin
		set @p_type_code = 'ALL' ;
	end ;

	if (isnull(@p_merk_code, '') = '')
	begin
		set @p_merk_code = 'ALL' ;
	end ;

	if (isnull(@p_model_code, '') = '')
	begin
		set @p_model_code = 'ALL' ;
	end ;

	if (isnull(@p_type_item_code, '') = '')
	begin
		set @p_type_item_code = 'ALL' ;
	end ;
  
	declare @rows_count int = 0 ;
	 
	select	@rows_count = count(1)
	from
			(
				select	ass.code
						,ass.branch_code
						,ass.branch_name
						,ass.item_name
						,ass.division_code
						,ass.division_name
						,ass.department_code
						,ass.department_name
						,av.built_year
						,ass.type_code
						,sgs.description
						,av.engine_no
						,av.chassis_no
						,av.plat_no
						,av.colour
						,ass.condition 'asset_condition'
						,ass.net_book_value_comm
						,ass.original_price 'purchase_price' --ass.purchase_price
						,ass.last_meter
						,ass.re_rent_status
						,ass.client_name
				from	dbo.asset ass
						inner join dbo.sys_general_subcode sgs on (sgs.code = ass.type_code)
						inner join dbo.asset_vehicle av on (av.asset_code	= ass.code)
				where	(ass.status							= @p_asset_status
						and isnull(ass.rental_status, '')   = case when isnull(ass.re_rent_status, '') = '' then '' else ass.rental_status end
						and isnull(ass.fisical_status, '')  = case when isnull(ass.re_rent_status, '') = '' then 'ON HAND' else ass.fisical_status end
						and isnull(ass.process_status, '')  = case when isnull(ass.re_rent_status, '') = '' then '' else ass.process_status end
						and	isnull(ass.activity_status, '') = case when isnull(ass.re_rent_status, '') = '' then '' else ass.activity_status end
						--and	isnull(ass.rental_status,'') = ''
						--and	isnull(ass.status,'') = 'STOCK'
						--and	isnull(ass.fisical_status,'') = 'ON HAND'
						--and	isnull(ass.condition,'') = @p_condition
						)
						--OR	ass.RE_RENT_STATUS = 'CONTINUE'
				union
				select	ass.code
						,ass.branch_code
						,ass.branch_name
						,ass.item_name
						,ass.division_code
						,ass.division_name
						,ass.department_code
						,ass.department_name
						,am.built_year
						,ass.type_code
						,sgs.description
						,am.engine_no
						,am.chassis_no
						,'' as 'plat_no'
						,am.colour
						,ass.condition 'asset_condition'
						,ass.net_book_value_comm
						,ass.original_price 'purchase_price' --ass.purchase_price
						,ass.last_meter
						,ass.re_rent_status
						,ass.client_name
				from	dbo.asset ass
						inner join dbo.sys_general_subcode sgs on (sgs.code = ass.type_code)
						inner join dbo.asset_machine am on (am.asset_code	= ass.code)
				where	(ass.status							= @p_asset_status
						and isnull(ass.rental_status, '')   = case when isnull(ass.re_rent_status, '') = '' then '' else ass.rental_status end
						and isnull(ass.fisical_status, '')  = case when isnull(ass.re_rent_status, '') = '' then 'ON HAND' else ass.fisical_status end
						and isnull(ass.process_status, '')  = case when isnull(ass.re_rent_status, '') = '' then '' else ass.process_status end
						and	isnull(ass.activity_status, '') = case when isnull(ass.re_rent_status, '') = '' then '' else ass.activity_status end
						--and	isnull(ass.rental_status,'') = ''
						--AND	isnull(ass.status,'') = 'STOCK'
						--AND	isnull(ass.fisical_status,'') = 'ON HAND'
						--and	isnull(ass.condition,'') = @p_condition
						)
						--OR	ass.RE_RENT_STATUS = 'CONTINUE'
				union
				select	ass.code
						,ass.branch_code
						,ass.branch_name
						,ass.item_name
						,ass.division_code
						,ass.division_name
						,ass.department_code
						,ass.department_name
						,ah.built_year
						,ass.type_code
						,sgs.description
						,ah.engine_no
						,ah.chassis_no
						,'' as 'plat_no'
						,ah.colour
						,ass.condition 'asset_condition'
						,ass.net_book_value_comm
						,ass.original_price 'purchase_price' --ass.purchase_price
						,ass.last_meter
						,ass.re_rent_status
						,ass.client_name
				from	dbo.asset ass
						inner join dbo.sys_general_subcode sgs on (sgs.code = ass.type_code)
						inner join dbo.asset_he ah on (ah.asset_code	= ass.code)
				where	(ass.status							= @p_asset_status
						and isnull(ass.rental_status, '')   = case when isnull(ass.re_rent_status, '') = '' then '' else ass.rental_status end
						and isnull(ass.fisical_status, '')  = case when isnull(ass.re_rent_status, '') = '' then 'ON HAND' else ass.fisical_status end
						and isnull(ass.process_status, '')  = case when isnull(ass.re_rent_status, '') = '' then '' else ass.process_status end
						and	isnull(ass.activity_status, '') = case when isnull(ass.re_rent_status, '') = '' then '' else ass.activity_status end
						--and	isnull(ass.rental_status,'') = ''
						--AND	isnull(ass.status,'') = 'STOCK'
						--AND	isnull(ass.fisical_status,'') = 'ON HAND'
						--and	isnull(ass.condition,'') = @p_condition
						)
						--OR	ass.RE_RENT_STATUS = 'CONTINUE'
				union
				select	ass.code
						,ass.branch_code
						,ass.branch_name
						,ass.item_name
						,ass.division_code
						,ass.division_name
						,ass.department_code
						,ass.department_name
						,'' 'built_year'
						,ass.type_code
						,sgs.description
						,'' as 'engine_no'
						,'' as 'chassis_no'
						,'' as 'plat_no'
						,'' as 'colour'
						,ass.condition 'asset_condition'
						,ass.net_book_value_comm
						,ass.original_price 'purchase_price' --ass.purchase_price
						,ass.last_meter
						,ass.re_rent_status
						,ass.client_name
				from	dbo.asset ass
						inner join dbo.sys_general_subcode sgs on (sgs.code	 = ass.type_code)
						inner join dbo.asset_electronic ae on (ae.asset_code = ass.code)
				where	(ass.status							= @p_asset_status
						and isnull(ass.rental_status, '')   = case when isnull(ass.re_rent_status, '') = '' then '' else ass.rental_status end
						and isnull(ass.fisical_status, '')  = case when isnull(ass.re_rent_status, '') = '' then 'ON HAND' else ass.fisical_status end
						and isnull(ass.process_status, '')  = case when isnull(ass.re_rent_status, '') = '' then '' else ass.process_status end
						and	isnull(ass.activity_status, '') = case when isnull(ass.re_rent_status, '') = '' then '' else ass.activity_status end
						--and	isnull(ass.rental_status,'') = ''
						--AND	isnull(ass.status,'') = 'STOCK'
						--AND	isnull(ass.fisical_status,'') = 'ON HAND'
						--and	isnull(ass.condition,'') = @p_condition
						)
						--OR	ass.RE_RENT_STATUS = 'CONTINUE'
			) asset
	where	(
				asset.code					like '%' + @p_keywords + '%'
				or	asset.item_name			like '%' + @p_keywords + '%'
				or	asset.plat_no			like '%' + @p_keywords + '%'
				or	asset.asset_condition	like '%' + @p_keywords + '%'
				or	asset.re_rent_status	like '%' + @p_keywords + '%'
				or	asset.client_name		like '%' + @p_keywords + '%'
			) ;

		

	select		*
	from
				(
					select	ass.code
							,ass.branch_code
							,ass.branch_name
							,ass.item_name
							,ass.division_code
							,ass.division_name
							,ass.department_code
							,ass.department_name
							,av.built_year
							,ass.type_code
							,sgs.description
							,av.engine_no
							,av.chassis_no
							,av.plat_no
							,av.colour
							,ass.net_book_value_comm
							,ass.original_price 'purchase_price' --ass.purchase_price
							,case when ass.is_spaf_use = 0 then ass.spaf_pct else 0 end 'SPAF_PCT'
							,case when ass.is_spaf_use = 0 then ass.spaf_amount else 0 end 'SPAF_AMOUNT'
							,ass.last_meter
							-- (+) Ari 2023-09-15 ket : add asset condition, year, colour, and tolltip adjustment
							,ass.condition 'asset_condition'
							,av.built_year 'asset_year'
							,av.colour 'asset_colour'
							,isnull(adj.adjustment_remark,'') 'adjustment_remark'
							-- (+) Ari 2023-09-15
							,case ass.re_rent_status when 'NEW' then 'NEW RENT' when 'CONTINUE' then 'CONTINUE RENT' else ass.re_rent_status end 're_rent_status'
							,ass.client_name
							,@rows_count 'rowcount'
					from	dbo.asset ass
							inner join dbo.sys_general_subcode sgs on (sgs.code = ass.type_code)
							inner join dbo.asset_vehicle av on (av.asset_code	= ass.code)
							-- (+) Ari 2023-09-15 ket : get code adjustment
							outer apply (
											select	isnull(sgs.description, adl.adjustment_description) 'adjustment_remark'
											from	dbo.adjustment adj 
											inner	join dbo.adjustment_detail adl on (adl.adjustment_code = adj.code)
											left	join dbo.sys_general_subcode sgs on (sgs.code = adl.adjusment_transaction_code)
											where	adj.asset_code = ass.code
										)adj
							-- (+) Ari 2023-09-15
				where	(ass.status							= @p_asset_status
						and isnull(ass.rental_status, '')   = case when isnull(ass.re_rent_status, '') = '' then '' else ass.rental_status end
						and isnull(ass.fisical_status, '')  = case when isnull(ass.re_rent_status, '') = '' then 'ON HAND' else ass.fisical_status end
						and isnull(ass.process_status, '')  = case when isnull(ass.re_rent_status, '') = '' then '' else ass.process_status end
						and	isnull(ass.activity_status, '') = case when isnull(ass.re_rent_status, '') = '' then '' else ass.activity_status end
						--and	isnull(ass.rental_status,'') = ''
						--AND	isnull(ass.status,'') = 'STOCK'
						--AND	isnull(ass.fisical_status,'') = 'ON HAND'
						--and	isnull(ass.condition,'') = @p_condition
						)
						--OR	ass.RE_RENT_STATUS = 'CONTINUE'
					union
					select	ass.code
							,ass.branch_code
							,ass.branch_name
							,ass.item_name
							,ass.division_code
							,ass.division_name
							,ass.department_code
							,ass.department_name
							,am.built_year
							,ass.type_code
							,sgs.description
							,am.engine_no
							,am.chassis_no
							,'' as 'plat_no'
							,am.colour
							,ass.net_book_value_comm
							,ass.original_price 'purchase_price' --ass.purchase_price
							,case when ass.is_spaf_use = 0 then ass.spaf_pct else 0 end 'SPAF_PCT'
							,case when ass.is_spaf_use = 0 then ass.spaf_amount else 0 end 'SPAF_AMOUNT'
							,ass.last_meter
							-- (+) Ari 2023-09-15 ket : add asset condition, year, colour, and tolltip adjustment
							,ass.condition 'asset_condition'
							,am.built_year 'asset_year'
							,am.colour 'asset_colour'
							,isnull(adj.adjustment_remark,'') 'adjustment_remark'
							-- (+) Ari 2023-09-15
							,case ass.re_rent_status when 'NEW' then 'NEW RENT' when 'CONTINUE' then 'CONTINUE RENT' else ass.re_rent_status end 're_rent_status'
							,ass.client_name
							,@rows_count 'rowcount'
					from	dbo.asset ass
							inner join dbo.sys_general_subcode sgs on (sgs.code = ass.type_code)
							inner join dbo.asset_machine am on (am.asset_code	= ass.code)
							-- (+) Ari 2023-09-15 ket : get code adjustment
							outer apply (
											select	isnull(sgs.description, adl.adjustment_description) 'adjustment_remark'
											from	dbo.adjustment adj 
											inner	join dbo.adjustment_detail adl on (adl.adjustment_code = adj.code)
											left	join dbo.sys_general_subcode sgs on (sgs.code = adl.adjusment_transaction_code)
											where	adj.asset_code = ass.code
										)adj
							-- (+) Ari 2023-09-15
				where	(ass.status							= @p_asset_status
						and isnull(ass.rental_status, '')   = case when isnull(ass.re_rent_status, '') = '' then '' else ass.rental_status end
						and isnull(ass.fisical_status, '')  = case when isnull(ass.re_rent_status, '') = '' then 'ON HAND' else ass.fisical_status end
						and isnull(ass.process_status, '')  = case when isnull(ass.re_rent_status, '') = '' then '' else ass.process_status end
						and	isnull(ass.activity_status, '') = case when isnull(ass.re_rent_status, '') = '' then '' else ass.activity_status end
						--and	isnull(ass.rental_status,'') = ''
						--AND	isnull(ass.status,'') = 'STOCK'
						--AND	isnull(ass.fisical_status,'') = 'ON HAND'
						--and	isnull(ass.condition,'') = @p_condition
						)
						--OR	ass.RE_RENT_STATUS = 'CONTINUE'
					union
					select	ass.code
							,ass.branch_code
							,ass.branch_name
							,ass.item_name
							,ass.division_code
							,ass.division_name
							,ass.department_code
							,ass.department_name
							,ah.built_year
							,ass.type_code
							,sgs.description
							,ah.engine_no
							,ah.chassis_no
							,'' as 'plat_no'
							,ah.colour
							,ass.net_book_value_comm
							,ass.original_price 'purchase_price' --ass.purchase_price
							,case when ass.is_spaf_use = 0 then ass.spaf_pct else 0 end 'SPAF_PCT'
							,case when ass.is_spaf_use = 0 then ass.spaf_amount else 0 end 'SPAF_AMOUNT'
							,ass.last_meter
							-- (+) Ari 2023-09-15 ket : add asset condition, year, colour, and tolltip adjustment
							,ass.condition 'asset_condition'
							,ah.built_year 'asset_year'
							,ah.colour 'asset_colour'
							,isnull(adj.adjustment_remark,'') 'adjustment_remark'
							-- (+) Ari 2023-09-15
							,case ass.re_rent_status when 'NEW' then 'NEW RENT' when 'CONTINUE' then 'CONTINUE RENT' else ass.re_rent_status end 're_rent_status'
							,ass.client_name
							,@rows_count 'rowcount'
					from	dbo.asset ass
							inner join dbo.sys_general_subcode sgs on (sgs.code = ass.type_code)
							inner join dbo.asset_he ah on (ah.asset_code	= ass.code)
							-- (+) Ari 2023-09-15 ket : get code adjustment
							outer apply (
											select	isnull(sgs.description, adl.adjustment_description) 'adjustment_remark'
											from	dbo.adjustment adj 
											inner	join dbo.adjustment_detail adl on (adl.adjustment_code = adj.code)
											left	join dbo.sys_general_subcode sgs on (sgs.code = adl.adjusment_transaction_code)
											where	adj.asset_code = ass.code
										)adj
							-- (+) Ari 2023-09-15
				where	(ass.status							= @p_asset_status
						and isnull(ass.rental_status, '')   = case when isnull(ass.re_rent_status, '') = '' then '' else ass.rental_status end
						and isnull(ass.fisical_status, '')  = case when isnull(ass.re_rent_status, '') = '' then 'ON HAND' else ass.fisical_status end
						and isnull(ass.process_status, '')  = case when isnull(ass.re_rent_status, '') = '' then '' else ass.process_status end
						and	isnull(ass.activity_status, '') = case when isnull(ass.re_rent_status, '') = '' then '' else ass.activity_status end
						--and	isnull(ass.rental_status,'') = ''
						--AND	isnull(ass.status,'') = 'STOCK'
						--AND	isnull(ass.fisical_status,'') = 'ON HAND'
						--and	isnull(ass.condition,'') = @p_condition
						)
						--OR	ass.RE_RENT_STATUS = 'CONTINUE'
					union
					select	ass.code
							,ass.branch_code
							,ass.branch_name
							,ass.item_name
							,ass.division_code
							,ass.division_name
							,ass.department_code
							,ass.department_name
							,'' 'built_year'
							,ass.type_code
							,sgs.description
							,'' as 'engine_no'
							,'' as 'chassis_no'
							,'' as 'plat_no'
							,'' as 'colour'
							,ass.net_book_value_comm
							,ass.original_price 'purchase_price' --ass.purchase_price
							,case when ass.is_spaf_use = 0 then ass.spaf_pct else 0 end 'SPAF_PCT'
							,case when ass.is_spaf_use = 0 then ass.spaf_amount else 0 end 'SPAF_AMOUNT'
							,ass.last_meter
							-- (+) Ari 2023-09-15 ket : add asset condition, year, colour, and tolltip adjustment
							,ass.condition 'asset_condition'
							,'' 'asset_year'
							,'' 'asset_colour'
							,isnull(adj.adjustment_remark,'') 'adjustment_remark'
							-- (+) Ari 2023-09-15
							,case ass.re_rent_status when 'NEW' then 'NEW RENT' when 'CONTINUE' then 'CONTINUE RENT' else ass.re_rent_status end 're_rent_status'
							,ass.client_name
							,@rows_count 'rowcount'
					from	dbo.asset ass
							inner join dbo.sys_general_subcode sgs on (sgs.code	 = ass.type_code)
							inner join dbo.asset_electronic ae on (ae.asset_code = ass.code)
							-- (+) Ari 2023-09-15 ket : get code adjustment
							outer apply (
											select	isnull(sgs.description, adl.adjustment_description) 'adjustment_remark'
											from	dbo.adjustment adj 
											inner	join dbo.adjustment_detail adl on (adl.adjustment_code = adj.code)
											left	join dbo.sys_general_subcode sgs on (sgs.code = adl.adjusment_transaction_code)
											where	adj.asset_code = ass.code
										)adj
							-- (+) Ari 2023-09-15
				where	(ass.status							= @p_asset_status
						and isnull(ass.rental_status, '')   = case when isnull(ass.re_rent_status, '') = '' then '' else ass.rental_status end
						and isnull(ass.fisical_status, '')  = case when isnull(ass.re_rent_status, '') = '' then 'ON HAND' else ass.fisical_status end
						and isnull(ass.process_status, '')  = case when isnull(ass.re_rent_status, '') = '' then '' else ass.process_status end
						and	isnull(ass.activity_status, '') = case when isnull(ass.re_rent_status, '') = '' then '' else ass.activity_status end
						--and	isnull(ass.rental_status,'') = ''
						--AND	isnull(ass.status,'') = 'STOCK'
						--AND	isnull(ass.fisical_status,'') = 'ON HAND'
						--and	isnull(ass.condition,'') = @p_condition
						)
						--OR	ass.RE_RENT_STATUS = 'CONTINUE'
				) asset
	where		(
					asset.code					like '%' + @p_keywords + '%'
					or	asset.item_name			like '%' + @p_keywords + '%'
					or	asset.plat_no			like '%' + @p_keywords + '%'
					or	asset.asset_condition	like '%' + @p_keywords + '%'
					or	asset.re_rent_status	like '%' + @p_keywords + '%'
					or	asset.client_name		like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asset.code
													 when 2 then asset.item_name
													 when 3 then asset.plat_no
													 when 4 then asset.asset_condition
													 when 5 then asset.re_rent_status
													 when 5 then asset.client_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then asset.code
													 when 2 then asset.item_name
													 when 3 then asset.plat_no
													 when 4 then asset.asset_condition
													 when 5 then asset.re_rent_status
													 when 5 then asset.client_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
