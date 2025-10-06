CREATE PROCEDURE dbo.xsp_client_slik_financial_statement_insert
(
	@p_id							   bigint = 0 output
	,@p_client_code					   nvarchar(50)
	,@p_statement_year				   nvarchar(4)
	,@p_statement_month				   nvarchar(2)
	,@p_aset						   decimal(18, 2)
	,@p_aset_lancar					   decimal(18, 2)
	,@p_kas							   decimal(18, 2)
	,@p_piutang_usaha_lancar		   decimal(18, 2)
	,@p_investasi_lain_lancar		   decimal(18, 2)
	,@p_aset_lancar_lain			   decimal(18, 2)
	,@p_aset_tidak_lancar			   decimal(18, 2)
	,@p_piutang_usaha_tidak_lancar	   decimal(18, 2)
	,@p_investasi_lain_tidak_lancar	   decimal(18, 2)
	,@p_aset_tidak_lancar_lain		   decimal(18, 2)
	,@p_liabilitas					   decimal(18, 2)
	,@p_liabilitas_jangka_pendek	   decimal(18, 2)
	,@p_pinjaman_jangka_pendek		   decimal(18, 2)
	,@p_utang_usaha_jangka_pendek	   decimal(18, 2)
	,@p_liabilitas_jangka_pendek_lain  decimal(18, 2)
	,@p_liabilitas_jangka_panjang	   decimal(18, 2)
	,@p_pinjaman_jangka_panjang		   decimal(18, 2)
	,@p_utang_usaha_jangka_panjang	   decimal(18, 2)
	,@p_liabilitas_jangka_panjang_lain decimal(18, 2)
	,@p_ekuitas						   decimal(18, 2)
	,@p_pendapatan_usaha			   decimal(18, 2)
	,@p_beban_operasional			   decimal(18, 2)
	,@p_laba_rugi_bruto				   decimal(18, 2)
	,@p_pendapatan_lain				   decimal(18, 2)
	,@p_beban_lain					   decimal(18, 2)
	,@p_laba_rugi_pre_tax			   decimal(18, 2)
	,@p_laba_rugi_tahun_berjalan	   decimal(18, 2)
	--
	,@p_cre_date					   datetime
	,@p_cre_by						   nvarchar(15)
	,@p_cre_ip_address				   nvarchar(15)
	,@p_mod_date					   datetime
	,@p_mod_by						   nvarchar(15)
	,@p_mod_ip_address				   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if @p_statement_year + @p_statement_month >  convert(varchar(6), dbo.xfn_get_system_date(),112)
		begin
			set @msg = 'Period must be less or equal than System Date';
			raiserror(@msg, 16, -1) ;
		end
		
		if exists (select 1 from client_slik_financial_statement where client_code = @p_client_code and statement_year = @p_statement_year and statement_month = @p_statement_month )
		begin
			set @msg = 'Month - Year already exist';
			raiserror(@msg, 16, -1) ;
		end
		exec [dbo].[xsp_client_update_invalid] @p_client_code		= @p_client_code  
												,@p_mod_date		= @p_mod_date
												,@p_mod_by			= @p_mod_by
												,@p_mod_ip_address	= @p_mod_ip_address

		insert into client_slik_financial_statement
		(
			client_code
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
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_client_code
			,@p_statement_year
			,@p_statement_month
			,@p_aset
			,@p_aset_lancar
			,@p_kas
			,@p_piutang_usaha_lancar
			,@p_investasi_lain_lancar
			,@p_aset_lancar_lain
			,@p_aset_tidak_lancar
			,@p_piutang_usaha_tidak_lancar
			,@p_investasi_lain_tidak_lancar
			,@p_aset_tidak_lancar_lain
			,@p_liabilitas
			,@p_liabilitas_jangka_pendek
			,@p_pinjaman_jangka_pendek
			,@p_utang_usaha_jangka_pendek
			,@p_liabilitas_jangka_pendek_lain
			,@p_liabilitas_jangka_panjang
			,@p_pinjaman_jangka_panjang
			,@p_utang_usaha_jangka_panjang
			,@p_liabilitas_jangka_panjang_lain
			,@p_ekuitas
			,@p_pendapatan_usaha
			,@p_beban_operasional
			,@p_laba_rugi_bruto
			,@p_pendapatan_lain
			,@p_beban_lain
			,@p_laba_rugi_pre_tax
			,@p_laba_rugi_tahun_berjalan
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	
end ;

 

