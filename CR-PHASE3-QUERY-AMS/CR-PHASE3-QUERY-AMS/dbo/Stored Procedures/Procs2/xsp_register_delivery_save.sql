CREATE PROCEDURE [dbo].[xsp_register_delivery_save]
(
     @p_code					NVARCHAR(50)
	,@p_result					NVARCHAR(50)
    ,@p_receive_date			DATETIME		= NULL
    ,@p_receive_by				NVARCHAR(50)	= NULL
    ,@p_resi_no					NVARCHAR(50)	= NULL
    ,@p_reject_date				DATETIME		= NULL
    ,@p_reason_reject_code		NVARCHAR(50)	= NULL
    ,@p_reason_reject			NVARCHAR(250)	= NULL
    ,@p_result_remark			NVARCHAR(4000)	= NULL
    --
    ,@p_mod_date				DATETIME
    ,@p_mod_by					NVARCHAR(15)
    ,@p_mod_ip_address			NVARCHAR(15)
)
AS
BEGIN
    DECLARE @msg NVARCHAR(MAX);

    BEGIN TRY
        IF @p_result = 'Accepted'
        BEGIN
            UPDATE dbo.REGISTER_DELIVERY
            SET 
                result				= @p_result,
                received_date		= @p_receive_date,
                received_by			= @p_receive_by,
                resi_no             = @p_resi_no,
                result_remark		= @p_result_remark,
                --
                mod_date			= @p_mod_date,
                mod_by				= @p_mod_by,
                mod_ip_address		= @p_mod_ip_address,
                reject_date			= NULL,
                reason_code			= NULL,
                reason_desc			= NULL
            WHERE code = @p_code;
        END
        ELSE IF @p_result = 'Failed'
        BEGIN
            UPDATE dbo.REGISTER_DELIVERY
            SET 
                result				= @p_result,
                reject_date			= @p_reject_date,
                reason_code	= @p_reason_reject_code,
                reason_desc		= @p_reason_reject,
                result_remark		= @p_result_remark,
                --
                mod_date			= @p_mod_date,
                mod_by				= @p_mod_by,
                mod_ip_address		= @p_mod_ip_address,
                -- kosongkan field accepted
                received_date		= NULL,
                received_by			= NULL,
                resi_no             = NULL
            WHERE code = @p_code;
        END
    END TRY
    BEGIN CATCH
        DECLARE @error INT = @@ERROR;

        IF (LEN(@msg) <> 0)
        BEGIN
            SET @msg = N'V;' + @msg;
        END
        ELSE IF (LEFT(ERROR_MESSAGE(), 2) = 'V;')
        BEGIN
            SET @msg = ERROR_MESSAGE();
        END
        ELSE
        BEGIN
            SET @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + ERROR_MESSAGE();
        END;

        RAISERROR(@msg, 16, -1);
        RETURN;
    END CATCH;
END;
