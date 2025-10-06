CREATE PROCEDURE [dbo].[xsp_gps_realization_subscribe_update]
(
     @p_realization_no          NVARCHAR(50)
    ,@p_bank_name               NVARCHAR(100)
    ,@p_bank_account_no         NVARCHAR(50)
    ,@p_bank_account_name       NVARCHAR(100)
    ,@p_realization_date        DATETIME
    ,@p_invoice_no              NVARCHAR(50)
    ,@p_invoice_date            DATETIME
    ,@p_faktur_no               NVARCHAR(50)
    ,@p_faktur_date             DATETIME
    ,@p_tax_code                NVARCHAR(20)
    ,@p_tax_name                NVARCHAR(250)
    ,@p_billing_amount          DECIMAL(18, 2)
    ,@p_ppn_amount              DECIMAL(18, 2)
    ,@p_pph_amount              DECIMAL(18, 2)
	--
    ,@p_mod_date                DATETIME
    ,@p_mod_by                  NVARCHAR(15)
    ,@p_mod_ip_address          NVARCHAR(15)
)
AS
BEGIN
    DECLARE @msg NVARCHAR(MAX)

    BEGIN TRY
        UPDATE dbo.GPS_REALIZATION_SUBCRIBE
        SET 
             BANK_NAME           = @p_bank_name
            ,BANK_ACCOUNT_NO     = @p_bank_account_no
            ,BANK_ACCOUNT_NAME   = @p_bank_account_name
            ,REALIZATION_DATE    = @p_realization_date
			,INVOICE_NO			 = @p_invoice_no
            ,INVOICE_DATE        = @p_invoice_date
            ,FAKTUR_NO           = @p_faktur_no
            ,FAKTUR_DATE         = @p_faktur_date
            ,TAX_CODE            = @p_tax_code
			,TAX_NAME			 = @p_tax_name
            ,BILLING_AMOUNT      = @p_billing_amount
            ,PPN_AMOUNT          = @p_ppn_amount
            ,PPH_AMOUNT          = @p_pph_amount
            ,INVOICE_AMOUNT      = @p_billing_amount + @p_ppn_amount - @p_pph_amount
			--
            ,MOD_DATE            = @p_mod_date
            ,MOD_BY              = @p_mod_by
            ,MOD_IP_ADDRESS      = @p_mod_ip_address
        WHERE REALIZATION_NO = @p_realization_no
    END TRY
    BEGIN CATCH
        IF ERROR_MESSAGE() LIKE 'V;%' OR ERROR_MESSAGE() LIKE 'E;%'
        BEGIN
            SET @msg = ERROR_MESSAGE();
        END
        ELSE
        BEGIN
            SET @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + ERROR_MESSAGE();
        END

        RAISERROR(@msg, 16, -1);
        RETURN;
    END CATCH
END
