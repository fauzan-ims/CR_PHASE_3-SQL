CREATE PROCEDURE dbo.xsp_agreement_amortization_payment_sync 
(
	@p_id				bigint
	,@p_Type			nvarchar(10)
	--,@p_approval_reff		nvarchar(250)
	--,@p_approval_remark	nvarchar(4000)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@msg						nvarchar(max)
			,@agreement_no				nvarchar(50)
			,@installment_no			int
			,@payment_date				datetime
			,@value_date				datetime
			,@payment_source_type		nvarchar(10)
			,@payment_source_no			nvarchar(50)
			,@payment_amount			decimal(18, 2)
			,@principal_amount			decimal(18, 2)
			,@interest_amount			decimal(18, 2)

	begin try
		
		if @p_Type in ('CASHIER','REVERSAL CASHIER')
		begin
		    select	@agreement_no			= ct.agreement_no
				   ,@installment_no			= ctd.installment_no
				   ,@payment_date			= ct.cashier_trx_date
				   ,@value_date				= ct.cashier_value_date
				   ,@payment_source_type	= @p_type
				   ,@payment_source_no		= ct.code
				   ,@principal_amount		= 0
				   ,@interest_amount		= 0
				   ,@payment_amount			= ctd.orig_amount
			from	dbo.cashier_transaction_detail ctd
					inner join dbo.cashier_transaction ct on (ct.code = ctd.cashier_transaction_code)
			where	id	= @p_id
		end
		else if (@p_Type IN ('DEPOSIT', 'REVERSAL DEPOSIT'))
		begin
		    select	@agreement_no			= da.agreement_no
				   ,@installment_no			= dad.installment_no
				   ,@payment_date			= da.allocation_trx_date
				   ,@value_date				= da.allocation_value_date
				   ,@payment_source_type	= @p_type
				   ,@payment_source_no		= da.code
				   ,@principal_amount		= 0
				   ,@interest_amount		= 0
				   ,@payment_amount			= dad.orig_amount
			from	dbo.deposit_allocation_detail dad
					inner join dbo.deposit_allocation da on (da.code = dad.deposit_allocation_code)
			where	id	= @p_id
		end
		else if (@p_Type IN ('SUSPEND','REVERSAL SUSPEND'))
		begin
		    select	@agreement_no			= sa.agreement_no
				   ,@installment_no			= sad.installment_no
				   ,@payment_date			= sa.allocation_trx_date
				   ,@value_date				= sa.allocation_value_date
				   ,@payment_source_type	= @p_type
				   ,@payment_source_no		= sa.code
				   ,@principal_amount		= 0
				   ,@interest_amount		= 0
				   ,@payment_amount			= sad.orig_amount
			from	dbo.suspend_allocation_detail sad
					inner join dbo.suspend_allocation sa on (sa.code = sad.suspend_allocation_code)
			where	id	= @p_id
		end
		
		if @p_type in ('REVERSAL CASHIER', 'REVERSAL SUSPEND', 'REVERSAL DEPOSIT')
		begin
			set @payment_amount = @payment_amount * -1
		end
		else
		begin
			set @payment_amount = @payment_amount
		end

		exec dbo.xsp_fin_interface_agreement_amortization_payment_insert @p_id						= 0
																		 ,@p_agreement_no			= @agreement_no
																		 ,@p_installment_no			= @installment_no
																		 ,@p_payment_date			= @payment_date			
																		 ,@p_value_date				= @value_date			
																		 ,@p_payment_source_type	= @payment_source_type	
																		 ,@p_payment_source_no		= @payment_source_no		
																		 ,@p_payment_amount			= @payment_amount		
																		 ,@p_principal_amount		= @principal_amount		
																		 ,@p_interest_amount		= @interest_amount		
																		 ,@p_cre_date				= @p_cre_date		
																		 ,@p_cre_by					= @p_cre_by			
																		 ,@p_cre_ip_address			= @p_cre_ip_address
																		 ,@p_mod_date				= @p_mod_date		
																		 ,@p_mod_by					= @p_mod_by			
																		 ,@p_mod_ip_address			= @p_mod_ip_address
		
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;

end




