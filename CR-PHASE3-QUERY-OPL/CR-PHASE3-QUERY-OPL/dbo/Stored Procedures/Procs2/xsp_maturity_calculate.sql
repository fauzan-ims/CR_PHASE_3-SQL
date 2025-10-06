-- Stored Procedure

CREATE PROCEDURE dbo.xsp_maturity_calculate
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
    declare @msg						nvarchar(max),
            @due_date					datetime,
            @no							int,
            @tenor						int,
            @schedule_month				int,
            @first_duedate				datetime,
            @billing_date				datetime,
            @billing_mode				nvarchar(10),
            @billing_mode_date			int,
            @lease_rounded_amount		decimal(18, 2),
            @description				nvarchar(4000),
            @max_billing_no				int,
            @agreement_no				nvarchar(50),
            @first_payment_type			nvarchar(3),
            @rounding_type				nvarchar(50),
            @rounding_value				decimal(18, 2),
            @last_biling_amount			decimal(18, 2),
            @is_eomonth					nvarchar(1),
            @first_max_biling_no		int,
            @max_billing_no_after		int,
            @add_periode				int,
			@due_date_prorate			datetime,
			@billing_date_prorate		datetime,
			@rental_amount_prorate		decimal(18,2),
			@rental_amount				decimal(18,2),
			@invoice_no					nvarchar(50)
			,@schedule_month_ags		int

    BEGIN TRY

        SET @tenor = @p_periode;

        -- mengambil multipier di master payment schedule
        select @lease_rounded_amount	= aa.monthly_rental_rounded_amount,
			   @rental_amount			= aa.monthly_rental_rounded_amount,
               @billing_mode			= aa.billing_mode,
               @billing_mode_date		= aa.billing_mode_date,
               @agreement_no			= am.agreement_no,
               @first_payment_type		= am.first_payment_type,
               @rounding_type			= am.round_type,
               @rounding_value			= am.round_amount,
			   @schedule_month_ags		= mbt.multiplier
        from	dbo.agreement_asset aa
        inner join dbo.agreement_main am on (am.agreement_no = aa.agreement_no)
		inner join dbo.master_billing_type mbt on mbt.code = aa.billing_type
        where	aa.asset_no				= @p_asset_no;

        select	@schedule_month	= multiplier,
				@add_periode	= additional_periode
        from	dbo.maturity m
        inner join dbo.master_billing_type mbt    on (mbt.code = m.new_billing_type)
        where	m.code			= @p_maturity_code;

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


        select top 1
               @max_billing_no		= billing_no,
               @first_max_biling_no = billing_no - 1,
               @due_date			= due_date,
               @last_biling_amount	= billing_amount,
			   @invoice_no			= replace(invoice_no,'.','/')
        from dbo.agreement_asset_amortization
        where asset_no	= @p_asset_no
        order by billing_no desc;

        if (@first_payment_type = 'ADV')
        begin
            select @due_date = maturity_date
            from dbo.agreement_information
            where agreement_no = @agreement_no;
        end;

        set @no = 1;
        set @first_duedate = @due_date;

        -- @schedule_month ini adalah per berapa bulan schedule yg akan terbentuk (cth: per 1 bulan/ per 2 bulan).
        -- @tenor jumlah periode utang.

        if ((@rental_amount*@schedule_month_ags) <> (@last_biling_amount))
        begin
            if exists
            (
                select	1
                from	dbo.agreement_asset_amortization
                where	asset_no		= @p_asset_no
						and billing_no	= @max_billing_no
						and isnull(invoice_no, '') <> ''
            )
            begin
                set @msg = 'This Asset Cannot Be Extend, Please Cancel Invoice '+@invoice_no+' For Prorate Amount On Last Billing';
                raiserror(@msg, 16, -1);
            end;
            else
            begin

				if (@first_payment_type = 'ARR')
				begin
				    select	top 1
							@first_duedate	= due_date
				    from	dbo.agreement_asset_amortization
				    where	asset_no		= @p_asset_no
							and billing_no	< @max_billing_no 
				    order by billing_no desc;
				end

                delete dbo.maturity_amortization_history
                where	asset_no		= @p_asset_no
                and		installment_no	= @max_billing_no;

                select	@due_date		= max(due_date)
                from	dbo.maturity_amortization_history
                where	asset_no		= @p_asset_no
				and		maturity_code	= @p_maturity_code
                and		old_or_new		= 'OLD';

				select @due_date_prorate		= dateadd(month, @add_periode, due_date),
						@billing_date_prorate	= dateadd(month, @add_periode, billing_date),
						@rental_amount_prorate	= billing_amount
				from	dbo.agreement_asset_amortization
				where	asset_no = @p_asset_no;

                while (@no <= @tenor / @schedule_month)
                begin

                    SET @first_max_biling_no += 1;

                    SET @description = N'Billing ke ' + CAST(@first_max_biling_no AS NVARCHAR(15)) + N' dari Periode ' + CONVERT(VARCHAR(30), @due_date, 103) + N' Sampai dengan '+ CONVERT(VARCHAR(30), DATEADD(MONTH, (@schedule_month * @no), @first_duedate), 103);

                    IF (@first_payment_type = 'ARR')
                    begin
                        select @is_eomonth = (dbo.xfn_get_due_date_eomonth(@p_asset_no)); --FUNCTION BUAT CHECK APAKAH DUE DATE ASSET TERSEBUT DI AKHIR BULAN SEMUA (raffy: Cr_Priority)

                        if @is_eomonth = '0' -- JIKA 0 BERARTI DUE DATE TIDAK DI AKHIR BULAN SEMUA
                        begin
                            set @due_date = dateadd(month, (@schedule_month * @no), @first_duedate);
                        end;
                        else
                        begin
                            set @due_date = eomonth(dateadd(month, (@schedule_month * @no), @first_duedate));
                        end;
                    end;

                    if (@billing_mode = 'BY DATE')
                    begin
                        if (day(@due_date) < @billing_mode_date)
                        begin
                            set @billing_date = dateadd(month, -1, @due_date);
                            if (day(eomonth(@billing_date)) < @billing_mode_date)
                            begin
                                set @billing_date = datefromparts(year(@billing_date),month(@billing_date),day(eomonth(@billing_date)));
                            end;
                            else
                            begin
                                set @billing_date
                                    = datefromparts(year(@billing_date), month(@billing_date), @billing_mode_date);
                            end;
                        end;
                        else
                        begin
                            set @billing_date = datefromparts(year(@due_date), month(@due_date), @billing_mode_date);
                        end;
                    end;
                    else if (@billing_mode = 'before due')
                    begin
                        set @billing_date = dateadd(day, @billing_mode_date * -1, @due_date);
                    end;
                    else
                    begin
                        set @billing_date = @due_date;
                    end;

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
                    (   @p_maturity_code, 
						@first_max_biling_no, 
						@p_asset_no, 
						@due_date, 
						@billing_date,
                        @lease_rounded_amount, 
						@description, 
						'NEW', 
						--
                        @p_cre_date, @p_cre_by, @p_cre_ip_address, @p_mod_date, @p_mod_by, @p_mod_ip_address);

                    SET @due_date = DATEADD(MONTH, (@schedule_month * @no), @first_duedate);

                    SET @no += 1;
                END;



                select	@max_billing_no_after	= max(installment_no)
                from	dbo.maturity_amortization_history
                where	asset_no				= @p_asset_no 
						and maturity_code		= @p_maturity_code;				

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
                (   @p_maturity_code, 
					@max_billing_no_after + 1, 
					@p_asset_no, 
					@due_date_prorate, 
					@billing_date_prorate,
                    @rental_amount_prorate,
                    'Billing ke ' + CAST(@max_billing_no_after + 1 AS NVARCHAR(15)) + ' dari Periode '+ CONVERT(VARCHAR(30), @due_date, 103) + ' Sampai dengan '+ CONVERT(VARCHAR(30), @due_date_prorate, 103), 
					'NEW',
                    --
                    @p_cre_date, @p_cre_by, @p_cre_ip_address, @p_mod_date, @p_mod_by, @p_mod_ip_address);

            END;
        END;
        ELSE
        BEGIN
		SELECT @no, @tenor, @schedule_month, @max_billing_no
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
                (   @p_maturity_code, 
					@max_billing_no,
					@p_asset_no, 
					@due_date, 
					@billing_date, 
					@lease_rounded_amount,
                    @description, 
					'NEW', 
					--
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


