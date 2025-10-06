CREATE PROCEDURE [dbo].[xsp_purchase_order_detail_object_info_getrows_for_grn]
(
	@p_keywords						nvarchar(50)
	,@p_pagenumber					int
	,@p_rowspage					int
	,@p_order_by					int
	,@p_sort_by						nvarchar(5)
	,@p_purchase_order_detail_id	bigint
	,@p_id							bigint
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.purchase_order_detail_object_info
	where	purchase_order_detail_id = @p_purchase_order_detail_id
	and		good_receipt_note_detail_id = @p_id
	and		isnull(good_receipt_note_detail_id,'') <> ''
	and		(
				plat_no												like '%' + @p_keywords + '%'
				or	chassis_no										like '%' + @p_keywords + '%'
				or	engine_no										like '%' + @p_keywords + '%'
				or	serial_no										like '%' + @p_keywords + '%'
				or	invoice_no										like '%' + @p_keywords + '%'
				or	domain											like '%' + @p_keywords + '%'
				or	imei											like '%' + @p_keywords + '%'
				or	convert(varchar(30),cover_note_date,103)		like '%' + @p_keywords + '%'
				or	convert(varchar(30),exp_date,103)				like '%' + @p_keywords + '%'
				or	file_name										like '%' + @p_keywords + '%'
				or	stnk											like '%' + @p_keywords + '%'
				or	convert(varchar(30),stnk_date, 103)				like '%' + @p_keywords + '%'
				or	convert(varchar(30),stnk_exp_date, 103)			like '%' + @p_keywords + '%'
				or	stck											like '%' + @p_keywords + '%'
				or	convert(varchar(30),stck_date, 103)				like '%' + @p_keywords + '%'
				or	convert(varchar(30),stck_exp_date, 103)			like '%' + @p_keywords + '%'
				or	keur											like '%' + @p_keywords + '%'
				or	convert(varchar(30),keur_date, 103)				like '%' + @p_keywords + '%'
				or	convert(varchar(30),keur_exp_date, 103)			like '%' + @p_keywords + '%'
			) ;

	select		id
				,good_receipt_note_detail_id
				,plat_no
				,chassis_no
				,engine_no
				,serial_no
				,invoice_no
				,domain
				,imei
				,bpkb_no
				,isnull(cover_note,'') 'cover_note'
				,convert(varchar(30),cover_note_date,103) 'cover_note_date'
				,convert(varchar(30),exp_date,103) 'exp_date'
				,file_name
				,file_path
				,stnk
				,convert(varchar(30),stnk_date, 103) 'stnk_date'
				,convert(varchar(30),stnk_exp_date, 103) 'stnk_exp_date'
				,stck
				,convert(varchar(30),stck_date, 103) 'stck_date'
				,convert(varchar(30),stck_exp_date, 103) 'stck_exp_date'
				,keur
				,convert(varchar(30),keur_date, 103) 'keur_date'
				,convert(varchar(30),keur_exp_date, 103) 'keur_exp_date'
				,asset_code
				-- (+) Ari 2024-03-22 ket : add new file upload
				,isnull(stnk_file_no,'') 'file_name_stnk'
				,stnk_file_path 'file_path_stnk'
				,isnull(stck_file_no,'') 'file_name_stck'
				,stck_file_path 'file_path_stck'
				,isnull(keur_file_no,'') 'file_name_keur'
				,keur_file_path 'file_path_keur'
				-- (+) Ari 2024-03-22 
				,@rows_count 'rowcount'
	from		dbo.purchase_order_detail_object_info
	where		purchase_order_detail_id = @p_purchase_order_detail_id
	and			good_receipt_note_detail_id = @p_id
	and			isnull(good_receipt_note_detail_id,'') <> ''
	and			(
					plat_no												like '%' + @p_keywords + '%'
					or	chassis_no										like '%' + @p_keywords + '%'
					or	engine_no										like '%' + @p_keywords + '%'
					or	serial_no										like '%' + @p_keywords + '%'
					or	invoice_no										like '%' + @p_keywords + '%'
					or	domain											like '%' + @p_keywords + '%'
					or	imei											like '%' + @p_keywords + '%'
					or	convert(varchar(30),cover_note_date,103)		like '%' + @p_keywords + '%'
					or	convert(varchar(30),exp_date,103)				like '%' + @p_keywords + '%'
					or	bpkb_no											like '%' + @p_keywords + '%'
					or	cover_note										like '%' + @p_keywords + '%'
					or	file_name										like '%' + @p_keywords + '%'
					or	stnk											like '%' + @p_keywords + '%'
					or	convert(varchar(30),stnk_date, 103)				like '%' + @p_keywords + '%'
					or	convert(varchar(30),stnk_exp_date, 103)			like '%' + @p_keywords + '%'
					or	stck											like '%' + @p_keywords + '%'
					or	convert(varchar(30),stck_date, 103)				like '%' + @p_keywords + '%'
					or	convert(varchar(30),stck_exp_date, 103)			like '%' + @p_keywords + '%'
					or	keur											like '%' + @p_keywords + '%'
					or	convert(varchar(30),keur_date, 103)				like '%' + @p_keywords + '%'
					or	convert(varchar(30),keur_exp_date, 103)			like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then plat_no
													 when 2 then serial_no
													 when 3 then invoice_no
													 when 4 then chassis_no
													 when 5 then engine_no
													 when 6 then domain
													 when 7 then imei
													 when 8 then bpkb_no
													 when 9 then cover_note
													 when 10 then cast(cover_note_date as sql_variant)
													 when 11 then cast(exp_date as sql_variant)
													 when 12 then file_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													  when 1 then plat_no
													  when 2 then serial_no
													  when 3 then invoice_no
													  when 4 then chassis_no
													  when 5 then engine_no
													  when 6 then domain
													  when 7 then imei
													  when 8 then bpkb_no
													  when 9 then cover_note
													  when 10 then cast(cover_note_date as sql_variant)
													  when 11 then cast(exp_date as sql_variant)
													  when 12 then file_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
