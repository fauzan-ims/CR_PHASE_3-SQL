CREATE PROCEDURE [dbo].[xsp_warning_letter_delivery_settlement_save]
(
	@p_code						NVARCHAR(50)
	,@p_delivery_date			DATETIME
	,@p_result					NVARCHAR(50)
    ,@p_received_date			DATETIME		= NULL
    ,@p_received_by				NVARCHAR(50)	= NULL
    ,@p_resi_no					NVARCHAR(50)	= NULL
    ,@p_reject_date				DATETIME		= NULL
    ,@p_reason_code				NVARCHAR(50)	= NULL
    ,@p_reason_desc				NVARCHAR(250)	= NULL
    ,@p_result_remark			NVARCHAR(4000)	= NULL
	--
	,@p_mod_date				DATETIME
	,@p_mod_by					NVARCHAR(15)
	,@p_mod_ip_address			NVARCHAR(15)
)
AS
BEGIN
	DECLARE @msg NVARCHAR(MAX) ;

	BEGIN TRY

		IF (@p_delivery_date > @p_received_date)
		BEGIN
			SET @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Delivery Date','Received Date') ;

			RAISERROR(@msg, 16, -1) ;
		END
        
		IF @p_result = 'Accepted'
        BEGIN
            UPDATE dbo.WARNING_LETTER_DELIVERY
            SET 
                result				= @p_result
                ,received_date		= @p_received_date
                ,received_by		= @p_received_by
                ,resi_no			= @p_resi_no
                ,result_remark		= @p_result_remark
                --
                ,mod_date			= @p_mod_date
                ,mod_by				= @p_mod_by
                ,mod_ip_address		= @p_mod_ip_address
				--
                ,reject_date		= NULL
                ,reason_code		= NULL
                ,reason_desc		= NULL
            WHERE code = @p_code;
        END
        ELSE IF @p_result = 'Failed'
        BEGIN
            UPDATE dbo.WARNING_LETTER_DELIVERY
            SET 
                result				= @p_result
                ,reject_date		= @p_reject_date
                ,reason_code		= @p_reason_code
                ,reason_desc		= @p_reason_desc
                ,result_remark		= @p_result_remark
                --
                ,mod_date			= @p_mod_date
                ,mod_by				= @p_mod_by
                ,mod_ip_address		= @p_mod_ip_address
                -- 
                ,received_date		= NULL
                ,received_by		= NULL
                ,resi_no            = NULL
            WHERE code = @p_code;
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
