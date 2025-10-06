CREATE PROCEDURE dbo.xsp_warning_letter_delivery_cancel_backup_25092025
(
	@p_code						nvarchar(50)
    --
	--,@p_cre_date				datetime
	--,@p_cre_by					nvarchar(15)
	--,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				DATETIME
	,@p_mod_by					NVARCHAR(15)
	,@p_mod_ip_address			NVARCHAR(15)
)
AS
BEGIN
	
	

	DECLARE @msg								NVARCHAR(MAX)
			--
			--,@result_promise_date				datetime
            --,@agreement_no						nvarchar(50)
			--,@letter_code						nvarchar(50)


	BEGIN TRY

		--if exists (select 1 from dbo.warning_letter_delivery where code = @p_code and delivery_status  <> 'HOLD')
		--begin
		--		set @msg = dbo.xfn_get_msg_err_data_already_proceed();
		--		raiserror(@msg ,16,-1)
		--end
        --else
		--begin
		--		
		--		declare	c_letter cursor local fast_forward for
		--		select	letter_code
		--		from	dbo.warning_letter_delivery_detail
		--		where	delivery_code		= @p_code
		--
		--		open	c_letter
		--		fetch	c_letter
		--		into	@letter_code
		--
		--   		while	@@fetch_status = 0
		--		begin
		--			
		--			update	dbo.warning_letter
		--			set		letter_status		= 'ON PROCESS'
		--					,delivery_code		= null
		--					,delivery_date		= null
		--					,mod_date			= @p_mod_date			
		--					,mod_by				= @p_mod_by			
		--					,mod_ip_address		= @p_mod_ip_address
		--			where	letter_no			= @letter_code
		--
		--			fetch	c_letter
		--			into	@letter_code
		--		end
		--		close		c_letter
		--		deallocate	c_letter
		--
		--end

		update	dbo.warning_letter_delivery
		set		delivery_status			= 'CANCEL'
				--
				,mod_date				= @p_mod_date		
				,mod_by					= @p_mod_by			
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code

		UPDATE dbo.warning_letter
		SET		LETTER_STATUS			= 'ON PROCESS'
				--
				,mod_date				= @p_mod_date		
				,mod_by					= @p_mod_by			
				,mod_ip_address			= @p_mod_ip_address
		WHERE	delivery_code			= @p_code

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
end   
