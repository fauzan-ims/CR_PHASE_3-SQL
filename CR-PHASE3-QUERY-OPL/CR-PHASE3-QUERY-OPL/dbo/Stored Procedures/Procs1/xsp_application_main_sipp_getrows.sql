CREATE PROCEDURE dbo.xsp_application_main_sipp_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_main_sipp
	where	(
				application_no like '%' + @p_keywords + '%'
				or	sipp_jenis_pembiayaan_code like '%' + @p_keywords + '%'
				or	sipp_skema_pembiayaan_code like '%' + @p_keywords + '%'
				or	sipp_jenis_barang_atau_jasa_code like '%' + @p_keywords + '%'
				or	sipp_jenis_suku_bunga_code like '%' + @p_keywords + '%'
				or	sipp_mata_uang_code like '%' + @p_keywords + '%'
				or	sipp_lokasi_project_code like '%' + @p_keywords + '%'
			) ;
			 
		select		application_no
					,sipp_jenis_pembiayaan_code
					,sipp_skema_pembiayaan_code
					,sipp_jenis_barang_atau_jasa_code
					,sipp_jenis_suku_bunga_code
					,sipp_mata_uang_code
					,sipp_lokasi_project_code
					,@rows_count 'rowcount'
		from		application_main_sipp
		where		(
						application_no like '%' + @p_keywords + '%'
						or	sipp_jenis_pembiayaan_code like '%' + @p_keywords + '%'
						or	sipp_skema_pembiayaan_code like '%' + @p_keywords + '%'
						or	sipp_jenis_barang_atau_jasa_code like '%' + @p_keywords + '%'
						or	sipp_jenis_suku_bunga_code like '%' + @p_keywords + '%'
						or	sipp_mata_uang_code like '%' + @p_keywords + '%'
						or	sipp_lokasi_project_code like '%' + @p_keywords + '%'
					) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then application_no
													when 2 then sipp_jenis_pembiayaan_code
													when 3 then sipp_skema_pembiayaan_code
													when 4 then sipp_jenis_barang_atau_jasa_code
													when 5 then sipp_jenis_suku_bunga_code
													when 6 then sipp_mata_uang_code
													when 7 then sipp_lokasi_project_code
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then application_no
													when 2 then sipp_jenis_pembiayaan_code
													when 3 then sipp_skema_pembiayaan_code
													when 4 then sipp_jenis_barang_atau_jasa_code
													when 5 then sipp_jenis_suku_bunga_code
													when 6 then sipp_mata_uang_code
													when 7 then sipp_lokasi_project_code
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

