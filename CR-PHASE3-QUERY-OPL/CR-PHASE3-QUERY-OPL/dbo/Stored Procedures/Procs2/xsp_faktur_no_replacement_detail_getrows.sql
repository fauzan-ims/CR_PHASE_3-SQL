

CREATE PROCEDURE dbo.xsp_faktur_no_replacement_detail_getrows
(
	@p_keywords							nvarchar(50)
	,@p_pagenumber						int
	,@p_rowspage						int
	,@p_order_by						int
	,@p_sort_by							nvarchar(5)
	,@p_faktur_no_replacement_code		 nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.faktur_no_replacement_detail
	where	faktur_no_replacement_code = @p_faktur_no_replacement_code
	and		(
		
		
	faktur_no_replacement_code						LIKE '%' + @p_keywords + '%'
	or	upload_date									like '%' + @p_keywords + '%'
	or	npwp_pembeli_or_identitas_lainnya			like '%' + @p_keywords + '%'
	or	nama_pembeli								like '%' + @p_keywords + '%'
	or	kode_transaksi								like '%' + @p_keywords + '%'
	or	nomor_faktur_pajak							like '%' + @p_keywords + '%'
	or	tanggal_faktur_pajak						like '%' + @p_keywords + '%'
	or	masa_or_pajak								like '%' + @p_keywords + '%'
	or	tahun										like '%' + @p_keywords + '%'
	or	status_faktur								like '%' + @p_keywords + '%'
	or	harga_jual_or_penggantian_or_dpp			like '%' + @p_keywords + '%'
	or	dpp_nilai_lain_or_dpp						like '%' + @p_keywords + '%'
	or	ppn											like '%' + @p_keywords + '%'
	or	ppnbm										like '%' + @p_keywords + '%'
	or	penandatangan								like '%' + @p_keywords + '%'
	or	referensi									like '%' + @p_keywords + '%'
	or	dilaporkan_oleh_penjual						like '%' + @p_keywords + '%'
	or	dilaporkan_oleh_pemungut_ppn				like '%' + @p_keywords + '%'
	or	faktur_no_before							like '%' + @p_keywords + '%'
			) ;

	select 	   id
              ,faktur_no_replacement_code
              ,user_id
              ,upload_date
              ,npwp_pembeli_or_identitas_lainnya
              ,nama_pembeli
              ,kode_transaksi
              ,nomor_faktur_pajak
              ,tanggal_faktur_pajak
              ,masa_or_pajak
              ,tahun
              ,status_faktur
              ,harga_jual_or_penggantian_or_dpp
              ,dpp_nilai_lain_or_dpp
              ,ppn
              ,ppnbm
              ,penandatangan
              ,referensi
              ,dilaporkan_oleh_penjual
              ,dilaporkan_oleh_pemungut_ppn
              ,faktur_no_before
              ,cre_date
              ,cre_by
              ,cre_ip_address
              ,mod_date
              ,mod_by
              ,mod_ip_address
			  ,@rows_count 'rowcount'
	from	dbo.faktur_no_replacement_detail
	where	faktur_no_replacement_code = @p_faktur_no_replacement_code
	and		(
		faktur_no_replacement_code					like '%' + @p_keywords + '%'
	or	upload_date									like '%' + @p_keywords + '%'
	or	npwp_pembeli_or_identitas_lainnya			like '%' + @p_keywords + '%'
	or	nama_pembeli								like '%' + @p_keywords + '%'
	or	kode_transaksi								like '%' + @p_keywords + '%'
	or	nomor_faktur_pajak							like '%' + @p_keywords + '%'
	or	tanggal_faktur_pajak						like '%' + @p_keywords + '%'
	or	masa_or_pajak								like '%' + @p_keywords + '%'
	or	tahun										like '%' + @p_keywords + '%'
	or	status_faktur								like '%' + @p_keywords + '%'
	or	harga_jual_or_penggantian_or_dpp			like '%' + @p_keywords + '%'
	or	dpp_nilai_lain_or_dpp						like '%' + @p_keywords + '%'
	or	ppn											like '%' + @p_keywords + '%'
	or	ppnbm										like '%' + @p_keywords + '%'
	or	penandatangan								like '%' + @p_keywords + '%'
	or	referensi									like '%' + @p_keywords + '%'
	or	dilaporkan_oleh_penjual						like '%' + @p_keywords + '%'
	or	dilaporkan_oleh_pemungut_ppn				like '%' + @p_keywords + '%'
	or	faktur_no_before							like '%' + @p_keywords + '%'
			)
	order by	case 
					when @p_sort_by='asc' then case @p_order_by
													when 1 then		faktur_no_replacement_code				
													when 2 then		upload_date								
													when 3 then		npwp_pembeli_or_identitas_lainnya		
													when 4 then		nama_pembeli							
													when 5 then		kode_transaksi							
													when 6 then		nomor_faktur_pajak						
													when 7 then		tanggal_faktur_pajak					
													when 8 then		masa_or_pajak							
													when 9 then		tahun									
													when 10 then	status_faktur							
													when 11 then	harga_jual_or_penggantian_or_dpp		
													when 12 then	dpp_nilai_lain_or_dpp					
													when 13 then	ppn										
													when 14 then	ppnbm									
													when 15 then	penandatangan							
													when 16 then	referensi								
													when 17 then	dilaporkan_oleh_penjual					
													when 18 then	dilaporkan_oleh_pemungut_ppn			
													when 19 then	faktur_no_before						
												end
					end asc,
				case 
					when @p_sort_by='desc' then case @p_order_by 
													when 1 then		faktur_no_replacement_code				
													when 2 then		upload_date								
													when 3 then		npwp_pembeli_or_identitas_lainnya		
													when 4 then		nama_pembeli							
													when 5 then		kode_transaksi							
													when 6 then		nomor_faktur_pajak						
													when 7 then		tanggal_faktur_pajak					
													when 8 then		masa_or_pajak							
													when 9 then		tahun									
													when 10 then	status_faktur							
													when 11 then	harga_jual_or_penggantian_or_dpp		
													when 12 then	dpp_nilai_lain_or_dpp					
													when 13 then	ppn										
													when 14 then	ppnbm									
													when 15 then	penandatangan							
													when 16 then	referensi								
													when 17 then	dilaporkan_oleh_penjual					
													when 18 then	dilaporkan_oleh_pemungut_ppn			
													when 19 then	faktur_no_before			
												end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only;
end ;
