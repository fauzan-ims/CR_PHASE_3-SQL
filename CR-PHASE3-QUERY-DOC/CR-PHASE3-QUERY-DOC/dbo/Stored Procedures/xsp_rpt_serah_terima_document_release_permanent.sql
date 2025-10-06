--created by, Bilal at 03/07/2023 

CREATE PROCEDURE dbo.xsp_rpt_serah_terima_document_release_permanent
(
	@p_user_id				nvarchar(max)
	,@p_mutation_no			nvarchar(50)
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

	delete dbo.rpt_serah_terima_document_release_permanent
	where user_id = @p_user_id 

	delete dbo.rpt_serah_terima_document_release_permanent_detail
	where user_id = @p_user_id 

	declare	@msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_image					nvarchar(250)
			,@report_title					nvarchar(250)
			,@tanggal_perjanjian			datetime
		    ,@value_date					datetime
		    ,@lesse_or_consumer				nvarchar(250)
		    ,@perjanjian_lesse_or_consumer  nvarchar(50)
			,@jumlah						int
			,@description					nvarchar(250)
		    ,@dokumen_or_surat				nvarchar(50)
		    ,@alasan_dokumen_or_surat		nvarchar(50)
		    ,@rekomendasi					nvarchar(50)

	begin try

		select @report_company = value
		from dbo.sys_global_param 
		where code = 'COMP2';

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		set	@report_title = 'SURAT PERSETUJUAN PENGELUARAN DOKUMEN'

		insert into dbo.rpt_serah_terima_document_release_permanent
		(
		    user_id
		    ,mutation_no
		    ,report_company
		    ,report_title
		    ,report_image
		    ,tanggal_perjanjian
		    ,value_date
		    ,lesse_or_consumer
		    ,perjanjian_lesse_or_consumer
			,jumlah
			,description
		    ,dokumen_or_surat
		    ,alasan_dokumen_or_surat
		    ,rekomendasi
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
		    ,@p_mutation_no
		    ,@report_company
		    ,@report_title
		    ,@report_image
		    ,@tanggal_perjanjian 
		    ,@value_date 
		    ,@lesse_or_consumer 
		    ,@perjanjian_lesse_or_consumer
			,@jumlah
			,@description
		    ,@dokumen_or_surat 
		    ,@alasan_dokumen_or_surat
		    ,@rekomendasi
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
