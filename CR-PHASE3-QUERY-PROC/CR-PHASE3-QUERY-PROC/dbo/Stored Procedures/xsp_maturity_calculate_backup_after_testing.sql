create PROCEDURE [dbo].[xsp_maturity_calculate_backup_after_testing]
(
    @p_asset_no NVARCHAR(50),
    @p_periode INT,
    @p_maturity_code NVARCHAR(50),
    @p_maturity_remark NVARCHAR(400),
    @p_maturity_date DATETIME,
    --
    @p_cre_date DATETIME,
    @p_cre_by NVARCHAR(15),
    @p_cre_ip_address NVARCHAR(15),
    @p_mod_date DATETIME,
    @p_mod_by NVARCHAR(15),
    @p_mod_ip_address NVARCHAR(15)
)
AS
BEGIN
    DECLARE @msg NVARCHAR(MAX),
            @due_date DATETIME,
            @no INT,
            @tenor INT,
            @schedule_month INT,
            @first_duedate DATETIME,
            @billing_date DATETIME,
            @billing_mode NVARCHAR(10),
            @billing_mode_date INT,
            @lease_rounded_amount DECIMAL(18, 2),
            @description NVARCHAR(4000),
            @max_billing_no INT,
            @agreement_no NVARCHAR(50),
            @first_payment_type NVARCHAR(3),
            @rounding_type NVARCHAR(50),
            @rounding_value DECIMAL(18, 2),
            @last_biling_amount DECIMAL(18, 2),
            @is_eomonth NVARCHAR(1),
            @first_max_biling_no INT,
            @max_billing_no_after INT,
            @add_periode INT;

    BEGIN TRY

        SET @tenor = @p_periode;

        -- mengambil multipier di master payment schedule
        SELECT @lease_rounded_amount = aa.MONTHLY_RENTAL_ROUNDED_AMOUNT,
               @billing_mode = aa.BILLING_MODE,
               @billing_mode_date = aa.BILLING_MODE_DATE,
               @agreement_no = am.AGREEMENT_NO,
               @first_payment_type = am.FIRST_PAYMENT_TYPE,
               @rounding_type = am.ROUND_TYPE,
               @rounding_value = am.ROUND_AMOUNT
        FROM dbo.AGREEMENT_ASSET aa
            INNER JOIN dbo.AGREEMENT_MAIN am
                ON (am.AGREEMENT_NO = aa.AGREEMENT_NO)
        WHERE aa.ASSET_NO = @p_asset_no;

        SELECT @schedule_month = MULTIPLIER,
               @add_periode = ADDITIONAL_PERIODE
        FROM dbo.MATURITY m
            INNER JOIN dbo.MASTER_BILLING_TYPE mbt
                ON (mbt.CODE = m.NEW_BILLING_TYPE)
        WHERE m.CODE = @p_maturity_code;

        SET @lease_rounded_amount = @lease_rounded_amount * @schedule_month;

        --select @add_periode = additional_periode from dbo.maturity where code = @p_maturity_code
        --if (@rounding_type = 'DOWN')
        --begin 
        --	set @lease_rounded_amount = dbo.fn_get_floor((@lease_rounded_amount), @rounding_value) ;
        --end
        --else if (@rounding_type = 'UP')
        --begin 
        --	set @lease_rounded_amount = dbo.fn_get_ceiling((@lease_rounded_amount), @rounding_value) ;
        --end
        --else
        --begin 
        --	set @lease_rounded_amount = dbo.fn_get_round((@lease_rounded_amount), @rounding_value) ;
        --end

        --select	@max_billing_no = max(billing_no)
        --		,@due_date = max(due_date)
        --from	dbo.agreement_asset_amortization
        --where	asset_no = @p_asset_no

        SELECT TOP 1
               @max_billing_no = BILLING_NO - 1,
               @first_max_biling_no = BILLING_NO,
               @due_date = DUE_DATE,
               @last_biling_amount = BILLING_AMOUNT
        FROM dbo.AGREEMENT_ASSET_AMORTIZATION
        WHERE ASSET_NO = @p_asset_no
        ORDER BY BILLING_NO DESC;

        IF (@first_payment_type = 'ADV')
        BEGIN
            SELECT @due_date = MATURITY_DATE
            FROM dbo.AGREEMENT_INFORMATION
            WHERE AGREEMENT_NO = @agreement_no;
        END;

        SET @no = 1;
        SET @first_duedate = @due_date;

        -- @schedule_month ini adalah per berapa bulan schedule yg akan terbentuk (cth: per 1 bulan/ per 2 bulan).
        -- @tenor jumlah periode utang.

        IF (@lease_rounded_amount <> @last_biling_amount)
        BEGIN
            IF EXISTS
            (
                SELECT 1
                FROM dbo.AGREEMENT_ASSET_AMORTIZATION
                WHERE ASSET_NO = @p_asset_no
                      AND BILLING_NO = @max_billing_no
                      AND ISNULL(INVOICE_NO, '') <> ''
            )
            BEGIN
                SET @msg = N'CANNOT EXTEND THIS ASSET, PLEASE CANCEL INVOICE FOR PRORATE AMOUNT ON LAST BILLING';
                RAISERROR(@msg, 16, -1);
            END;
            ELSE
            BEGIN
                SELECT TOP 1
                       @first_duedate = DUE_DATE
                FROM dbo.AGREEMENT_ASSET_AMORTIZATION
                WHERE ASSET_NO = @p_asset_no
                      AND BILLING_NO < @max_billing_no
                ORDER BY BILLING_NO DESC;

                DELETE dbo.MATURITY_AMORTIZATION_HISTORY
                WHERE ASSET_NO = @p_asset_no
                      AND INSTALLMENT_NO = @first_max_biling_no;

                SELECT @due_date = MAX(DUE_DATE)
                FROM dbo.MATURITY_AMORTIZATION_HISTORY
                WHERE ASSET_NO = @p_asset_no
                      AND OLD_OR_NEW = 'OLD';
                --SET @max_billing_no = @max_billing_no - 1

                WHILE (@no <= @tenor / @schedule_month)
                BEGIN

                    SET @max_billing_no += 1;

                    SET @description = N'Billing ke ' + CAST(@max_billing_no AS NVARCHAR(15)) + N' dari Periode ' + CONVERT(VARCHAR(30), @due_date, 103) + N' Sampai dengan '+ CONVERT(VARCHAR(30), DATEADD(MONTH, ((@schedule_month * @no) + 1), @first_duedate), 103);

                    IF (@first_payment_type = 'ARR')
                    BEGIN
                        SELECT @is_eomonth = (dbo.xfn_get_due_date_eomonth(@p_asset_no));

                        IF @is_eomonth = '0'
                        BEGIN
                            SET @due_date = DATEADD(MONTH, ((@schedule_month * @no) + 1), @first_duedate);
                        END;
                        ELSE
                        BEGIN
                            SET @due_date = EOMONTH(DATEADD(MONTH, ((@schedule_month * @no) + 1), @first_duedate));
                        END;
                    END;

                    IF (@billing_mode = 'BY DATE')
                    BEGIN
                        IF (DAY(@due_date) < @billing_mode_date)
                        BEGIN
                            SET @billing_date = DATEADD(MONTH, -1, @due_date);
                            IF (DAY(EOMONTH(@billing_date)) < @billing_mode_date)
                            BEGIN
                                SET @billing_date = DATEFROMPARTS(YEAR(@billing_date),MONTH(@billing_date),DAY(EOMONTH(@billing_date)));
                            END;
                            ELSE
                            BEGIN
                                SET @billing_date
                                    = DATEFROMPARTS(YEAR(@billing_date), MONTH(@billing_date), @billing_mode_date);
                            END;
                        END;
                        ELSE
                        BEGIN
                            SET @billing_date = DATEFROMPARTS(YEAR(@due_date), MONTH(@due_date), @billing_mode_date);
                        END;
                    END;
                    ELSE IF (@billing_mode = 'BEFORE DUE')
                    BEGIN
                        SET @billing_date = DATEADD(DAY, @billing_mode_date * -1, @due_date);
                    END;
                    ELSE
                    BEGIN
                        SET @billing_date = @due_date;
                    END;

                    INSERT INTO dbo.MATURITY_AMORTIZATION_HISTORY
                    (
                        MATURITY_CODE,
                        INSTALLMENT_NO,
                        ASSET_NO,
                        DUE_DATE,
                        BILLING_DATE,
                        BILLING_AMOUNT,
                        DESCRIPTION,
                        OLD_OR_NEW,
                        --
                        CRE_DATE,
                        CRE_BY,
                        CRE_IP_ADDRESS,
                        MOD_DATE,
                        MOD_BY,
                        MOD_IP_ADDRESS
                    )
                    VALUES
                    (   @p_maturity_code, @max_billing_no, @p_asset_no, @due_date, @billing_date,
                        @lease_rounded_amount, @description, 'NEW', --
                        @p_cre_date, @p_cre_by, @p_cre_ip_address, @p_mod_date, @p_mod_by, @p_mod_ip_address);

                    SET @due_date = DATEADD(MONTH, (@schedule_month * @no), @first_duedate);

                    SET @no += 1;
                END;

                SELECT @due_date = DATEADD(MONTH, @add_periode, DUE_DATE),
                       @billing_date = DATEADD(MONTH, @add_periode, BILLING_DATE),
                       @last_biling_amount = BILLING_AMOUNT
                FROM dbo.AGREEMENT_ASSET_AMORTIZATION
                WHERE ASSET_NO = @p_asset_no;

                SELECT @max_billing_no_after = MAX(INSTALLMENT_NO)
                FROM dbo.MATURITY_AMORTIZATION_HISTORY
                WHERE ASSET_NO = @p_asset_no;

                INSERT INTO dbo.MATURITY_AMORTIZATION_HISTORY
                (
                    MATURITY_CODE,
                    INSTALLMENT_NO,
                    ASSET_NO,
                    DUE_DATE,
                    BILLING_DATE,
                    BILLING_AMOUNT,
                    DESCRIPTION,
                    OLD_OR_NEW,
                    --
                    CRE_DATE,
                    CRE_BY,
                    CRE_IP_ADDRESS,
                    MOD_DATE,
                    MOD_BY,
                    MOD_IP_ADDRESS
                )
                VALUES
                (   @p_maturity_code, @max_billing_no_after, @p_asset_no, @due_date, @billing_date,
                    @last_biling_amount,
                    'Billing ke ' + CAST(@max_billing_no_after AS NVARCHAR(15)) + ' dari Periode '
                    + CONVERT(VARCHAR(30), @due_date, 103) + ' Sampai dengan '
                    + CONVERT(VARCHAR(30), DATEADD(MONTH, ((@schedule_month * @no) + 1), @first_duedate), 103), 'NEW',
                    --
                    @p_cre_date, @p_cre_by, @p_cre_ip_address, @p_mod_date, @p_mod_by, @p_mod_ip_address);
            --select @max_billing_no_after = max(installment_no) from dbo.maturity_amortization_history where asset_no = @p_asset_no
            --select @add_periode = additional_periode from dbo.maturity where code = @p_maturity_code

            --update dbo.maturity_amortization_history
            --set		due_date		= dateadd(month, @add_periode, b.due_date)
            --		,billing_date	= dateadd(month, @add_periode, b.billing_date)
            --		,billing_amount = b.billing_amount
            --		--,DESCRIPTION	= 'Billing ke ' + cast(@max_billing_no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), dateadd(month, @add_periode, b.due_date), 103) + ' Sampai dengan ' + convert(varchar(30), dateadd(month, ((@schedule_month * @no)+1), @first_duedate), 103)
            --from	dbo.maturity_amortization_history a
            --outer apply (select due_date, billing_amount, billing_date from dbo.maturity_amortization_history
            --			where asset_no = @p_asset_no and installment_no = @first_max_biling_no)b
            --where  a.asset_no = @p_asset_no 
            --and		a.installment_no = @max_billing_no_after

            --UPDATE dbo.MATURITY_AMORTIZATION_HISTORY
            --SET		DUE_DATE		= EOMONTH(DUE_DATE)
            --		,BILLING_DATE	=  EOMONTH(BILLING_DATE)
            --		,BILLING_AMOUNT	= @lease_rounded_amount
            --		--,DESCRIPTION	= 'Billing ke ' + cast(@max_billing_no as nvarchar(15)) + ' dari Periode ' + convert(varchar(30), @due_date, 103) + ' Sampai dengan ' + convert(varchar(30), dateadd(month, (@schedule_month * @no), @first_duedate), 103)
            --WHERE ASSET_NO = @p_asset_no AND INSTALLMENT_NO = @first_max_biling_no
            END;
        END;
        ELSE
        BEGIN
            WHILE (@no <= @tenor / @schedule_month)
            BEGIN

                SET @max_billing_no += 1;

                SET @description = N'Billing ke ' + CAST(@max_billing_no AS NVARCHAR(15)) + N' dari Periode ' + CONVERT(VARCHAR(30), @due_date, 103) + N' Sampai dengan ' + CONVERT(VARCHAR(30), DATEADD(MONTH, (@schedule_month * @no), @first_duedate), 103);

                IF (@first_payment_type = 'ARR')
                BEGIN
                    SET @due_date = DATEADD(MONTH, (@schedule_month * @no), @first_duedate);
                END;

                IF (@billing_mode = 'BY DATE')
                BEGIN
                    IF (DAY(@due_date) < @billing_mode_date)
                    BEGIN
                        SET @billing_date = DATEADD(MONTH, -1, @due_date);
                        IF (DAY(EOMONTH(@billing_date)) < @billing_mode_date)
                        BEGIN
                            SET @billing_date
                                = DATEFROMPARTS(YEAR(@billing_date), MONTH(@billing_date), DAY(EOMONTH(@billing_date)));
                        END;
                        ELSE
                        BEGIN
                            SET @billing_date
                                = DATEFROMPARTS(YEAR(@billing_date), MONTH(@billing_date), @billing_mode_date);
                        END;
                    END;
                    ELSE
                    BEGIN
                        SET @billing_date = DATEFROMPARTS(YEAR(@due_date), MONTH(@due_date), @billing_mode_date);
                    END;
                END;
                ELSE IF (@billing_mode = 'BEFORE DUE')
                BEGIN
                    SET @billing_date = DATEADD(DAY, @billing_mode_date * -1, @due_date);
                END;
                ELSE
                BEGIN
                    SET @billing_date = @due_date;
                END;

                INSERT INTO dbo.MATURITY_AMORTIZATION_HISTORY
                (
                    MATURITY_CODE,
                    INSTALLMENT_NO,
                    ASSET_NO,
                    DUE_DATE,
                    BILLING_DATE,
                    BILLING_AMOUNT,
                    DESCRIPTION,
                    OLD_OR_NEW,
                    --
                    CRE_DATE,
                    CRE_BY,
                    CRE_IP_ADDRESS,
                    MOD_DATE,
                    MOD_BY,
                    MOD_IP_ADDRESS
                )
                VALUES
                (   @p_maturity_code, @max_billing_no, @p_asset_no, @due_date, @billing_date, @lease_rounded_amount,
                    @description, 'NEW', --
                    @p_cre_date, @p_cre_by, @p_cre_ip_address, @p_mod_date, @p_mod_by, @p_mod_ip_address);

                SET @due_date = DATEADD(MONTH, (@schedule_month * @no), @first_duedate);

                SET @no += 1;
            END;
        END;
    END TRY
    BEGIN CATCH
        DECLARE @error INT;

        SET @error = @@error;

        --if (@error = 2627)
        --begin
        --	set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
        --end ;

        IF (LEN(@msg) <> 0)
        BEGIN
            SET @msg = N'V' + N';' + @msg;
        END;
        ELSE
        BEGIN
            IF (ERROR_MESSAGE() LIKE '%V;%' OR ERROR_MESSAGE() LIKE '%E;%')
            BEGIN
                SET @msg = ERROR_MESSAGE();
            END;
            ELSE
            BEGIN
                SET @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + ERROR_MESSAGE();
            END;
        END;

        RAISERROR(@msg, 16, -1);

        RETURN;
    END CATCH;
END;


