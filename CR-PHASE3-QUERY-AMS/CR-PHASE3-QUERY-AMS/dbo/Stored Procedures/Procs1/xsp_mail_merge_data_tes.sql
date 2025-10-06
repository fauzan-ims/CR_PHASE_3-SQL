CREATE PROCEDURE dbo.xsp_mail_merge_data_tes
--(
	
--)
as
begin

	declare @msg nvarchar(max);

	begin try
		

	select  
		'Indosurya Jakpus' as 'CABANG'
		,'Jakarta' as 'KOTA'
		,getdate() as 'TANGGAL'
		,'111222333' as 'NOMOR'
		,'Chapri' as 'NAMA_DEBITUR'
		,'jl.simpang raya 7 no.1' as 'ALAMAT_DEBITUR'
		,'08573321333' as 'TELPON'
		,'12BBCA33213' as 'NO_KONTRAK'
		,'21-01-2020' as 'TGL_DISBURSE'
		,'Chapri' as 'CONDITION'
		,'SP1_332232' as 'NOMOR_SP1'
		,'21-01-2020' as 'TGL_SP1'
		,'3' as 'ANGSURAN_KE'
		,'3000000.00' as 'ANGSURAN'
		,'180000.00' as 'DENDA';
	--from dbo.CUSTOMER_DOCUMENT;


	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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
