CREATE PROCEDURE [dbo].[xsp_client_slik_financial_statement_getrow]
(
	@p_id			   bigint
)
as
begin
	select	id
			,client_code
			,statement_year
			,statement_month
			,aset
			,aset_lancar
			,kas
			,piutang_usaha_lancar
			,investasi_lain_lancar
			,aset_lancar_lain
			,aset_tidak_lancar
			,piutang_usaha_tidak_lancar
			,investasi_lain_tidak_lancar
			,aset_tidak_lancar_lain
			,liabilitas
			,liabilitas_jangka_pendek
			,pinjaman_jangka_pendek
			,utang_usaha_jangka_pendek
			,liabilitas_jangka_pendek_lain
			,liabilitas_jangka_panjang
			,pinjaman_jangka_panjang
			,utang_usaha_jangka_panjang
			,liabilitas_jangka_panjang_lain
			,ekuitas
			,pendapatan_usaha
			,beban_operasional
			,laba_rugi_bruto
			,pendapatan_lain
			,beban_lain
			,laba_rugi_pre_tax
			,laba_rugi_tahun_berjalan
	from	client_slik_financial_statement
	where	id				   = @p_id ;
end ;

