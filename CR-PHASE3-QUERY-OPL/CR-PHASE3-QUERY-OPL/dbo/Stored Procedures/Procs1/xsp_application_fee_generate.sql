CREATE PROCEDURE [dbo].[xsp_application_fee_generate]
(
	@p_application_no  nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						 nvarchar(max)
			,@fee_code					 nvarchar(50)
			,@currency_code				 nvarchar(3)
			,@fee_name					 nvarchar(250)
			,@fn_default_name			 nvarchar(250)
			,@fn_override_name			 nvarchar(250)
			,@calculate_by				 nvarchar(10)
			,@is_fn_override			 nvarchar(1)
			,@calculate_base			 nvarchar(11)
			,@calculate_from			 nvarchar(20)
			,@remarks					 nvarchar(4000)
			,@calculate_base_count		 int			  = 0
			,@fee_rate					 decimal(9, 6)
			,@fee_amount				 decimal(18, 2)
			,@calculate_from_amount		 decimal(18, 2) 
			,@fee_payment_type			 nvarchar(10)
			,@fee_paid_amount			 decimal(18, 2) = 0 
			,@fee_reduce_disburse_amount decimal(18, 2) = 0 
			,@fee_capitalize_amount		 decimal(18, 2) = 0 ;

	begin try
		select	@currency_code = currency_code
		from	dbo.application_main
		where	application_no	 = @p_application_no

		if exists
		(
			select	1
			from	dbo.application_main
			where	application_no	 = @p_application_no
					and isnull(package_code, '') <> ''
		)
		begin -- PACKAGE
			declare cursor_package_fee cursor local fast_forward for
			select	mpf.fee_code
					,mpf.calculate_by
					,mpf.calculate_base
					,mpf.calculate_from
					,mf.description
					,mpf.is_fn_override
					,mpf.fn_default_name
					,mpf.fn_override_name
					,mpf.fee_payment_type
					,mpf.fee_rate
					,mpf.fee_amount
			from	dbo.master_package_fee mpf
					inner join dbo.application_main apm on (apm.package_code = mpf.package_code)
					inner join dbo.master_fee mf on (mf.code = mpf.fee_code)
					outer apply
							(
								select top 1
											mfa.is_fn_override
											,mfa.fn_default_name
											,mfa.fn_override_name
								from		master_fee_amount mfa
								where		mfa.fee_code		   = mpf.fee_code
											and mfa.facility_code  = apm.facility_code
											and mfa.currency_code  = apm.currency_code
											and mfa.effective_date <= apm.APPLICATION_DATE
								order by	mfa.effective_date desc
							) mfa
			where	apm.application_no = @p_application_no ;
			
			open cursor_package_fee ;

			fetch next from cursor_package_fee
			into @fee_code
				 ,@calculate_by
				 ,@calculate_base
				 ,@calculate_from
				 ,@fee_name
				 ,@is_fn_override
				 ,@fn_default_name
				 ,@fn_override_name 
				 ,@fee_payment_type 
				 ,@fee_rate
				 ,@fee_amount;

			while @@fetch_status = 0
			begin
				if (@calculate_base = 'ASSET')
				begin
					select	@calculate_base_count = count(1)
					from	dbo.application_asset
					where	application_no = @p_application_no ;
				end ;
				else
				begin
					set @calculate_base_count = 1 ;
				end ;

				--select	@fee_rate		= mpf.fee_rate
				--		,@fee_amount	= mpf.fee_amount
				--from	dbo.master_package_fee mpf
				--		inner join dbo.application_main apm on (apm.package_code = mpf.package_code)
				--where	apm.application_no = @p_application_no 
				--and mpf.fee_code = @fee_code;
				if (@calculate_by = 'PCT')
				begin
					if (@calculate_from = 'AMOUNT')
					begin
						select	@calculate_from_amount = asset_value
						from	dbo.application_main
						where	application_no = @p_application_no ;
					end ;
					else
					begin
						select	@calculate_from_amount = financing_amount
						from	dbo.application_main
						where	application_no = @p_application_no ;
					end ;

					set @fee_amount = ((@fee_rate/100) * @calculate_from_amount) * @calculate_base_count
				end ;
				else if (@calculate_by = 'AMOUNT')
				begin
					set @fee_rate = 0 ;
					set @fee_amount = @fee_amount * @calculate_base_count;
				end ;
				else -- BY FUNCTION
				begin
				-- exec sp dinamis, function ini return 
					if (@is_fn_override = 0)
					begin
						exec @fee_amount = @fn_default_name @p_application_no
					    set @fee_rate = 0
						--exec @fn_default_name @p_application_no
						--					  ,@fee_rate output
						--					  ,@fee_amount output ;
					end ;
					else
					begin
						exec @fee_amount = @fn_override_name @p_application_no
					    set @fee_rate = 0
						--exec @fn_override_name @p_application_no
						--					   ,@fee_rate output
						--					   ,@fee_amount output ;
					end ; 
				end ;
				
				set @fee_paid_amount = 0
				set @fee_capitalize_amount = 0
				set @fee_reduce_disburse_amount = 0

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
                else
				begin
				    set @fee_paid_amount = @fee_amount
				end
				set @remarks = 'Fee ' + @fee_name ;

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
					,is_fee_paid
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
					,@fee_code
					,@fee_rate
					,@fee_amount
					,@fee_amount
					,@fee_payment_type
					,@fee_paid_amount			
					,@fee_reduce_disburse_amount
					,@fee_capitalize_amount		
					,0
					,@remarks
					,'1'
					,'1'
					,'0'
					,@currency_code
					--
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
				) ;

				fetch next from cursor_package_fee
				into @fee_code
					 ,@calculate_by
					 ,@calculate_base
					 ,@calculate_from
					 ,@fee_name
					 ,@is_fn_override
					 ,@fn_default_name
					 ,@fn_override_name 
					 ,@fee_payment_type 
					 ,@fee_rate
					 ,@fee_amount;
			end ;

			close cursor_package_fee ;
			deallocate cursor_package_fee ;
		end ;
		else if exists
		(	
			select 1 
			from   dbo.application_main
			where  application_no	 = @p_application_no
				   and isnull(plafond_group_code, '') <> ''
		)
		begin -- PLAFOND
			declare cursor_application_fee cursor local fast_forward for
			select	mpf.fee_code
					,case when mpf.DEFAULT_FEE_RATE > 0
						then 'PCT'
						else 'AMOUNT'
					END
					,'APPLICATION' -- hardcode untuk dari plafond
					,'FINANCING' -- hardcode untuk dari plafond
					,mf.description
					,mfa.is_fn_override
					,mfa.fn_default_name
					,mfa.fn_override_name
					,'FULL PAID' -- hardcode untuk dari plafond
					,mpf.default_fee_rate
					,mpf.fee_amount
			from	dbo.plafond_fee mpf
					inner join dbo.application_main apm on (apm.plafond_group_code = mpf.plafond_code)
					inner join dbo.master_fee mf on (mf.code = mpf.fee_code)
					outer apply
								(
									select top 1
												mfa.is_fn_override
												,mfa.fn_default_name
												,mfa.fn_override_name
									from		master_fee_amount mfa
									where		mfa.fee_code		   = mpf.fee_code
												and mfa.facility_code  = apm.facility_code
												and mfa.currency_code  = apm.currency_code
												and mfa.effective_date <= apm.application_date
									order by	mfa.effective_date desc
								) mfa
			where	apm.application_no = @p_application_no 
			and		mpf.fee_paid_on <> 'PLAFOND'

			open cursor_application_fee ;

			fetch next from cursor_application_fee
			into @fee_code
				 ,@calculate_by
				 ,@calculate_base
				 ,@calculate_from
				 ,@fee_name
				 ,@is_fn_override
				 ,@fn_default_name
				 ,@fn_override_name 
				 ,@fee_payment_type 
				 ,@fee_rate
				 ,@fee_amount;

			while @@fetch_status = 0
			begin
				if (@calculate_base = 'ASSET')
				begin
					select	@calculate_base_count = count(1)
					from	dbo.application_asset
					where	application_no = @p_application_no ;
				end ;
				else
				begin
					set @calculate_base_count = 1 ;
				end ;

				--select	@fee_rate		= mpf.default_fee_rate
				--		,@fee_amount	= mpf.default_fee_amount
				--from	dbo.plafond_fee mpf
				--		inner join dbo.application_main apm on (apm.plafond_group_code = mpf.plafond_code)
				--where	apm.application_no = @p_application_no ;

				if (@calculate_by = 'PCT')
				begin
					
					if (@calculate_from = 'AMOUNT')
					begin
						select	@calculate_from_amount = asset_value
						from	dbo.application_main
						where	application_no = @p_application_no ;
					end ;
					else
					begin
						select	@calculate_from_amount = financing_amount
						from	dbo.application_main
						where	application_no = @p_application_no ;
					end ;
					 
					set @fee_amount = ((@fee_rate/100) * @calculate_from_amount)  * @calculate_base_count ;
				end ;
				else if (@calculate_by = 'AMOUNT')
				begin
					set @fee_rate = 0 ;
					set @fee_amount = @fee_amount * @calculate_base_count ;
				end ;
				else -- BY FUNCTION
				begin
					-- exec sp dinamis, function ini return 
					if (@is_fn_override = 0)
					begin
						exec @fee_amount = @fn_default_name @p_application_no
					    set @fee_rate = 0
						--exec @fn_default_name @p_application_no
						--					  ,@fee_rate output
						--					  ,@fee_amount output ;
					end ;
					else
					begin
						exec @fee_amount = @fn_override_name @p_application_no
					    set @fee_rate = 0
						--exec @fn_override_name @p_application_no
						--					   ,@fee_rate output
						--					   ,@fee_amount output ;
					end ;
				end ;

				set @fee_paid_amount = 0
				set @fee_capitalize_amount = 0
				set @fee_reduce_disburse_amount = 0

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
                else
				begin
				    set @fee_paid_amount = @fee_amount
				end
				set @remarks = 'Fee ' + @fee_name ;

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
					,is_fee_paid
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
					,@fee_code
					,@fee_rate
					,@fee_amount
					,@fee_amount
					,@fee_payment_type
					,@fee_paid_amount			
					,@fee_reduce_disburse_amount
					,@fee_capitalize_amount		
					,0
					,@remarks
					,'0'
					,'1'
					,'0'
					,@currency_code
					--
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
				) ;

				fetch next from cursor_application_fee
				into @fee_code
					 ,@calculate_by
					 ,@calculate_base
					 ,@calculate_from
					 ,@fee_name
					 ,@is_fn_override
					 ,@fn_default_name
					 ,@fn_override_name 
					 ,@fee_payment_type
					 ,@fee_rate
					 ,@fee_amount;
			end ;

			close cursor_application_fee ;
			deallocate cursor_application_fee ;
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









