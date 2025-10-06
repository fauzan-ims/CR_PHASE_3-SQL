CREATE PROCEDURE [dbo].[xsp_calculate_overdue_penalty_per_agreement_update]
(
	@p_agreement_no			nvarchar(50)
    ,@p_invoice_no			nvarchar(50)
	,@p_asset_no			nvarchar(50)
	,@p_payment_date		datetime
	--
    ,@p_mod_date 			datetime
	,@p_mod_by 				nvarchar(15)
	,@p_mod_ip_address 		nvarchar(15)
)
as
begin	
	
	declare @msg					nvarchar(max)
			,@amount_penalty		decimal(18,2)
			,@payment_amount		decimal(18,2)
			,@payment_ovd_days		int
			,@ovd_days				int
            ,@due_date				datetime
			,@sisa_amort			decimal(18,2)
			,@obligation_date		datetime
			,@billing_no			int
			
	select	@due_date = invoice_due_date
	from	dbo.invoice with (nolock)
	where	invoice_no = @p_invoice_no ;

	select	@billing_no = min(billing_no)
	from	dbo.invoice_detail with (nolock)
	where	invoice_no = @p_invoice_no ;

	select	@payment_amount = sum(payment_amount)
	from	dbo.agreement_invoice_payment with (nolock)
	where	agreement_no		= @p_agreement_no
			and invoice_no		= @p_invoice_no
			and asset_no		= @p_asset_no 

	if (isnull(@payment_amount,0) = 0)
	begin
		set @ovd_days = dbo.xfn_calculate_overdue_days_for_penalty(@due_date, dbo.xfn_get_system_date()) ;
		set @amount_penalty = dbo.xfn_calculate_penalty_per_agreement(@p_agreement_no, dbo.xfn_get_system_date(), @p_invoice_no, @p_asset_no) ;
		set @obligation_date = dbo.xfn_get_system_date()
	end
	else
	begin
		set @ovd_days = dbo.xfn_calculate_overdue_days_for_penalty(@due_date, @p_payment_date) ;
		set @amount_penalty = dbo.xfn_calculate_penalty_per_agreement(@p_agreement_no, @p_payment_date, @p_invoice_no, @p_asset_no) ;
		set @obligation_date = @p_payment_date
	end
	 
	if not exists
	(
		select	1
		from	dbo.agreement_obligation with (nolock)
		where	agreement_no		= @p_agreement_no
				and asset_no		= @p_asset_no
				and invoice_no		= @p_invoice_no 
				and	installment_no	= @billing_no
				and obligation_type = 'OVDP'
	)
	begin 
		exec dbo.xsp_agreement_obligation_insert @p_code				= 0
						                        ,@p_agreement_no		= @p_agreement_no
												,@p_asset_no		    = @p_asset_no	
												,@p_invoice_no		    = @p_invoice_no
						                        ,@p_installment_no		= @billing_no
						                        ,@p_obligation_day		= @ovd_days
						                        ,@p_obligation_date		= @obligation_date
						                        ,@p_obligation_type		= 'OVDP'
												,@p_obligation_name     = 'OVERDUE PENALTY - DAILY'
						                        ,@p_obligation_reff_no  = 'EOD'
						                        ,@p_obligation_amount	= @amount_penalty
						                        ,@p_remarks				= N'RECALCULATE OVERDUE PENALTY'
						                        ,@p_cre_date			= @p_mod_date       
						                        ,@p_cre_by				= @p_mod_by         
						                        ,@p_cre_ip_address		= @p_mod_ip_address 
						                        ,@p_mod_date			= @p_mod_date      
						                        ,@p_mod_by				= @p_mod_by         
						                        ,@p_mod_ip_address		= @p_mod_ip_address 
						
	end
	else 
	begin
		update	dbo.agreement_obligation 
		set		obligation_day			= @ovd_days
				,obligation_amount		= @amount_penalty
				,obligation_date		= @obligation_date
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	agreement_no			= @p_agreement_no
				and asset_no			= @p_asset_no
				and invoice_no			= @p_invoice_no
				and	installment_no		= @billing_no
				and	obligation_type		= 'OVDP'

	end 
	 
end
