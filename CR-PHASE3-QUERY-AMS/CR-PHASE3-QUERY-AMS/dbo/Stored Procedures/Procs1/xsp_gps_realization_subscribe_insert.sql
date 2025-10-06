CREATE PROCEDURE [dbo].[xsp_gps_realization_subscribe_insert]
(
    @p_realization_no				NVARCHAR(50) OUTPUT
	,@p_code					NVARCHAR(50)
	,@p_payment_date			DATETIME
	,@p_agreement_no			NVARCHAR(50)
	,@p_from_period				DATETIME
	,@p_to_period				DATETIME
	,@p_vendor_name				NVARCHAR(250)
	,@p_invoice_no				NVARCHAR(50)
	,@p_remarks					NVARCHAR(4000)
	,@p_invoice_amout			DECIMAL(18,2)
	,@p_status					NVARCHAR(20)
    --
    ,@p_cre_date              DATETIME
    ,@p_cre_by                NVARCHAR(15)
    ,@p_cre_ip_address        NVARCHAR(15)
    ,@p_mod_date              DATETIME
    ,@p_mod_by                NVARCHAR(15)
    ,@p_mod_ip_address        NVARCHAR(15)
)
AS
BEGIN
    DECLARE @msg			NVARCHAR(MAX)
            ,@year			NVARCHAR(2)
            ,@month			NVARCHAR(2)
			,@branch_code	NVARCHAR(50)
			,@branch_name	NVARCHAR(250);
				 
								 
	SET @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

    exec dbo.xsp_get_next_unique_code_for_table 
								@p_unique_code 			= @p_realization_no output
								,@p_branch_code 		= ''
								,@p_sys_document_code 	= ''
								,@p_custom_prefix 		= 'RSGPS'
								,@p_year 				= @year
								,@p_month 				= @month
								,@p_table_name 			= 'GPS_REALIZATION_SUBCRIBE'
								,@p_run_number_length 	= 6
								,@p_delimiter 			= '.'
								,@p_run_number_only 	= N'0' ;

		SELECT @branch_code		= ast.BRANCH_CODE
				,@branch_name	= ast.BRANCH_NAME
		FROM dbo.ASSET ast
		WHERE ast.CODE = @p_code

    BEGIN TRY
        INSERT INTO dbo.GPS_REALIZATION_SUBCRIBE
        (
            REALIZATION_NO
            ,FA_CODE
            ,PAYMENT_DATE
            ,AGREEMENT_NO
            ,FROM_PERIOD
			,TO_PERIOD
            ,VENDOR_NAME
            ,INVOICE_NO
            ,REMARKS
            ,INVOICE_AMOUT
            ,STATUS
			,BRANCH_CODE
			,BRANCH_NAME
			--
            ,CRE_DATE
            ,CRE_BY
            ,CRE_IP_ADDRESS
            ,MOD_DATE
            ,MOD_BY
            ,MOD_IP_ADDRESS
        )
        VALUES
        (   @p_realization_no
            ,@p_code
            ,@p_payment_date
			,@p_agreement_no
            ,@p_from_period
			,@p_to_period
            ,@p_vendor_name
            ,@p_invoice_no
            ,@p_remarks
            ,@p_invoice_amout
            ,'HOLD'
			,@branch_code
			,@branch_name
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
        );
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
        END

        RAISERROR(@msg, 16, -1);
        RETURN;
    END CATCH;
END;
