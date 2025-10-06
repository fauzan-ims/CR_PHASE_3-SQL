CREATE PROCEDURE [dbo].[xsp_register_delivery_insert]
(
     @p_code					NVARCHAR(50) OUTPUT  -- Auto-generate CODE 
    ,@p_branch_code				NVARCHAR(50)
    ,@p_branch_name				NVARCHAR(250)
    ,@p_status					NVARCHAR(50) = 'HOLD'
    ,@p_delivery_date			DATETIME
    ,@p_deliver_by				NVARCHAR(50) 
    ,@p_delivery_to_name		NVARCHAR(50) 
    ,@p_delivery_to_area_no		NVARCHAR(3) 
    ,@p_delivery_to_phone_no	NVARCHAR(15) 
    ,@p_delivery_to_address		NVARCHAR(4000) 
    ,@p_remark					NVARCHAR(4000) 
    ,@p_result					NVARCHAR(50) 
    ,@p_received_date			DATETIME 
    ,@p_received_by				NVARCHAR(50) 
    ,@p_resi_no					NVARCHAR(50)
    ,@p_reject_date				DATETIME 
    ,@p_reason_code				NVARCHAR(50) 
    ,@p_reason_desc				NVARCHAR(250)
    --
    ,@p_cre_date				DATETIME
    ,@p_cre_by					NVARCHAR(15)
    ,@p_cre_ip_address			NVARCHAR(15)
    ,@p_mod_date				DATETIME
    ,@p_mod_by					NVARCHAR(15)
    ,@p_mod_ip_address			NVARCHAR(15)
)
AS
BEGIN
    DECLARE @msg NVARCHAR(MAX)
          ,@year NVARCHAR(2)
          ,@month NVARCHAR(2);

    set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

    EXEC dbo.xsp_get_next_unique_code_for_table
         @p_unique_code        = @p_code OUTPUT
        ,@p_branch_code        = ''
        ,@p_sys_document_code  = ''
        ,@p_custom_prefix      = 'RDV'
        ,@p_year               = @year
        ,@p_month              = @month
        ,@p_table_name         = 'REGISTER_DELIVERY'
        ,@p_run_number_length  = 6
        ,@p_delimiter          = '.'
        ,@p_run_number_only    = N'0';

    BEGIN TRY
        INSERT INTO dbo.REGISTER_DELIVERY
        (
             CODE
            ,BRANCH_CODE
            ,BRANCH_NAME
            ,DATE
            ,STATUS
            ,DELIVERY_DATE
            ,DELIVER_BY
            ,DELIVERY_TO_NAME
            ,DELIVERY_TO_AREA_NO
            ,DELIVERY_TO_PHONE_NO
            ,DELIVERY_TO_ADDRESS
            ,REMARK
            ,RESULT
            ,RECEIVED_DATE
            ,RECEIVED_BY
            ,RESI_NO
            ,REJECT_DATE
            ,REASON_CODE
            ,REASON_DESC
			--
            ,CRE_DATE
            ,CRE_BY
            ,CRE_IP_ADDRESS
            ,MOD_DATE
            ,MOD_BY
            ,MOD_IP_ADDRESS
        )
        VALUES
        (
             @p_code
            ,@p_branch_code
            ,@p_branch_name
            ,GETDATE()
            ,@p_status
            ,@p_delivery_date
            ,@p_deliver_by
            ,@p_delivery_to_name
            ,@p_delivery_to_area_no
            ,@p_delivery_to_phone_no
            ,@p_delivery_to_address
            ,@p_remark
            ,@p_result
            ,@p_received_date
            ,@p_received_by
            ,@p_resi_no
            ,@p_reject_date
            ,@p_reason_code
            ,@p_reason_desc
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
        END;

        RAISERROR(@msg, 16, -1);
        RETURN;
    END CATCH;
END;
