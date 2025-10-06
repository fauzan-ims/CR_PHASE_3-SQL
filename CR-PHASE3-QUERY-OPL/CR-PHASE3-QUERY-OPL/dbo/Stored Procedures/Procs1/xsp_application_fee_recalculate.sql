CREATE PROCEDURE [dbo].[xsp_application_fee_recalculate]
(
	@p_application_no nvarchar(50)
)
as
begin
	declare @msg			   nvarchar(max)
			,@facility_code	   nvarchar(50)
			,@currency_code	   nvarchar(3)
			,@eff_date		   datetime
			,@asset_amount	   decimal(18, 2)
			,@financing_amount decimal(18, 2)
			,@calculate_by	   nvarchar(10)
			,@default_rate	   decimal(9, 6)
			,@default_amount   decimal(18, 2)
			,@fee_amount	   decimal(18, 2)
			,@fee_amount_awal  decimal(18, 2)
			,@plafond_code	   nvarchar(50)
			,@fee_code		   nvarchar(50)
			,@asset_count	   int
			,@package_code	   nvarchar(50) 
			,@fee_payment_type	nvarchar(10)
			,@fee_paid_amount  			  decimal(18, 2)
			,@fee_capitalize_amount  	  decimal(18, 2)
			,@fee_reduce_disburse_amount  decimal(18, 2)

	begin try
		select	@asset_count = count(asset_no)
		from	dbo.application_asset
		where	application_no = @p_application_no ;

		select @package_code = isnull(package_code, '')
				,@plafond_code = isnull(plafond_group_code, '')
		from	application_main
		where	application_no = @p_application_no ;

		declare cursor_name cursor fast_forward read_only for
		select	fee_code
				,fee_amount
				,am.facility_code
				,am.currency_code
				,am.application_date
				,am.asset_value
				,am.loan_amount
				,af.fee_payment_type
		from	dbo.application_fee af
				inner join dbo.application_main am on (am.application_no = af.application_no)
				inner join dbo.master_fee mf on (
													mf.code				 = af.fee_code
													and mf.is_calculated = '0'
												)
		where	af.application_no = @p_application_no ;

		open cursor_name ;

		fetch next from cursor_name
		into @fee_code
			 ,@fee_amount_awal
			 ,@facility_code
			 ,@currency_code
			 ,@eff_date
			 ,@asset_amount
			 ,@financing_amount 
			 ,@fee_payment_type

		while @@fetch_status = 0
		begin
			exec dbo.xsp_sys_master_fee_get_amount @p_facility_code		= @facility_code
												   ,@p_currency_code	= @currency_code
												   ,@p_eff_date			= @eff_date
												   ,@p_asset_count		= @asset_count
												   ,@p_asset_amount		= @asset_amount
												   ,@p_financing_amount = @financing_amount
												   ,@p_fee_code			= @fee_code
												   ,@p_calculate_by		= @calculate_by output
												   ,@p_default_rate		= @default_rate output
												   ,@p_default_amount	= @default_amount output
												   ,@p_fee_amount		= @fee_amount output
												   ,@p_plafond_code		= @plafond_code 
												   ,@p_package_code		= @package_code 
												   ,@p_reff_no			= @p_application_no

			 
			if (@fee_amount_awal <> @fee_amount)
			begin
				
				set @fee_paid_amount = 0
				set @fee_capitalize_amount = 0
				set @fee_reduce_disburse_amount = 0

				if (@fee_payment_type <> 'PARTIAL')
				begin
					if (@fee_payment_type = 'FULL PAID')
					begin
						set @fee_paid_amount = @fee_amount
					end
					else if (@fee_payment_type = 'CAPITALIZE')
					begin
						set @fee_capitalize_amount = @fee_amount
					end
					else if (@fee_payment_type = 'REDUCE')
					begin
						set @fee_reduce_disburse_amount = @fee_amount
					end

				
					update	application_fee
					set		fee_amount					= @fee_amount
							,default_fee_rate			= @default_rate
							,default_fee_amount			= @fee_amount
							,fee_paid_amount			= @fee_paid_amount
							,fee_capitalize_amount		= @fee_capitalize_amount
							,fee_reduce_disburse_amount = @fee_reduce_disburse_amount
					where	application_no				= @p_application_no
							and fee_code				= @fee_code ; 
				end
				else
				begin
					update	application_fee
					set		fee_amount					= @fee_amount
							,default_fee_rate			= @default_rate
							,default_fee_amount			= @fee_amount
					where	application_no				= @p_application_no
							and fee_code				= @fee_code ; 

				end

			end ;

			fetch next from cursor_name
			into @fee_code
				 ,@fee_amount_awal
				 ,@facility_code
				 ,@currency_code
				 ,@eff_date
				 ,@asset_amount
				 ,@financing_amount 
				 ,@fee_payment_type
		end ;

		close cursor_name ;
		deallocate cursor_name ;
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



