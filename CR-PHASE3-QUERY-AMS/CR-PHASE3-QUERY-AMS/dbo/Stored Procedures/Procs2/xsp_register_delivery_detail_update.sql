CREATE PROCEDURE [dbo].[xsp_register_delivery_detail_update]
(
     @p_id                BIGINT
    ,@p_delivery_code     NVARCHAR(50)
    ,@p_register_code     NVARCHAR(50)
    --
    ,@p_mod_date          DATETIME
    ,@p_mod_by            NVARCHAR(15)
    ,@p_mod_ip_address    NVARCHAR(15)
)
AS
BEGIN
    DECLARE @msg NVARCHAR(MAX);

    BEGIN TRY
        UPDATE dbo.register_delivery_detail
        SET
             delivery_code      = @p_delivery_code
            ,register_code      = @p_register_code
            ,mod_date           = @p_mod_date
            ,mod_by             = @p_mod_by
            ,mod_ip_address     = @p_mod_ip_address
        WHERE id = @p_id;
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
