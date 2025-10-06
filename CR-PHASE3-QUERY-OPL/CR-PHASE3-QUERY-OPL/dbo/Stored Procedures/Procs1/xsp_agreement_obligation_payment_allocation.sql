CREATE PROCEDURE dbo.xsp_agreement_obligation_payment_allocation
(
	@p_agreement_no			nvarchar(50)
	,@p_asset_no			nvarchar(50)
	,@p_invoice_no			nvarchar(50)  = null
	,@p_payment_amount		decimal(18, 2)
	,@p_obligation_type		nvarchar(50)
	,@p_is_waive			nvarchar(1)
	,@p_payment_date		datetime
	,@p_value_date			datetime
	,@p_payment_source_type nvarchar(50)
	,@p_payment_source_no	nvarchar(50)
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
	declare @msg				   nvarchar(max)
			,@installment_no	   int
			,@obligation_code	   nvarchar(50)
			,@os_obligation_amount decimal(18, 2)
			,@allocate_amount	   decimal(18, 2);

	begin try
		if ((
				select	sum(aa.obligation_amount) - sum(parsial.payment_amount)
				from	dbo.agreement_obligation aa
						outer apply
				(
					select	isnull(sum(payment_amount), 0) 'payment_amount'
					from	dbo.agreement_obligation_payment aap
					where	aap.agreement_no	   = aa.agreement_no
							and aap.asset_no	   = asset_no
							and aap.invoice_no	   = invoice_no
							and aap.installment_no = aa.installment_no
				) parsial
				where	aa.agreement_no			 = @p_agreement_no
						and aa.asset_no			 = @p_asset_no
						and aa.invoice_no		 = isnull(@p_invoice_no, aa.invoice_no)
						and aa.obligation_amount > isnull(parsial.payment_amount, 0)
						and aa.obligation_type	 = @p_obligation_type
			) < @p_payment_amount
		   )
		begin --check apakah ada obligasi yang belum terbayar
			set @msg = 'Payment Amount must be less or equal to Outstanding Obligation Amount' ;

			raiserror(@msg, 16, -1) ;
		end ;

		while (@p_payment_amount > 0)
		begin
			select top 1
					@obligation_code = aa.code
					,@os_obligation_amount = aa.obligation_amount - parsial.payment_amount
					,@installment_no = aa.installment_no
			from	dbo.agreement_obligation aa
					outer apply
			(
				select	isnull(sum(aap.payment_amount), 0) 'payment_amount'
				from	dbo.agreement_obligation_payment aap
				where	aap.agreement_no	   = aa.agreement_no
						and aap.asset_no	   = asset_no
						and aap.invoice_no	   = invoice_no
						and aap.installment_no = aa.installment_no
			) parsial
			where	aa.agreement_no			 = @p_agreement_no
					and aa.asset_no			 = @p_asset_no
					and aa.invoice_no		 = isnull(@p_invoice_no, aa.invoice_no)
					and aa.obligation_amount > isnull(parsial.payment_amount, 0)
					and aa.installment_no	 > 0
					and obligation_type		 = @p_obligation_type ;

			if (@p_payment_amount > @os_obligation_amount)
			begin
				set @allocate_amount = @os_obligation_amount ;
				set @p_payment_amount = @p_payment_amount - @os_obligation_amount ;
			end ;
			else
			begin
				set @allocate_amount = @p_payment_amount ;
				set @p_payment_amount = 0 ;
			end ;
			 
			exec dbo.xsp_agreement_obligation_payment_insert @p_id					 = 0
															 ,@p_obligation_code	 = @obligation_code
															 ,@p_agreement_no		 = @p_agreement_no
															 ,@p_asset_no			 = @p_asset_no	
															 ,@p_invoice_no			 = ''	
															 ,@p_installment_no		 = @installment_no
															 ,@p_payment_date		 = @p_payment_date
															 ,@p_value_date			 = @p_value_date
															 ,@p_payment_source_type = @p_payment_source_type
															 ,@p_payment_source_no	 = @p_payment_source_no
															 ,@p_payment_amount		 = @allocate_amount
															 ,@p_is_waive			 = @p_is_waive
															 --
															 ,@p_cre_date			 = @p_cre_date
															 ,@p_cre_by				 = @p_cre_by
															 ,@p_cre_ip_address		 = @p_cre_ip_address
															 ,@p_mod_date			 = @p_mod_date
															 ,@p_mod_by				 = @p_mod_by
															 ,@p_mod_ip_address		 = @p_mod_ip_address ; 
		end ;
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
end ;
