--CREATED by ALIV at 11/05/2023
CREATE PROCEDURE dbo.xsp_ifinams_interface_spaf_asset_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_validation_status	nvarchar(20)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	ifinams_interface_spaf_asset isa
			left join asset a ON a.code = isa.fa_code
			left join dbo.asset_vehicle av on av.asset_code = isa.fa_code
	where	isa.validation_status = case @p_validation_status
									 when 'ALL' then isa.validation_status
									 else @p_validation_status
								 end
			and
			(
				isa.code												like '%' + @p_keywords + '%'
				or convert(varchar(30), isa.date , 103)					like '%' + @p_keywords + '%'
				or isa.fa_code											like '%' + @p_keywords + '%'
				or a.item_name											like '%' + @p_keywords + '%'
				or av.engine_no											like '%' + @p_keywords + '%'
				or av.chassis_no										like '%' + @p_keywords + '%'
				or av.plat_no											like '%' + @p_keywords + '%'
				or a.purchase_price										like '%' + @p_keywords + '%'
				or isa.spaf_pct											like '%' + @p_keywords + '%'
				or isa.spaf_amount										like '%' + @p_keywords + '%'
				or isa.validation_status								like '%' + @p_keywords + '%'
				or convert(varchar(30),isa.validation_date, 103)		like '%' + @p_keywords + '%'
				or isa.validation_remark								like '%' + @p_keywords + '%'
				or isa.claim_code										like '%' + @p_keywords + '%'
			) ;

	select		isa.id
				,isa.code				
				,convert(varchar(30), isa.date , 103) 'date'			
				,isa.fa_code	
				,a.item_name
				,av.engine_no
				,av.chassis_no
				,av.plat_no
				,a.purchase_price
				,isa.spaf_pct		
				,isa.spaf_amount			
				,isa.validation_status	
				,convert(varchar(30), isa.validation_date, 103) 'validation_date'
				,isa.validation_remark	
				,isa.claim_code			
				,@rows_count 'rowcount'
	from		ifinams_interface_spaf_asset isa
				left join asset a ON a.code = isa.fa_code
				left join dbo.asset_vehicle av on av.asset_code = isa.fa_code
	where		isa.validation_status = case @p_validation_status
									 when 'ALL' then isa.validation_status
									 else @p_validation_status
								 end
				and
				(
					isa.code												like '%' + @p_keywords + '%'
					or convert(varchar(30), isa.date , 103)					like '%' + @p_keywords + '%'
					or isa.fa_code											like '%' + @p_keywords + '%'
					or a.item_name											like '%' + @p_keywords + '%'
					or av.engine_no											like '%' + @p_keywords + '%'
					or av.chassis_no										like '%' + @p_keywords + '%'
					or av.plat_no											like '%' + @p_keywords + '%'
					or a.purchase_price										like '%' + @p_keywords + '%'
					or isa.spaf_pct											like '%' + @p_keywords + '%'
					or isa.spaf_amount										like '%' + @p_keywords + '%'
					or isa.validation_status								like '%' + @p_keywords + '%'
					or convert(varchar(30),isa.validation_date, 103)		like '%' + @p_keywords + '%'
					or isa.validation_remark								like '%' + @p_keywords + '%'
					or isa.claim_code										like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then isa.fa_code
													 when 2 then av.engine_no + av.chassis_no + av.plat_no
													 when 3 then cast(isa.date as sql_variant)
													 when 4 then cast(a.purchase_price as sql_variant)
													 when 5 then cast(isa.spaf_pct as sql_variant)
													 when 6 then cast(isa.spaf_amount as sql_variant)
													 when 7 then cast(isa.validation_date as sql_variant)
													 when 8 then isa.validation_remark	
													 when 9 then isa.validation_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then isa.fa_code
													 when 2 then av.engine_no + av.chassis_no + av.plat_no
													 when 3 then cast(isa.date as sql_variant)
													 when 4 then cast(a.purchase_price as sql_variant)
													 when 5 then cast(isa.spaf_pct as sql_variant)
													 when 6 then cast(isa.spaf_amount as sql_variant)
													 when 7 then cast(isa.validation_date as sql_variant)
													 when 8 then isa.validation_remark	
													 when 9 then isa.validation_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
