CREATE PROCEDURE dbo.xsp_client_slik_getrows
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
	from	client_slik
	where	(
				client_code like '%' + @p_keywords + '%'
				or	slik_status_pendidikan_code like '%' + @p_keywords + '%'
				or	slik_bid_ush_tmpt_kerja_code like '%' + @p_keywords + '%'
				or	slik_pekerjaan_code like '%' + @p_keywords + '%'
				or	slik_pnghslan_per_thn_amount like '%' + @p_keywords + '%'
				or	slik_sumber_penghasilan_code like '%' + @p_keywords + '%'
				or	slik_hub_pelapor_code like '%' + @p_keywords + '%'
				or	slik_golongan_debitur_code like '%' + @p_keywords + '%'
				or	slik_perj_pisah_harta like '%' + @p_keywords + '%'
				or	slik_mlnggar_bts_maks_krdit like '%' + @p_keywords + '%'
				or	slik_mlmpui_bts_maks_krdit like '%' + @p_keywords + '%'
				or	slik_is_go_public like '%' + @p_keywords + '%'
				or	slik_lemb_pemeringkat_debitur_code like '%' + @p_keywords + '%'
				or	slik_tgl_pemeringkatan like '%' + @p_keywords + '%'
				or	slik_rating_debitur like '%' + @p_keywords + '%'
				or	slik_dati_ii_code like '%' + @p_keywords + '%'
			) ;
			 
		select		client_code
					,slik_status_pendidikan_code
					,slik_bid_ush_tmpt_kerja_code
					,slik_pekerjaan_code
					,slik_pnghslan_per_thn_amount
					,slik_sumber_penghasilan_code
					,slik_hub_pelapor_code
					,slik_golongan_debitur_code
					,slik_perj_pisah_harta
					,slik_mlnggar_bts_maks_krdit
					,slik_mlmpui_bts_maks_krdit
					,slik_is_go_public
					,slik_lemb_pemeringkat_debitur_code
					,slik_tgl_pemeringkatan
					,slik_rating_debitur
					,slik_dati_ii_code
					,@rows_count 'rowcount'
		from		client_slik
		where		(
						client_code like '%' + @p_keywords + '%'
						or	slik_status_pendidikan_code like '%' + @p_keywords + '%'
						or	slik_bid_ush_tmpt_kerja_code like '%' + @p_keywords + '%'
						or	slik_pekerjaan_code like '%' + @p_keywords + '%'
						or	slik_pnghslan_per_thn_amount like '%' + @p_keywords + '%'
						or	slik_sumber_penghasilan_code like '%' + @p_keywords + '%'
						or	slik_hub_pelapor_code like '%' + @p_keywords + '%'
						or	slik_golongan_debitur_code like '%' + @p_keywords + '%'
						or	slik_perj_pisah_harta like '%' + @p_keywords + '%'
						or	slik_mlnggar_bts_maks_krdit like '%' + @p_keywords + '%'
						or	slik_mlmpui_bts_maks_krdit like '%' + @p_keywords + '%'
						or	slik_is_go_public like '%' + @p_keywords + '%'
						or	slik_lemb_pemeringkat_debitur_code like '%' + @p_keywords + '%'
						or	slik_tgl_pemeringkatan like '%' + @p_keywords + '%'
						or	slik_rating_debitur like '%' + @p_keywords + '%'
						or	slik_dati_ii_code like '%' + @p_keywords + '%'
					) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then client_code
													when 2 then slik_status_pendidikan_code
													when 3 then slik_bid_ush_tmpt_kerja_code
													when 4 then slik_pekerjaan_code
													when 5 then slik_sumber_penghasilan_code
													when 6 then slik_hub_pelapor_code
													when 7 then slik_golongan_debitur_code
													when 8 then slik_perj_pisah_harta
													when 9 then slik_mlnggar_bts_maks_krdit
													when 10 then slik_mlmpui_bts_maks_krdit
													when 11 then slik_is_go_public
													when 12 then slik_lemb_pemeringkat_debitur_code
													when 13 then slik_dati_ii_code
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then client_code
													when 2 then slik_status_pendidikan_code
													when 3 then slik_bid_ush_tmpt_kerja_code
													when 4 then slik_pekerjaan_code
													when 5 then slik_sumber_penghasilan_code
													when 6 then slik_hub_pelapor_code
													when 7 then slik_golongan_debitur_code
													when 8 then slik_perj_pisah_harta
													when 9 then slik_mlnggar_bts_maks_krdit
													when 10 then slik_mlmpui_bts_maks_krdit
													when 11 then slik_is_go_public
													when 12 then slik_lemb_pemeringkat_debitur_code
													when 13 then slik_dati_ii_code
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

