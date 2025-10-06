
CREATE procedure xsp_document_pending_detail_update
(
	@p_id					  bigint
	,@p_document_pending_code nvarchar(50)
	,@p_document_name		  nvarchar(250)
	,@p_document_description  nvarchar(4000)
	,@p_document_primary_no	  nvarchar(50)
	,@p_document_primary_name nvarchar(250)
	,@p_file_name			  nvarchar(250)
	,@p_paths				  nvarchar(250)
	,@p_expired_date		  datetime
	,@p_bpkb_name			  nvarchar(250)
	,@p_bpkb_no				  nvarchar(50)
	,@p_certificate_name	  nvarchar(250)
	,@p_certificate_no		  nvarchar(50)
	,@p_faktur_no			  nvarchar(50)
	,@p_stnk_no				  nvarchar(50)
	,@p_stnk_taxt_date		  datetime
	,@p_is_expired_date		  nvarchar(1)
	--
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_expired_date = 'T'
		set @p_is_expired_date = '1' ;
	else
		set @p_is_expired_date = '0' ;

	begin try
		update	document_pending_detail
		set		document_pending_code		= @p_document_pending_code
				,document_name				= @p_document_name
				,document_description		= @p_document_description
				,document_primary_no		= @p_document_primary_no
				,document_primary_name		= @p_document_primary_name
				,file_name					= @p_file_name
				,paths						= @p_paths
				,expired_date				= @p_expired_date
				,bpkb_name					= @p_bpkb_name
				,bpkb_no					= @p_bpkb_no
				,certificate_name			= @p_certificate_name
				,certificate_no				= @p_certificate_no
				,faktur_no					= @p_faktur_no
				,stnk_no					= @p_stnk_no
				,stnk_taxt_date				= @p_stnk_taxt_date
				,is_expired_date			= @p_is_expired_date
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id							= @p_id ;
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
