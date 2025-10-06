CREATE PROCEDURE [dbo].[xsp_realization_subcription_gps_after_approved]
(
	@p_code			   NVARCHAR(50)
	--
	,@p_mod_date	   DATETIME
	,@p_mod_by		   NVARCHAR(15)
	,@p_mod_ip_address NVARCHAR(15)
)
AS
BEGIN
	DECLARE @msg	 NVARCHAR(MAX)
			,@status NVARCHAR(20) ;

	BEGIN TRY
		select	@status = STATUS
		from	dbo.GPS_REALIZATION_SUBCRIBE
		where	REALIZATION_NO = @p_code ;

		if (@status = 'ON PROCESS')
		begin
			update	dbo.GPS_REALIZATION_SUBCRIBE
			set		STATUS	= 'APPROVE'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	REALIZATION_NO	= @p_code ;

			--EXEC dbo.xsp_realization_subcription_gps_proceed @p_code				= @p_code
			--											   ,@p_cre_date			= @p_mod_date
			--											   ,@p_cre_by			= @p_mod_by
			--											   ,@p_cre_ip_address	= @p_mod_ip_address
			--											   ,@p_mod_date			= @p_mod_date
			--											   ,@p_mod_by			= @p_mod_by
			--											   ,@p_mod_ip_address	= @p_mod_ip_address

			EXEC dbo.xsp_realization_subcription_gps_proceed_after_approve @p_code				= @p_code
																		   ,@p_cre_date			= @p_mod_date
																		   ,@p_cre_by			= @p_mod_by
																		   ,@p_cre_ip_address	= @p_mod_ip_address
																		   ,@p_mod_date			= @p_mod_date
																		   ,@p_mod_by			= @p_mod_by
																		   ,@p_mod_ip_address	= @p_mod_ip_address
			
			
		end ;
		else
		begin
			set @msg = N'Data Already Proceed.' ;

			raiserror(@msg, 16, -1) ;
		end ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
