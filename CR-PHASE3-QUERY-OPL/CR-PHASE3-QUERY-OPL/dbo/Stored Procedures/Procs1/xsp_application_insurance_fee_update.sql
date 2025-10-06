CREATE PROCEDURE [dbo].[xsp_application_insurance_fee_update]
(
	@p_application_no  nvarchar(50)
	,@p_insurance_type nvarchar(10)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						 nvarchar(max)
			,@total_insurance			 decimal(18, 2)
			,@fee_paid_amount			 decimal(18, 2)
			,@fee_capitalize_amount		 decimal(18, 2)
			,@fee_reduce_disburse_amount decimal(18, 2)
			,@insurance_name			 nvarchar(250) 
			,@currency_code				 nvarchar(3)  ;

	begin try
		select	@total_insurance = isnull(sum(total_sell_amount), 0)
		from	dbo.application_insurance
		where	application_no	   = @p_application_no
				and insurance_type = @p_insurance_type ;

		select	@insurance_name = coverage_name
				,@currency_code = currency_code
		from	dbo.application_insurance
		where	application_no	   = @p_application_no
				and insurance_type = @p_insurance_type ;
		 
		exec dbo.xsp_application_refund_update_is_valid @p_application_no = @p_application_no ;

		if (@total_insurance <> 0)
		begin
			if (@p_insurance_type = 'LIFE')
			begin

				if exists
				(
					select	1
					from	application_fee
					where	application_no = @p_application_no
							and fee_code   = 'LINS'
				)
				begin
					select	@fee_paid_amount = case
												   when fee_payment_type = 'FULL PAID' then @total_insurance
												   else fee_paid_amount
											   end
							,@fee_capitalize_amount = case
														  when fee_payment_type = 'CAPITALIZE' then @total_insurance
														  else fee_capitalize_amount
													  end
							,@fee_reduce_disburse_amount = case
															   when fee_payment_type = 'REDUCE' then @total_insurance
															   else fee_reduce_disburse_amount
														   end
					from	dbo.application_fee
					where	application_no = @p_application_no
							and fee_code   = 'LINS' ;


					update	application_fee
					set		default_fee_amount				= @total_insurance
							,fee_amount						= @total_insurance
							,fee_paid_amount				= @fee_paid_amount
							,fee_capitalize_amount			= @fee_capitalize_amount
							,fee_reduce_disburse_amount		= @fee_reduce_disburse_amount
							--
							,mod_date						= @p_mod_date
							,mod_by							= @p_mod_by
							,mod_ip_address					= @p_mod_ip_address
					where	application_no					= @p_application_no
							and fee_code					= 'LINS' ;
				end ;
				else
				begin
					if not exists
					(
						select	1
						from	dbo.master_fee
						where	code		  = 'LINS'
								and is_active = '1'
					)
					begin
						set @msg = 'Please setting LINS - Life Insurance Fee in Master Fee' ;

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
						,'LINS'
						,0
						,@total_insurance
						,@total_insurance
						,'FULL PAID'
						,@total_insurance
						,0
						,0
						,0
						,'Insurance Fee For ' + @insurance_name
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
			else if (@p_insurance_type = 'CREDIT')
			begin

				if exists
				(
					select	1
					from	application_fee
					where	application_no = @p_application_no
							and fee_code   = 'CRIN'
				)
				begin
					select	@fee_paid_amount = case
												   when fee_payment_type = 'FULL PAID' then @total_insurance
												   else fee_paid_amount
											   end
							,@fee_capitalize_amount = case
														  when fee_payment_type = 'CAPITALIZE' then @total_insurance
														  else fee_capitalize_amount
													  end
							,@fee_reduce_disburse_amount = case
															   when fee_payment_type = 'REDUCE' then @total_insurance
															   else fee_reduce_disburse_amount
														   end
					from	dbo.application_fee
					where	application_no = @p_application_no
							and fee_code   = 'CRIN' ;


					update	application_fee
					set		default_fee_amount				= @total_insurance
							,fee_amount						= @total_insurance
							,fee_paid_amount				= @fee_paid_amount
							,fee_capitalize_amount			= @fee_capitalize_amount
							,fee_reduce_disburse_amount		= @fee_reduce_disburse_amount
							--
							,mod_date						= @p_mod_date
							,mod_by							= @p_mod_by
							,mod_ip_address					= @p_mod_ip_address
					where	application_no					= @p_application_no
							and fee_code					= 'CRIN' ;
				end ;
				else
				begin
					if not exists
					(
						select	1
						from	dbo.master_fee
						where	code		  = 'CRIN'
								and is_active = '1'
					)
					begin
						set @msg = 'Please setting CRIN - Credit Insurance Fee in Master Fee' ;

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
						,'CRIN'
						,0
						,@total_insurance
						,@total_insurance
						,'FULL PAID'
						,@total_insurance
						,0
						,0
						,0
						,'Insurance Fee For ' + @insurance_name
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
		end ;
		else
		begin
			if (@p_insurance_type = 'LIFE')
			begin
				delete dbo.application_fee
				where	application_no = @p_application_no
						and fee_code   = 'LINS' ;
			end
			else if (@p_insurance_type = 'CREDIT')
			begin
				delete dbo.application_fee
				where	application_no = @p_application_no
						and fee_code   = 'CRIN' ;
			end
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;



