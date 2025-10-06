create PROCEDURE dbo.xsp_master_barcode_lookup
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;


	select	@rows_count = count(1)
	from	dbo.master_barcode_register_detail mbrd
			inner join dbo.master_barcode_register mbr on (mbr.code = mbrd.barcode_register_code)
	where	mbr.status		= 'POST'
	and		mbrd.status		= 'UNUSED'
	and		mbrd.asset_code	= '-'
	and		cast(getdate() as date) between cast(mbr.start_date as date) and cast(mbr.end_date as date)	
	and		(
				mbrd.barcode_register_code			like '%' + @p_keywords + '%'
				or	mbrd.barcode_no					like '%' + @p_keywords + '%'	 
			) ;

	select	mbrd.barcode_register_code
			,mbrd.barcode_no
			,@rows_count 'rowcount'
	from	dbo.master_barcode_register_detail mbrd
			inner join dbo.master_barcode_register mbr on (mbr.code = mbrd.barcode_register_code)
	where	mbr.status		= 'POST'
	and		mbrd.status		= 'UNUSED'
	and		mbrd.asset_code	= '-'
	and		cast(getdate() as date) between cast(mbr.start_date as date) and cast(mbr.end_date as date)
	and			(
					mbrd.barcode_register_code			like '%' + @p_keywords + '%'
				or	mbrd.barcode_no						like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by	
														when 1 then mbrd.barcode_register_code
														when 2 then mbrd.barcode_no
					 								end
				end asc
				,case
					when @p_sort_by = 'desc' then case @p_order_by				
														when 1 then mbrd.barcode_register_code
														when 2 then mbrd.barcode_no
					 								end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end ;
