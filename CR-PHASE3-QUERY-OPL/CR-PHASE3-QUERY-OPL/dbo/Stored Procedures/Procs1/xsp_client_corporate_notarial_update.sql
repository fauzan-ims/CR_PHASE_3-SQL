CREATE PROCEDURE dbo.xsp_client_corporate_notarial_update
(
	@p_code					   nvarchar(50)
	,@p_client_code			   nvarchar(50)
	,@p_notarial_document_code nvarchar(50)
	,@p_document_no			   nvarchar(50)
	,@p_document_date		   datetime
	,@p_notary_name			   nvarchar(250)
	,@p_skmenkumham_doc_no	   nvarchar(50)
	,@p_suggest_by			   nvarchar(250)
	,@p_modal_dasar			   decimal(18, 2)
	,@p_modal_setor			   decimal(18, 2)
	--
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if (@p_document_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Document Date must be less or equal than System Date';
			raiserror (@msg, 16, 1);
		end
		if (@p_modal_dasar <= 0)
		begin
			set @msg = 'Modal Dasar must be greater than 0';
			raiserror (@msg, 16, 1);
		end
		if (@p_modal_setor <= 0)
		begin
			set @msg = 'Modal Setor must be greater than 0';
			raiserror (@msg, 16, 1);
		end
		if (@p_modal_setor > @p_modal_dasar)
		begin
			set @msg = 'Modal Setor must be less or equal than Modal Dasar';
			raiserror (@msg, 16, 1);
		end
		
		exec [dbo].[xsp_client_update_invalid] @p_client_code		= @p_client_code  
												,@p_mod_date		= @p_mod_date
												,@p_mod_by			= @p_mod_by
												,@p_mod_ip_address	= @p_mod_ip_address
		update	client_corporate_notarial
		set		client_code				= @p_client_code
				,notarial_document_code = @p_notarial_document_code
				,document_no			= upper(@p_document_no)
				,document_date			= @p_document_date
				,notary_name			= upper(@p_notary_name)
				,skmenkumham_doc_no		= upper(@p_skmenkumham_doc_no)
				,suggest_by				= upper(@p_suggest_by)
				,modal_dasar			= @p_modal_dasar
				,modal_setor			= @p_modal_setor
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code ;
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

