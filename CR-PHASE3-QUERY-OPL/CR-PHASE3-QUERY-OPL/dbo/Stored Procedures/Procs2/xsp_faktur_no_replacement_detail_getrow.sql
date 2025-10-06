

CREATE PROCEDURE dbo.xsp_faktur_no_replacement_detail_getrow
(
	@p_id	bigint
) as
begin

	select	 npwp_pembeli_or_identitas_lainnya 	
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
	from	dbo.faktur_no_replacement_detail
	where	id	= @p_id
end
