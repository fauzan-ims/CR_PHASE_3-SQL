CREATE PROCEDURE [dbo].[xsp_ap_invoice_registration_faktur_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_id		   bigint
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.ap_invoice_registration_detail_faktur		irdf
			inner join ap_invoice_registration_detail		ird on ird.id							 = irdf.invoice_registration_detail_id
			left join dbo.purchase_order_detail_object_info podoi on (podoi.ID = irdf.purchase_order_detail_object_info_id)
	where	ird.id			 = @p_id
			and ird.quantity <> 0
			and
			(
				podoi.asset_code									like '%' + @p_keywords + '%'
				or	podoi.plat_no									like '%' + @p_keywords + '%'
				or	podoi.engine_no									like '%' + @p_keywords + '%'
				or	podoi.chassis_no								like '%' + @p_keywords + '%'
				or	irdf.faktur_no									like '%' + @p_keywords + '%'
				or	convert(varchar(50), irdf.faktur_date, 103)		like '%' + @p_keywords + '%'
			) ;

	select		ird.invoice_register_code
				,irdf.id  'id_faktur'
				,podoi.asset_code
				,podoi.plat_no
				,podoi.engine_no
				,podoi.chassis_no
				,irdf.faktur_no
				,convert(varchar(50), irdf.faktur_date, 103) 'faktur_date'
				,@rows_count 'rowcount'
	from		dbo.ap_invoice_registration_detail_faktur		irdf
				inner join ap_invoice_registration_detail		ird on ird.id							 = irdf.invoice_registration_detail_id
				left join dbo.purchase_order_detail_object_info podoi on (podoi.ID = irdf.purchase_order_detail_object_info_id)
	where		ird.id			 = @p_id
				and ird.quantity <> 0
				and
				(
					podoi.asset_code									like '%' + @p_keywords + '%'
					or	podoi.plat_no									like '%' + @p_keywords + '%'
					or	podoi.engine_no									like '%' + @p_keywords + '%'
					or	podoi.chassis_no								like '%' + @p_keywords + '%'
					or	irdf.faktur_no									like '%' + @p_keywords + '%'
					or	convert(varchar(50), irdf.faktur_date, 103)		like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then podoi.plat_no
													 when 2 then podoi.engine_no
													 when 3 then podoi.chassis_no
													 when 4 then irdf.faktur_no
													 when 5 then cast(irdf.faktur_date as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then podoi.plat_no
													   when 2 then podoi.engine_no
													   when 3 then podoi.chassis_no
													   when 4 then irdf.faktur_no
													   when 5 then cast(irdf.faktur_date as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
