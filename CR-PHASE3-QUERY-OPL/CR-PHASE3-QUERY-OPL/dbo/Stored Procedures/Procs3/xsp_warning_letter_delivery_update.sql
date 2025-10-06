CREATE PROCEDURE [dbo].[xsp_warning_letter_delivery_update]
(
	@p_code						NVARCHAR(50)
	,@p_branch_code				NVARCHAR(50)
	,@p_branch_name				NVARCHAR(250)
	,@p_delivery_status			NVARCHAR(10)
	,@p_delivery_date			DATETIME
	,@p_delivery_courier_type	NVARCHAR(10)
	,@p_delivery_courier_code	NVARCHAR(50)   = NULL
	,@p_delivery_collector_code NVARCHAR(50)   = NULL
	,@p_delivery_collector_name NVARCHAR(250)  = NULL
	,@p_delivery_remarks		NVARCHAR(4000)
	,@p_delivery_address		NVARCHAR(4000)
	,@p_client_phone_no			NVARCHAR(50)	= null
	,@p_client_npwp				NVARCHAR(50)	= null
	,@p_client_email			NVARCHAR(50)	= null
	,@p_delivery_to_name		NVARCHAR(250)
	,@p_up_print_sp				NVARCHAR(250)
	--
	,@p_mod_date				DATETIME
	,@p_mod_by					NVARCHAR(15)
	,@p_mod_ip_address			NVARCHAR(15)
)
AS
BEGIN
	DECLARE @msg NVARCHAR(MAX) ;

	BEGIN TRY

		IF (@p_delivery_date > dbo.xfn_get_system_date())
		BEGIN
			SET @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Date','System Date') ;

			RAISERROR(@msg, 16, -1) ;
		END
        
		UPDATE	warning_letter_delivery
		set		branch_code						= @p_branch_code
				,branch_name					= @p_branch_name
				,delivery_status				= @p_delivery_status
				,delivery_date					= @p_delivery_date
				,delivery_courier_type			= @p_delivery_courier_type
				,delivery_courier_code			= @p_delivery_courier_code
				,delivery_collector_code		= @p_delivery_collector_code
				,delivery_collector_name		= @p_delivery_collector_name
				,delivery_remarks				= @p_delivery_remarks
				,delivery_address				= @p_delivery_address
				,client_phone_no				= @p_client_phone_no
				,client_npwp					= @p_client_npwp
				,client_email					= @p_client_email
				,delivery_to_name				= @p_delivery_to_name
				,up_print_sp					= @p_up_print_sp
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		WHERE	code						= @p_code ;
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
