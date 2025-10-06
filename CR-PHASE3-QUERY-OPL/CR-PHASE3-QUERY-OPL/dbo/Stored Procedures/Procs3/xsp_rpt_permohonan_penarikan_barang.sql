--created by, Bilal at 28/06/2023 

CREATE PROCEDURE dbo.xsp_rpt_permohonan_penarikan_barang
(
	@p_user_id			nvarchar(max)
	,@p_agreement_no	nvarchar(50)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin

	delete dbo.rpt_permohonan_penarikan_barang
	where user_id = @p_user_id 

	declare	@msg					nvarchar(max)
			,@report_company		nvarchar(250)
			,@report_image			nvarchar(250)
			,@report_title			nvarchar(250)
			,@tanggal				datetime
		    ,@request_by			nvarchar(50)
		    ,@asset_code			nvarchar(50)
		    ,@periode_from			datetime
		    ,@periode_to			datetime
		    ,@unit_name				nvarchar(250)
		    ,@colour				nvarchar(50)
		    ,@engine_no				nvarchar(50)
		    ,@chassie_no			nvarchar(50)
		    ,@tanggal_penarikan		datetime
		    ,@name					nvarchar(250)
		    ,@telepon				nvarchar(20)
		    ,@alamat				nvarchar(4000)

	begin try

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		set	@report_title = 'PERMOHONAN PENARIKAN BARANG'

		insert into dbo.rpt_permohonan_penarikan_barang
		(
		    user_id
		    ,agreement_no
		    ,report_company
		    ,report_title
		    ,report_image
		    ,tanggal
		    ,request_by
		    ,asset_code
		    ,periode_from
		    ,periode_to
		    ,unit_name
		    ,colour
		    ,engine_no
		    ,chassie_no
		    ,tanggal_penarikan
		    ,name
		    ,telepon
		    ,alamat
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
		    ,@p_agreement_no
		    ,@report_company 
		    ,@report_title
		    ,@report_image
		    ,@tanggal
		    ,@request_by
		    ,@asset_code
		    ,@periode_from
		    ,@periode_to
		    ,@unit_name 
		    ,@colour 
		    ,@engine_no
		    ,@chassie_no
		    ,@tanggal_penarikan
		    ,@name
		    ,@telepon
		    ,@alamat
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
