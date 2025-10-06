CREATE PROCEDURE dbo.xsp_application_asset_getrows_for_golive
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
			inner join dbo.sys_general_subcode sgs on (sgs.code				= aa.asset_type_code)
			left join dbo.application_asset_vehicle aav on (aav.asset_no	= aa.asset_no)
			left join dbo.application_asset_he aah on (aah.asset_no			= aa.asset_no)
			left join dbo.application_asset_machine aam on (aam.asset_no	= aa.asset_no)
			left join dbo.application_asset_electronic aae on (aae.asset_no = aa.asset_no)
			left join dbo.master_vehicle_unit mvu on (mvu.code				= aav.vehicle_unit_code)
			left join dbo.master_he_unit mhu on (mhu.code					= aah.he_unit_code)
			left join dbo.master_machinery_unit mmu on (mmu.code			= aam.machinery_unit_code)
			left join dbo.master_electronic_unit meu on (meu.code			= aae.electronic_unit_code) 
	where	application_no = @p_application_no
			and (
					aa.asset_no																						like '%' + @p_keywords + '%'
					or	aa.asset_name																				like '%' + @p_keywords + '%'
					or	aa.asset_year																				like '%' + @p_keywords + '%'
					or	aa.asset_condition																			like '%' + @p_keywords + '%'
					or	aa.fa_code																					like '%' + @p_keywords + '%'
					or	aa.fa_name																					like '%' + @p_keywords + '%'
					or	aa.purchase_status																			like '%' + @p_keywords + '%'
					or	aa.lease_rounded_amount																		like '%' + @p_keywords + '%'
					or	isnull(mvu.description, isnull(mhu.description, isnull(mmu.description, meu.description)))	like '%' + @p_keywords + '%' 
				) ;

	select		aa.asset_no
				,aa.asset_name
				,sgs.description 'asset_type'
				,aa.asset_year
				,aa.asset_condition
				,aa.lease_rounded_amount
				,aa.net_margin_amount
				,aa.purchase_status 
				,isnull(mvu.code, isnull(mhu.code, isnull(mmu.code, meu.code))) 'unit_code'
				,isnull(mvu.description, isnull(mhu.description, isnull(mmu.description, meu.description))) 'unit_desc'
				,aa.fa_code
				,aa.fa_name
				,aa.asset_type_code
				,@rows_count 'rowcount'
	from		application_asset aa
				inner join dbo.sys_general_subcode sgs on (sgs.code				= aa.asset_type_code)
				left join dbo.application_asset_vehicle aav on (aav.asset_no	= aa.asset_no)
				left join dbo.application_asset_he aah on (aah.asset_no			= aa.asset_no)
				left join dbo.application_asset_machine aam on (aam.asset_no	= aa.asset_no)
				left join dbo.application_asset_electronic aae on (aae.asset_no = aa.asset_no)
				left join dbo.master_vehicle_unit mvu on (mvu.code				= aav.vehicle_unit_code)
				left join dbo.master_he_unit mhu on (mhu.code					= aah.he_unit_code)
				left join dbo.master_machinery_unit mmu on (mmu.code			= aam.machinery_unit_code)
				left join dbo.master_electronic_unit meu on (meu.code			= aae.electronic_unit_code) 
	where		application_no = @p_application_no
				and (
						aa.asset_no																						like '%' + @p_keywords + '%'
						or	aa.asset_name																				like '%' + @p_keywords + '%'
						or	aa.asset_year																				like '%' + @p_keywords + '%'
						or	aa.asset_condition																			like '%' + @p_keywords + '%'
						or	aa.fa_code																					like '%' + @p_keywords + '%'
						or	aa.fa_name																					like '%' + @p_keywords + '%'
						or	aa.purchase_status																			like '%' + @p_keywords + '%'
						or	aa.lease_rounded_amount																		like '%' + @p_keywords + '%'
						or	isnull(mvu.description, isnull(mhu.description, isnull(mmu.description, meu.description)))	like '%' + @p_keywords + '%' 
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then aa.asset_no + aa.asset_name
													 when 2 then aa.asset_year			
													 when 3 then aa.asset_condition
													 when 4 then isnull(mvu.description, isnull(mhu.description, isnull(mmu.description, meu.description)))
													 when 5 then aa.fa_name
													 when 6 then cast(lease_rounded_amount as sql_variant)
													 when 7 then aa.purchase_status 
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then aa.asset_no + aa.asset_name
													 when 2 then aa.asset_year			
													 when 3 then aa.asset_condition
													 when 4 then isnull(mvu.description, isnull(mhu.description, isnull(mmu.description, meu.description)))
													 when 5 then aa.fa_name
													 when 6 then cast(lease_rounded_amount as sql_variant)
													 when 7 then aa.purchase_status 
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
