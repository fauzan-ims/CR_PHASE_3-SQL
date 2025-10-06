CREATE PROCEDURE [dbo].[xsp_register_delivery_detail_insert]
(
     @p_id               BIGINT OUTPUT
    ,@p_delivery_code    NVARCHAR(50)
    ,@p_register_code    NVARCHAR(50)
    --
    ,@p_cre_date         DATETIME
    ,@p_cre_by           NVARCHAR(15)
    ,@p_cre_ip_address   NVARCHAR(15)
    ,@p_mod_date         DATETIME
    ,@p_mod_by           NVARCHAR(15)
    ,@p_mod_ip_address   NVARCHAR(15)
)
AS
BEGIN
    DECLARE @msg NVARCHAR(MAX);

    BEGIN TRY
        INSERT INTO dbo.REGISTER_DELIVERY_DETAIL
        (
             delivery_code
            ,register_code
			--
            ,cre_date
            ,cre_by
            ,cre_ip_address
            ,mod_date
            ,mod_by
            ,mod_ip_address
        )
        VALUES
        (
             @p_delivery_code
            ,@p_register_code
			--
            ,@p_cre_date
            ,@p_cre_by
            ,@p_cre_ip_address
            ,@p_mod_date
            ,@p_mod_by
            ,@p_mod_ip_address
        );

        SET @p_id = @@identity;
    END TRY
    BEGIN CATCH
        DECLARE @error INT = @@ERROR;

        IF (@error = 2627)
        BEGIN
            SET @msg = dbo.xfn_get_msg_err_code_already_exist();
        END;

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
