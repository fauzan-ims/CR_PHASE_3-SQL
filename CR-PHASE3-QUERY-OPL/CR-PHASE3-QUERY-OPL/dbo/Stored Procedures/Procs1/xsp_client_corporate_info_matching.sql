/*
	ALTERd : Yunus Muslim, 27 Mei 2020
*/
CREATE PROCEDURE dbo.xsp_client_corporate_info_matching
(
	@p_client_code		nvarchar(50)
)
as
begin
	declare @msg					nvarchar(max)
			,@client_type			nvarchar(10)
			,@corporate_name		nvarchar(250)
			,@corporate_tax_file_no	nvarchar(50)
			,@corporate_est_date	datetime
			,@shareholder_pct		decimal(9,6)
			,@checking_status		nvarchar(1)	;
	
	begin try
		select	@client_type	= client_type 
		from	dbo.client_main
		where	code			= @p_client_code

		select	@corporate_name			= full_name 
				,@corporate_est_date	= est_date
		from	dbo.client_corporate_info
		where	client_code				= @p_client_code
		
		select	@corporate_tax_file_no	= document_no
		from	dbo.client_corporate_notarial
		where	client_code				= @p_client_code
		
		select	@shareholder_pct = sum(shareholder_pct)
		from	dbo.client_corporate_shareholder
		where	client_code = @p_client_code

		exec dbo.xsp_sys_client_negative_and_warning_matching @p_client_type						= @client_type
															  ,@p_personal_nationality_type_code	= ''
															  ,@p_personal_doc_type_code			= ''
															  ,@p_personal_id_no					= ''
															  ,@p_personal_name						= ''
															  ,@p_personal_alias_name				= ''
															  ,@p_personal_mother_maiden_name		= ''
															  ,@p_personal_dob						= ''
															  ,@p_corporate_name					= @corporate_name
															  ,@p_corporate_tax_file_no				= @corporate_tax_file_no
															  ,@p_corporate_est_date				= @corporate_est_date
															  ,@p_status							= @checking_status output
		
		if @checking_status <> '0'
		begin
			set @msg = 'This company is found in negative or warning list'
			raiserror(@msg,16,-1)
		end

		if @shareholder_pct <> 100.00
		begin
			set @msg = 'Share Holder summary must be 100 percent'
			raiserror(@msg,16,-1)
		end

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

