CREATE PROCEDURE dbo.xsp_application_main_slik_getrows
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
	from	application_main_slik
	where	(
				application_no like '%' + @p_keywords + '%'
				or	slik_sifat_kredit_code like '%' + @p_keywords + '%'
				or	slik_jenis_kredit_code like '%' + @p_keywords + '%'
				or	slik_skim_akad_pembiayaan_code like '%' + @p_keywords + '%'
				or	slik_kategori_debitur_code like '%' + @p_keywords + '%'
				or	slik_jenis_penggunaan_code like '%' + @p_keywords + '%'
				or	slik_orientasi_penggunaan_code like '%' + @p_keywords + '%'
				or	slik_sektor_ekonomi_code like '%' + @p_keywords + '%'
				or	slik_jenis_bunga_code like '%' + @p_keywords + '%'
				or	slik_kredit_pembiayaan_prog_pemerintah_code like '%' + @p_keywords + '%'
				or	slik_take_over_dari_code like '%' + @p_keywords + '%'
				or	slik_sumber_dana_code like '%' + @p_keywords + '%'
				or	slik_cara_restrukturasi_code like '%' + @p_keywords + '%'
				or	slik_kondisi_code like '%' + @p_keywords + '%'
			) ;
			 
		select		application_no
					,slik_sifat_kredit_code
					,slik_jenis_kredit_code
					,slik_skim_akad_pembiayaan_code
					,slik_kategori_debitur_code
					,slik_jenis_penggunaan_code
					,slik_orientasi_penggunaan_code
					,slik_sektor_ekonomi_code
					,slik_jenis_bunga_code
					,slik_kredit_pembiayaan_prog_pemerintah_code
					,slik_take_over_dari_code
					,slik_sumber_dana_code
					,slik_cara_restrukturasi_code
					,slik_kondisi_code
					,@rows_count 'rowcount'
		from		application_main_slik
		where		(
						application_no like '%' + @p_keywords + '%'
						or	slik_sifat_kredit_code like '%' + @p_keywords + '%'
						or	slik_jenis_kredit_code like '%' + @p_keywords + '%'
						or	slik_skim_akad_pembiayaan_code like '%' + @p_keywords + '%'
						or	slik_kategori_debitur_code like '%' + @p_keywords + '%'
						or	slik_jenis_penggunaan_code like '%' + @p_keywords + '%'
						or	slik_orientasi_penggunaan_code like '%' + @p_keywords + '%'
						or	slik_sektor_ekonomi_code like '%' + @p_keywords + '%'
						or	slik_jenis_bunga_code like '%' + @p_keywords + '%'
						or	slik_kredit_pembiayaan_prog_pemerintah_code like '%' + @p_keywords + '%'
						or	slik_take_over_dari_code like '%' + @p_keywords + '%'
						or	slik_sumber_dana_code like '%' + @p_keywords + '%'
						or	slik_cara_restrukturasi_code like '%' + @p_keywords + '%'
						or	slik_kondisi_code like '%' + @p_keywords + '%'
					) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
												when 1 then application_no
												when 2 then slik_sifat_kredit_code
												when 3 then slik_jenis_kredit_code
												when 4 then slik_skim_akad_pembiayaan_code
												when 5 then slik_kategori_debitur_code
												when 6 then slik_jenis_penggunaan_code
												when 7 then slik_orientasi_penggunaan_code
												when 8 then slik_sektor_ekonomi_code
												when 9 then slik_jenis_bunga_code
												when 10 then slik_kredit_pembiayaan_prog_pemerintah_code
												when 11 then slik_take_over_dari_code
												when 12 then slik_sumber_dana_code
												when 13 then slik_cara_restrukturasi_code
												when 14 then slik_kondisi_code
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
												when 1 then application_no
												when 2 then slik_sifat_kredit_code
												when 3 then slik_jenis_kredit_code
												when 4 then slik_skim_akad_pembiayaan_code
												when 5 then slik_kategori_debitur_code
												when 6 then slik_jenis_penggunaan_code
												when 7 then slik_orientasi_penggunaan_code
												when 8 then slik_sektor_ekonomi_code
												when 9 then slik_jenis_bunga_code
												when 10 then slik_kredit_pembiayaan_prog_pemerintah_code
												when 11 then slik_take_over_dari_code
												when 12 then slik_sumber_dana_code
												when 13 then slik_cara_restrukturasi_code
												when 14 then slik_kondisi_code
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

