CREATE PROCEDURE dbo.xsp_disposal_return_journal_trial
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
			,@date			datetime

	begin try  
		select	@status			= status 
				,@date			= disposal_date
		from	dbo.disposal
		where	code = @p_code ;

		if (@status = 'POST')
		begin
			update	dbo.disposal
			set		status			= 'ON PROGRESS'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code = @p_code;

			update	dbo.asset
			set		disposal_date	= @date
					,status			= 'AVAILABLE'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code in (select asset_code from dbo.disposal_detail where disposal_code = @p_code)

			delete	dbo.efam_interface_journal_gl_link_transaction 
			where	transaction_code = @p_code ;

			delete dbo.asset_mutation_history
			where	document_refference_no = @p_code;
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
