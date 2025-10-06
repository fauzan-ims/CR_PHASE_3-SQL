CREATE PROCEDURE [dbo].[xsp_register_delivery_detail_delete]
(
    @p_id BIGINT
)
AS
BEGIN
    DECLARE @msg NVARCHAR(MAX)
			,@register_code NVARCHAR(50)
			,@delivery_code NVARCHAR(50)

    BEGIN TRY
		
		SELECT @register_code = register_code,
				@delivery_code = DELIVERY_CODE
		FROM dbo.REGISTER_DELIVERY_DETAIL 
		WHERE id = @p_id

		UPDATE dbo.REGISTER_MAIN
		SET	DELIVERY_STATUS = NULL
		WHERE CODE = @register_code

        DELETE dbo.register_delivery_detail
        WHERE id = @p_id;

		IF NOT EXISTS (SELECT 1 FROM dbo.REGISTER_DELIVERY_DETAIL WHERE DELIVERY_CODE = @delivery_code)
		BEGIN
		    UPDATE dbo.REGISTER_DELIVERY SET STATUS = 'CANCEL' WHERE CODE = @delivery_code
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
