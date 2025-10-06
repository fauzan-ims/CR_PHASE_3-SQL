CREATE PROCEDURE [dbo].[xsp_application_first_installment_amount_fee_update]
(
	@p_application_no		nvarchar(50)
	,@p_first_payment_type	nvarchar(3)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg						 nvarchar(max)
			,@total_first_installment_amount			 decimal(18, 2)
			,@fee_paid_amount			 decimal(18, 2)
			,@fee_capitalize_amount		 decimal(18, 2)
			,@fee_reduce_disburse_amount decimal(18, 2)
			,@first_installment_amount_name			 nvarchar(250) 
			,@currency_code				 nvarchar(3) ;

	begin try
		select	@total_first_installment_amount = installment_amount
				,@currency_code = currency_code
		from	dbo.application_amortization aa
				inner join dbo.application_main am on (am.application_no = aa.application_no)
		where	aa.application_no	= @p_application_no
				and installment_no	= 1

		exec dbo.xsp_application_refund_update_is_valid @p_application_no = @p_application_no ;

		if (@total_first_installment_amount <> 0 and @p_first_payment_type = 'ADV')
		begin
			if exists
			(
				select	1
				from	application_fee
				where	application_no = @p_application_no
						and fee_code   = 'FINS'
			)
			begin
				select	@fee_paid_amount = case
											   when fee_payment_type = 'FULL PAID' then @total_first_installment_amount
											   else fee_paid_amount
										   end
						,@fee_capitalize_amount = case
													  when fee_payment_type = 'CAPITALIZE' then @total_first_installment_amount
													  else fee_capitalize_amount
												  end
						,@fee_reduce_disburse_amount = case
														   when fee_payment_type = 'REDUCE' then @total_first_installment_amount
														   else fee_reduce_disburse_amount
													   end
				from	dbo.application_fee
				where	application_no = @p_application_no
						and fee_code   = 'FINS' ;


				update	application_fee
				set		default_fee_amount				= @total_first_installment_amount
						,fee_amount						= @total_first_installment_amount
						,fee_paid_amount				= @fee_paid_amount
						,fee_capitalize_amount			= @fee_capitalize_amount
						,fee_reduce_disburse_amount		= @fee_reduce_disburse_amount
						,currency_code					= @currency_code
						--
						,mod_date						= @p_mod_date
						,mod_by							= @p_mod_by
						,mod_ip_address					= @p_mod_ip_address
				where	application_no					= @p_application_no
						and fee_code					= 'FINS' ;
			end ;
			else
			begin
				if not exists
				(
					select	1
					from	dbo.master_fee
					where	code		  = 'FINS'
							and is_active = '1'
				)
				begin
					set @msg = 'Please setting FINS - First Installment Amount Fee in Master Fee' ;

					raiserror(@msg, 16, 1) ;
				end ;

				insert into dbo.application_fee
				(
					application_no
					,fee_code
					,default_fee_rate
					,default_fee_amount
					,fee_amount
					,fee_payment_type
					,fee_paid_amount
					,fee_reduce_disburse_amount
					,fee_capitalize_amount
					,insurance_year
					,remarks
					,is_from_package
					,is_calculated
					,currency_code
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				values
				(	@p_application_no
					,'FINS'
					,0
					,@total_first_installment_amount
					,@total_first_installment_amount
					,'FULL PAID'
					,@total_first_installment_amount
					,0
					,0
					,0
					,'First Installment Amount Fee'
					,'0'
					,'1'
					,@currency_code
					--
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
				) ;
			end ;
		end ;
		else
		begin
			delete dbo.application_fee
			where	application_no = @p_application_no
					and fee_code   = 'FINS' ;
		end ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		--else if (@error = 547)
		--begin
		--	set @msg = dbo.xfn_get_msg_err_code_already_used() ;
		--end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;




