
-- Stored Procedure

-- stored procedure

CREATE PROCEDURE [dbo].[xsp_proc_asset_lookup_getrows]
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

	-- sepria 13082025: ganti konsep karena cr priority
	--select	@rows_count = count(1)
	--from	dbo.proc_asset_lookup
	--where	application_no = @p_application_no
	--		and isnull(asset_no,'') = ''
	--		and
	--		(
	--			asset_code		like '%' + @p_keywords + '%'
	--			or	item_name	like '%' + @p_keywords + '%'
	--			or	plat_no		like '%' + @p_keywords + '%'
	--			or	engine_no	like '%' + @p_keywords + '%'
	--			or	chasis_no	like '%' + @p_keywords + '%'
	--		) ;

	--select	id
	--			,asset_code
	--			,item_name
	--			,plat_no
	--			,engine_no
	--			,chasis_no
	--			,@rows_count 'rowcount'
	--from		dbo.proc_asset_lookup
	--where		application_no = @p_application_no
	--			and isnull(asset_no,'') = ''
	--			and (
	--				asset_code		like '%' + @p_keywords + '%'
	--				or	item_name	like '%' + @p_keywords + '%'
	--				or	plat_no		like '%' + @p_keywords + '%'
	--				or	engine_no	like '%' + @p_keywords + '%'
	--				or	chasis_no	like '%' + @p_keywords + '%'
	--			)
	--order by	case
	--				when @p_sort_by = 'asc' then case @p_order_by
	--												 when 1 then asset_code
	--												 when 2 then plat_no
	--												 when 3 then engine_no
	--												 when 4 then chasis_no
	--											 end
	--			end asc
	--			,case
	--				 when @p_sort_by = 'desc' then case @p_order_by
	--												   when 1 then asset_code
	--												   when 2 then plat_no
	--												   when 3 then engine_no
	--												   when 4 then chasis_no
	--											   end
	--			 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

	declare @lookup_asset table
	(
		asset_code		nvarchar(50)
		,item_name		nvarchar(250)
		,plat_no		nvarchar(50)
		,engine_no		nvarchar(50)
		,chasis_no		nvarchar(50)
	)

	insert  @lookup_asset

	select	distinct 
			ast.code	
			,ast.item_name
			,fgrn.plat_no
			,fgrn.engine_no
			,fgrn.chasis_no
	from	dbo.final_grn_request_detail fgrn
			inner join ifinopl.dbo.application_asset aps on aps.asset_no = fgrn.asset_no
			inner join dbo.eproc_interface_asset past on past.grn_detail_id = fgrn.grn_detail_id_asset
			inner join ifinams.dbo.asset ast on ast.code = past.code
	where	fgrn.status = 'POST'
	and		isnull(ast.rental_status,'') = ''
	and		isnull(ast.status,'') = 'STOCK'
	and		isnull(ast.fisical_status,'') = 'ON HAND'
	and		application_no = @p_application_no
	and		ast.code not in (	select distinct isnull(isnull(aps.fa_code, aps.replacement_fa_code),'') from ifinopl.dbo.application_asset aps
										inner join ifinopl.dbo.application_main apm on apm.application_no = aps.application_no
								where apm.application_status not in ('cancel','reject'))
	and		ast.code not in (	select distinct isnull(isnull(aps.fa_code, aps.replacement_fa_code),'') from ifinopl.dbo.agreement_asset aps
								where aps.asset_status <> 'return')
	and
			(
				ast.code			like '%' + @p_keywords + '%'
				or	ast.item_name	like '%' + @p_keywords + '%'
				or	plat_no		like '%' + @p_keywords + '%'
				or	engine_no	like '%' + @p_keywords + '%'
				or	chasis_no	like '%' + @p_keywords + '%'
			) 
	UNION 

	select	distinct 
			ast.code
			,ast.item_name
			,asvh.plat_no
			,asvh.engine_no
			,asvh.chassis_no
	from	ifinams.dbo.asset ast
			inner join ifinams.dbo.asset_vehicle asvh on asvh.asset_code = ast.code
	where	isnull(ast.rental_status,'') = ''
	and		isnull(ast.status,'') = 'STOCK'
	and		isnull(ast.fisical_status,'') = 'ON HAND'
	and		ast.code not in (	select distinct isnull(isnull(aps.fa_code, aps.replacement_fa_code),'') from ifinopl.dbo.application_asset aps
										inner join ifinopl.dbo.application_main apm on apm.application_no = aps.application_no
								where apm.application_status not in ('cancel','reject'))
	and		ast.code not in (	select distinct isnull(isnull(aps.fa_code, aps.replacement_fa_code),'') from ifinopl.dbo.agreement_asset aps
								where aps.asset_status <> 'return')
	and		(
				ast.code				like '%' + @p_keywords + '%'
				or	ast.item_name		like '%' + @p_keywords + '%'
				or	asvh.plat_no		like '%' + @p_keywords + '%'
				or	asvh.engine_no		like '%' + @p_keywords + '%'
				or	asvh.chassis_no		like '%' + @p_keywords + '%'
			) 

-----

	select	@rows_count = count(1) 
	from	@lookup_asset

	select	0 'id',
            asset_code,
            item_name,
            plat_no,
            engine_no,
            chasis_no,
			@rows_count 'rowcount'
	from	@lookup_asset
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asset_code
													 when 2 then plat_no
													 when 3 then engine_no
													 when 4 then chasis_no
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then asset_code
													   when 2 then plat_no
													   when 3 then engine_no
													   when 4 then chasis_no
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end ;
