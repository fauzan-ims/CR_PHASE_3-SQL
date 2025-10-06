CREATE PROCEDURE [dbo].[xsp_register_delivery_delete]
(
    @p_code             NVARCHAR(50)
)
AS
BEGIN
    DECLARE @msg NVARCHAR(MAX);

    BEGIN TRY
        DELETE dbo.REGISTER_DELIVERY
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
