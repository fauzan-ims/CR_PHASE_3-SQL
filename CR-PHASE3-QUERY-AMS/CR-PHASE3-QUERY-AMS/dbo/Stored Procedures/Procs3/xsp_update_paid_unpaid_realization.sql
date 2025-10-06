CREATE PROCEDURE dbo.xsp_update_paid_unpaid_realization
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				 nvarchar(max)
			,@mod_by			 nvarchar(50)

	begin try -- 
		select @mod_by = mod_by 
		from dbo.register_main
		where code = @p_code


		if(@mod_by <> 'MIGRASI')
		BEGIN
			IF EXISTS (SELECT 1 FROM dbo.PAYMENT_REQUEST WHERE PAYMENT_SOURCE_NO = @p_code)
			BEGIN
				SET @msg = 'Cannot update this data.' ;
				RAISERROR(@msg, 16, -1) ;
            end
		END
        ELSE
        begin
			update	dbo.REGISTER_MAIN
			set		PAYMENT_STATUS		= 'HOLD'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code ;
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
