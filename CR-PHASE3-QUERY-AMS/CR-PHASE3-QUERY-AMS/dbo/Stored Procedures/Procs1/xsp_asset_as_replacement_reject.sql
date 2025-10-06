CREATE PROCEDURE dbo.xsp_asset_as_replacement_reject
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address NVARCHAR(15)
)
AS
BEGIN
	DECLARE @msg		nvarchar(max)
			,@status	nvarchar(20)
			,@company_code	nvarchar(50);

	begin try  
		
			update	dbo.asset
			set		activity_status = ''
					,mod_date = @p_mod_date
					,mod_by = @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code = @p_code ;
			
		-- send mail attachment based on setting ================================================
			--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'RTRQTR'
			--												,@p_doc_code		= @p_code
			--												,@p_attachment_flag = 0
			--												,@p_attachment_file = ''
			--												,@p_attachment_path = ''
			--												,@p_company_code	= @company_code
			--												,@p_trx_no			= @p_code
			--												,@p_trx_type		= 'ASET'
			-- End of send mail attachment based on setting ================================================
		
		
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
