

CREATE PROCEDURE dbo.xsp_faktur_no_replacement_download_data
(
	@p_code			nvarchar(50) = ''
)
as
begin
	select		code
				,branch_code
				,branch_name
				,date
				,remarks
				,status
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
				,faktur_no_replacement_code 
	from		dbo.faktur_no_replacement_detail a
	left join	dbo.faktur_no_replacement b on b.code = a.faktur_no_replacement_code
	--where		CODE = @p_code
end
