CREATE PROCEDURE [dbo].[xsp_register_delivery_detail_post]
(
     @p_code					NVARCHAR(50)
    ,@p_delivery_date			DATETIME
    ,@p_deliver_by				NVARCHAR(50)
    ,@p_delivery_to_name		NVARCHAR(50)
    ,@p_delivery_to_area_no		NVARCHAR(3)
    ,@p_delivery_to_phone_no	NVARCHAR(15)
    ,@p_delivery_to_address		NVARCHAR(4000)
    ,@p_remark					NVARCHAR(4000)
    --
    ,@p_mod_date				DATETIME
    ,@p_mod_by					NVARCHAR(15)
    ,@p_mod_ip_address			NVARCHAR(15)
)
AS
BEGIN
    DECLARE @msg NVARCHAR(MAX);

    BEGIN TRY
        UPDATE dbo.REGISTER_DELIVERY
        SET 
            DELIVERY_DATE          = @p_delivery_date
            ,DELIVER_BY             = @p_deliver_by
            ,DELIVERY_TO_NAME       = @p_delivery_to_name
            ,DELIVERY_TO_AREA_NO    = @p_delivery_to_area_no
            ,DELIVERY_TO_PHONE_NO   = @p_delivery_to_phone_no
            ,DELIVERY_TO_ADDRESS    = @p_delivery_to_address
            ,REMARK                 = @p_remark
			,STATUS					= 'ON PROCESS'
			,RESULT					= 'Failed'
			--
            ,MOD_DATE               = @p_mod_date
            ,MOD_BY                 = @p_mod_by
            ,MOD_IP_ADDRESS         = @p_mod_ip_address
        WHERE CODE = @p_code;
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
