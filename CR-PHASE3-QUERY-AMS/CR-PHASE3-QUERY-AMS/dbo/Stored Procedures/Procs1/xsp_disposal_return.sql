CREATE PROCEDURE dbo.xsp_disposal_return
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@status		nvarchar(20)
			-- Asqal 20-Oct-2022 ket : for WOM (+)
			,@company_code	nvarchar(50)

	begin try  
		select	@status			= status
				,@company_code	= company_code
		from	dbo.disposal
		where	code = @p_code ;

		if (@status = 'ON PROGRESS')
		begin
			update	dbo.disposal
			set		status			= 'NEW'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code = @p_code;

			-- send mail attachment based on setting ================================================
			--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'RTRQTR'
			--												,@p_doc_code		= @p_code
			--												,@p_attachment_flag = 0
			--												,@p_attachment_file = ''
			--												,@p_attachment_path = ''
			--												,@p_company_code	= @company_code
			--												,@p_trx_no			= @p_code
			--												,@p_trx_type		= 'DISPOSAL'
			-- End of send mail attachment based on setting ================================================

		end
		else 
		--if (@status = 'POST')
		--begin
		--	update	dbo.disposal
		--	set		status			= 'ON PROGRESS'
		--			--
		--			,mod_date		= @p_mod_date
		--			,mod_by			= @p_mod_by
		--			,mod_ip_address = @p_mod_ip_address
		--	where	code = @p_code;

		--	delete dbo.efam_interface_journal_gl_link_transaction where transaction_code = @p_code ;

		--end 
		begin
			set @msg = 'Data already proceed';
			raiserror(@msg ,16,-1);
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
