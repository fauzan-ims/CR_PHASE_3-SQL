CREATE PROCEDURE dbo.xsp_client_doc_update
(
	@p_id			   bigint
	,@p_client_code	   nvarchar(50)
	,@p_doc_type_code  nvarchar(50)
	,@p_document_no	   nvarchar(50)
	,@p_doc_status	   nvarchar(10)
	,@p_eff_date	   datetime
	,@p_exp_date	   datetime
	,@p_is_default	   nvarchar(1)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_default = 'T'
		set @p_is_default = '1' ;
	else
		set @p_is_default = '0' ;

	begin try
		if exists (select 1 from client_doc where doc_type_code = @p_doc_type_code and client_code = @p_client_code and id <> @p_id)
		begin
			set @msg = 'Document Type already exist';
			raiserror(@msg, 16, -1) ;
		end 
		if (@p_eff_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Effective Date must be less or equal than System Date';
			raiserror(@msg, 16, -1) ;
		end 
		if (@p_exp_date < @p_eff_date)
		begin
			set @msg = ' Expired Date must be greater or equal than Effective Date';
			raiserror(@msg, 16, -1) ;
		end 
		
		exec [dbo].[xsp_client_update_invalid] @p_client_code		= @p_client_code  
												,@p_mod_date		= @p_mod_date
												,@p_mod_by			= @p_mod_by
												,@p_mod_ip_address	= @p_mod_ip_address

		update	client_doc
		set		document_no		= @p_document_no
				,doc_type_code	= @p_doc_type_code
				,doc_status		= @p_doc_status
				,eff_date		= @p_eff_date
				,exp_date		= @p_exp_date
				,is_default		= @p_is_default
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	id				= @p_id ;

		if @p_is_default = '1'
			begin
				update	dbo.client_doc
				set		is_default		= '0'
				where	client_code		= @p_client_code
				and		id				<> @p_id
			END
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

