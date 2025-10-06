CREATE FUNCTION [dbo].[fn_CalcCreditRefund]
(
    @agreement_no		nvarchar(50),
    @asset_no			nvarchar(50),
    @et_date			date,
	@first_payment_type	nvarchar(15),
	@multiplier			int
)
RETURNS @Result TABLE
(
    refund_amount DECIMAL(18,2),
    credit_amount DECIMAL(18,2)
)
AS
begin
      DECLARE 
        @billing_amount DECIMAL(18,2),
        @due_date DATE,
        @invoice_status NVARCHAR(10),
        @period_start DATE,
        @period_end DATE,
        @days_month INT,
        @days_used INT,
        @refund_amount DECIMAL(18,2) = 0,
        @credit_amount DECIMAL(18,2) = 0;

    DECLARE cur_billing CURSOR FAST_FORWARD READ_ONLY FOR
    select 
        a.billing_amount,
        a.due_date,
        i.invoice_status
    from dbo.agreement_asset_amortization a
    inner join dbo.invoice i on a.invoice_no = i.invoice_no
    where a.agreement_no = @agreement_no
      and a.asset_no = @asset_no
      and i.invoice_status in ('POST','PAID')
    order by a.due_date;

    open cur_billing;
    fetch next from cur_billing into @billing_amount, @due_date, @invoice_status;

    while @@fetch_status = 0
    begin
        set @period_start = case when @first_payment_type = 'ARR' then dateadd(month, -@multiplier, @due_date)
								else @due_date
							end
        set @period_end   = case when @first_payment_type = 'ADV' then dateadd(month, @multiplier, @due_date)
								else @due_date
							end;
        set @days_month   = datediff(day, @period_start, @period_end);

        -- hitung hari terpakai
        if (@et_date < @period_start)
            set @days_used = 0;
        else if (@et_date >= @period_end)
            set @days_used = @days_month;
        else
            set @days_used = datediff(day, @period_start, @et_date) + 1;

        -- case future (et sebelum periode)
        if (@period_start >= @et_date)
        begin
            if (@invoice_status = 'PAID')
                set @refund_amount += @billing_amount; 
            else
                set @credit_amount += @billing_amount; 
        end
        -- case past (et sesudah periode)
        else if (@period_end <= @et_date)
        begin
            set @refund_amount = 0;
			set @credit_amount = 0;-- sudah dipakai penuh, tidak ada refund/credit
        end
        -- case et di tengah periode
        else
        begin
            if (@invoice_status = 'PAID')
            begin
                -- refund = sisa hari
                set @refund_amount += round(@billing_amount * ((@days_month - @days_used) * 1.0) / nullif(@days_month,0), 0);
            end
            else
            begin
                -- credit = sisa hari
                set @credit_amount += round(@billing_amount * ((@days_month - @days_used) * 1.0) / nullif(@days_month,0), 0);
            end
        end

        fetch next from cur_billing into @billing_amount, @due_date, @invoice_status;
    end

    close cur_billing;
    deallocate cur_billing;

    insert into @result(refund_amount, credit_amount)
    values(@refund_amount, @credit_amount);

    return;
END
