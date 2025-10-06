CREATE PROCEDURE [dbo].[xsp_register_delivery_detail_done]
(
     @p_code                   NVARCHAR(50)
    ,@p_code_list              NVARCHAR(MAX) = ''
    ,@p_delivery_date          DATETIME
    ,@p_deliver_by             NVARCHAR(50)
    ,@p_delivery_to_name       NVARCHAR(50)
    ,@p_delivery_to_area_no    NVARCHAR(3)
    ,@p_delivery_to_phone_no   NVARCHAR(15)
    ,@p_delivery_to_address    NVARCHAR(4000)
    ,@p_remark                 NVARCHAR(4000) = null
    ,@p_result                 NVARCHAR(50) = NULL
    ,@p_received_date          DATETIME = NULL
    ,@p_received_by            NVARCHAR(50) = NULL
    ,@p_resi_no                NVARCHAR(50) = NULL
    ,@p_reject_date            DATETIME = NULL
    ,@p_reason_code            NVARCHAR(50) = NULL
    ,@p_reason_reject          NVARCHAR(250) = NULL
    ,@p_result_remark          NVARCHAR(4000)
    -- 
    ,@p_mod_date               DATETIME
    ,@p_mod_by                 NVARCHAR(15)
    ,@p_mod_ip_address         NVARCHAR(15)
)
AS
BEGIN
    DECLARE @msg NVARCHAR(MAX);

    BEGIN TRY
        -- Update REGISTER_DELIVERY
        UPDATE dbo.REGISTER_DELIVERY
        SET 
             DELIVERY_DATE         = @p_delivery_date
            ,DELIVER_BY           = @p_deliver_by
            ,DELIVERY_TO_NAME     = @p_delivery_to_name
            ,DELIVERY_TO_AREA_NO  = @p_delivery_to_area_no
            ,DELIVERY_TO_PHONE_NO = @p_delivery_to_phone_no
            ,DELIVERY_TO_ADDRESS  = @p_delivery_to_address
            ,REMARK               = 'Selesai Pengiriman ' + ISNULL(@p_result, '')
            ,STATUS               = 'DONE'
            ,RESULT               = @p_result
            ,RECEIVED_DATE        = @p_received_date
            ,RECEIVED_BY          = @p_received_by
            ,RESI_NO              = @p_resi_no
            ,REJECT_DATE          = @p_reject_date
            ,REASON_CODE          = @p_reason_code
            ,REASON_DESC          = @p_reason_reject
            ,RESULT_REMARK        = @p_result_remark
            ,MOD_DATE             = @p_mod_date
            ,MOD_BY               = @p_mod_by
            ,MOD_IP_ADDRESS       = @p_mod_ip_address
        WHERE CODE = @p_code;

        IF (UPPER(@p_result) = 'FAILED')
        BEGIN
            UPDATE rmn
            SET 
                 DELIVERY_STATUS    = 'CANCEL'
                ,MOD_DATE           = @p_mod_date
                ,MOD_BY             = @p_mod_by
                ,MOD_IP_ADDRESS     = @p_mod_ip_address
            FROM dbo.REGISTER_MAIN rmn
            INNER JOIN dbo.REGISTER_DELIVERY_DETAIL rdd 
                ON rmn.CODE COLLATE SQL_Latin1_General_CP1_CI_AS = rdd.register_code
            INNER JOIN dbo.REGISTER_DELIVERY rd 
                ON rd.CODE = rdd.delivery_code
            WHERE rd.CODE = @p_code;
        END

    END TRY
    BEGIN CATCH
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
