
CREATE procedure [dbo].[xsp_master_fintech_slik_client_getrows]
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
	from	master_fintech_slik_client
	where	(
				fintech_code							like '%' + @p_keywords + '%'
				or	slik_status_pendidikan_code			like '%' + @p_keywords + '%'
				or	slik_status_pendidikan_ojk_code		like '%' + @p_keywords + '%'
				or	slik_status_pendidikan_name			like '%' + @p_keywords + '%'
				or	slik_bid_ush_tmpt_kerja_code		like '%' + @p_keywords + '%'
				or	slik_bid_ush_tmpt_kerja_ojk_code	like '%' + @p_keywords + '%'
				or	slik_bid_ush_tmpt_kerja_name		like '%' + @p_keywords + '%'
				or	slik_pekerjaan_code					like '%' + @p_keywords + '%'
				or	slik_pekerjaan_ojk_code				like '%' + @p_keywords + '%'
				or	slik_pekerjaan_name					like '%' + @p_keywords + '%'
				or	slik_pnghslan_per_thn_amount		like '%' + @p_keywords + '%'
				or	slik_sumber_penghasilan_code		like '%' + @p_keywords + '%'
				or	slik_sumber_penghasilan_ojk_code	like '%' + @p_keywords + '%'
				or	slik_sumber_penghasilan_name		like '%' + @p_keywords + '%'
				or	slik_hub_pelapor_code				like '%' + @p_keywords + '%'
				or	slik_hub_pelapor_ojk_code			like '%' + @p_keywords + '%'
				or	slik_hub_pelapor_name				like '%' + @p_keywords + '%'
				or	slik_golongan_debitur_code			like '%' + @p_keywords + '%'
				or	slik_golongan_debitur_ojk_code		like '%' + @p_keywords + '%'
				or	slik_golongan_debitur_name			like '%' + @p_keywords + '%'
				or	slik_perj_pisah_harta				like '%' + @p_keywords + '%'
				or	slik_mlnggar_bts_maks_krdit			like '%' + @p_keywords + '%'
				or	slik_mlmpui_bts_maks_krdit			like '%' + @p_keywords + '%'
				or	slik_dati_ii_code					like '%' + @p_keywords + '%'
				or	slik_dati_ii_ojk_code				like '%' + @p_keywords + '%'
				or	slik_dati_ii_name					like '%' + @p_keywords + '%'
			) ;

	select		fintech_code
				,slik_status_pendidikan_code
				,slik_status_pendidikan_ojk_code
				,slik_status_pendidikan_name
				,slik_bid_ush_tmpt_kerja_code
				,slik_bid_ush_tmpt_kerja_ojk_code
				,slik_bid_ush_tmpt_kerja_name
				,slik_pekerjaan_code
				,slik_pekerjaan_ojk_code
				,slik_pekerjaan_name
				,slik_pnghslan_per_thn_amount
				,slik_sumber_penghasilan_code
				,slik_sumber_penghasilan_ojk_code
				,slik_sumber_penghasilan_name
				,slik_hub_pelapor_code
				,slik_hub_pelapor_ojk_code
				,slik_hub_pelapor_name
				,slik_golongan_debitur_code
				,slik_golongan_debitur_ojk_code
				,slik_golongan_debitur_name
				,slik_perj_pisah_harta
				,slik_mlnggar_bts_maks_krdit
				,slik_mlmpui_bts_maks_krdit
				,slik_dati_ii_code
				,slik_dati_ii_ojk_code
				,slik_dati_ii_name
				,@rows_count 'rowcount'
	from		master_fintech_slik_client
	where		(
					fintech_code							like '%' + @p_keywords + '%'
					or	slik_status_pendidikan_code			like '%' + @p_keywords + '%'
					or	slik_status_pendidikan_ojk_code		like '%' + @p_keywords + '%'
					or	slik_status_pendidikan_name			like '%' + @p_keywords + '%'
					or	slik_bid_ush_tmpt_kerja_code		like '%' + @p_keywords + '%'
					or	slik_bid_ush_tmpt_kerja_ojk_code	like '%' + @p_keywords + '%'
					or	slik_bid_ush_tmpt_kerja_name		like '%' + @p_keywords + '%'
					or	slik_pekerjaan_code					like '%' + @p_keywords + '%'
					or	slik_pekerjaan_ojk_code				like '%' + @p_keywords + '%'
					or	slik_pekerjaan_name					like '%' + @p_keywords + '%'
					or	slik_pnghslan_per_thn_amount		like '%' + @p_keywords + '%'
					or	slik_sumber_penghasilan_code		like '%' + @p_keywords + '%'
					or	slik_sumber_penghasilan_ojk_code	like '%' + @p_keywords + '%'
					or	slik_sumber_penghasilan_name		like '%' + @p_keywords + '%'
					or	slik_hub_pelapor_code				like '%' + @p_keywords + '%'
					or	slik_hub_pelapor_ojk_code			like '%' + @p_keywords + '%'
					or	slik_hub_pelapor_name				like '%' + @p_keywords + '%'
					or	slik_golongan_debitur_code			like '%' + @p_keywords + '%'
					or	slik_golongan_debitur_ojk_code		like '%' + @p_keywords + '%'
					or	slik_golongan_debitur_name			like '%' + @p_keywords + '%'
					or	slik_perj_pisah_harta				like '%' + @p_keywords + '%'
					or	slik_mlnggar_bts_maks_krdit			like '%' + @p_keywords + '%'
					or	slik_mlmpui_bts_maks_krdit			like '%' + @p_keywords + '%'
					or	slik_dati_ii_code					like '%' + @p_keywords + '%'
					or	slik_dati_ii_ojk_code				like '%' + @p_keywords + '%'
					or	slik_dati_ii_name					like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then fintech_code
													 when 2 then slik_status_pendidikan_code
													 when 3 then slik_status_pendidikan_ojk_code
													 when 4 then slik_status_pendidikan_name
													 when 5 then slik_bid_ush_tmpt_kerja_code
													 when 6 then slik_bid_ush_tmpt_kerja_ojk_code
													 when 7 then slik_bid_ush_tmpt_kerja_name
													 when 8 then slik_pekerjaan_code
													 when 9 then slik_pekerjaan_ojk_code
													 when 10 then slik_pekerjaan_name
													 when 11 then slik_sumber_penghasilan_code
													 when 12 then slik_sumber_penghasilan_ojk_code
													 when 13 then slik_sumber_penghasilan_name
													 when 14 then slik_hub_pelapor_code
													 when 15 then slik_hub_pelapor_ojk_code
													 when 16 then slik_hub_pelapor_name
													 when 17 then slik_golongan_debitur_code
													 when 18 then slik_golongan_debitur_ojk_code
													 when 19 then slik_golongan_debitur_name
													 when 20 then slik_perj_pisah_harta
													 when 21 then slik_mlnggar_bts_maks_krdit
													 when 22 then slik_mlmpui_bts_maks_krdit
													 when 23 then slik_dati_ii_code
													 when 24 then slik_dati_ii_ojk_code
													 when 25 then slik_dati_ii_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then fintech_code
													   when 2 then slik_status_pendidikan_code
													   when 3 then slik_status_pendidikan_ojk_code
													   when 4 then slik_status_pendidikan_name
													   when 5 then slik_bid_ush_tmpt_kerja_code
													   when 6 then slik_bid_ush_tmpt_kerja_ojk_code
													   when 7 then slik_bid_ush_tmpt_kerja_name
													   when 8 then slik_pekerjaan_code
													   when 9 then slik_pekerjaan_ojk_code
													   when 10 then slik_pekerjaan_name
													   when 11 then slik_sumber_penghasilan_code
													   when 12 then slik_sumber_penghasilan_ojk_code
													   when 13 then slik_sumber_penghasilan_name
													   when 14 then slik_hub_pelapor_code
													   when 15 then slik_hub_pelapor_ojk_code
													   when 16 then slik_hub_pelapor_name
													   when 17 then slik_golongan_debitur_code
													   when 18 then slik_golongan_debitur_ojk_code
													   when 19 then slik_golongan_debitur_name
													   when 20 then slik_perj_pisah_harta
													   when 21 then slik_mlnggar_bts_maks_krdit
													   when 22 then slik_mlmpui_bts_maks_krdit
													   when 23 then slik_dati_ii_code
													   when 24 then slik_dati_ii_ojk_code
													   when 25 then slik_dati_ii_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

