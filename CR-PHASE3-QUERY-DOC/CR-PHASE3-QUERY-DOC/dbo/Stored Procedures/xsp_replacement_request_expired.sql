--Raffyanda 12/01/2024
CREATE PROCEDURE dbo.xsp_replacement_request_expired
(
	@p_id				NVARCHAR(50)
	--
	,@p_mod_date			DATETIME
	,@p_mod_by				NVARCHAR(15)
	,@p_mod_ip_address		NVARCHAR(15)
)
AS
BEGIN
	DECLARE	@msg				NVARCHAR(MAX)

	BEGIN TRY

			UPDATE	dbo.REPLACEMENT_REQUEST
			SET		STATUS							= 'EXPIRED'
					,mod_date						= @p_mod_date
					,mod_by							= @p_mod_by
					,mod_ip_address					= @p_mod_ip_address
			WHERE	ID								= @p_id
			
		END TRY
	BEGIN CATCH
		DECLARE @error INT ;

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
