--created by, Bilal at 05/07/2023 

CREATE PROCEDURE dbo.xsp_rpt_invoice_pembatalan_kontrak
(
	@p_user_id				nvarchar(max)
	,@p_no_invoice			nvarchar(50)
	--,@p_agreement_no			nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin

	delete dbo.rpt_invoice_pembatalan_kontrak
	where user_id = @p_user_id

	--(Untuk Data Looping)
	delete dbo.rpt_invoice_pembatalan_kontrak_detail
	where user_id = @p_user_id

	--(Untuk Data Lampiran)
	delete dbo.rpt_invoice_pembatalan_kontrak_kwitansi
	where user_id = @p_user_id

	declare	@msg					nvarchar(max)
			,@report_company		nvarchar(250)
			,@report_image			nvarchar(250)
			,@report_title			nvarchar(250)
			--,@invoice_no			nvarchar(50) 
			,@agreement_no			nvarchar(50) = ''
		    ,@tanggal				datetime
		    ,@npwp_no				nvarchar(50)
		    ,@star_sewa				datetime
		    ,@end_sewa				datetime
		    ,@star_denda			datetime
		    ,@end_denda				datetime
		    ,@jatuh_tempo			datetime
		    ,@no_perjanjian			nvarchar(50)
		    ,@lesse_desc			nvarchar(4000)
		    ,@nama_bank				nvarchar(50)
		    ,@rek_atas_nama			nvarchar(50)
		    ,@no_rek				nvarchar(50)
		    ,@nama					nvarchar(50)
		    ,@jabatan				nvarchar(50)

	begin try

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		set	@report_title = 'INVOICE DENDA PEMBATALAN KONTRAK'

		insert into dbo.rpt_invoice_pembatalan_kontrak
		(
		    user_id
		    ,agreement_no
		    ,report_company
		    ,report_title
		    ,report_image
		    ,no_invoice
		    ,tanggal
		    ,npwp_no
		    ,star_sewa
		    ,end_sewa
		    ,star_denda
		    ,end_denda
		    ,jatuh_tempo
		    ,no_perjanjian
		    ,lesse_desc
		    ,nama_bank
		    ,rek_atas_nama
		    ,no_rek
		    ,nama
		    ,jabatan
		    ,cre_date
		    ,cre_by
		    ,cre_ip_address
		    ,mod_date
		    ,mod_by
		    ,mod_ip_address
		)
		values
		(   
			@p_user_id
		    ,@agreement_no
		    ,@report_company
		    ,@report_title
		    ,@report_image
		    ,@p_no_invoice 
		    ,@tanggal 
		    ,@npwp_no 
		    ,@star_sewa 
		    ,@end_sewa 
		    ,@star_denda
		    ,@end_denda 
		    ,@jatuh_tempo
		    ,@no_perjanjian
		    ,@lesse_desc
		    ,@nama_bank 
		    ,@rek_atas_nama
		    ,@no_rek 
		    ,@nama
		    ,@jabatan
			--
		    ,@p_cre_date		
			,@p_cre_by			
			,@p_cre_ip_address	
			,@p_mod_date		
			,@p_mod_by			
			,@p_mod_ip_address
		)

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
END
