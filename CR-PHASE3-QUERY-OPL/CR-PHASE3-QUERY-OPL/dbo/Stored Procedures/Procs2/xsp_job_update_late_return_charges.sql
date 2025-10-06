/*
exec dbo.xsp_job_update_late_return_charges
*/
CREATE PROCEDURE [dbo].[xsp_job_update_late_return_charges]
(
	@p_agreement_no nvarchar(50)
)
as
begin
	declare @msg				   nvarchar(max)
			,@eod_date			   datetime
			,@mod_date			   datetime		  = getdate()
			,@mod_by			   nvarchar(15)	  = N'EOD'
			,@mod_ip_address	   nvarchar(15)	  = N'SYSTEM' 
			,@amount_penalty	   decimal(18, 2)
			,@lease_rounded_amount decimal(18, 2)
			,@ovd_days			   int
			,@maturity_date		   datetime
			,@return_date		   datetime
			,@charges_name		   nvarchar(250)  = N'LATE RETURN ASSET PENALTY - DAILY'
			,@asset_no			   nvarchar(50)
			,@charges_pct		   decimal(9, 6)
			,@charges_amount	   decimal(18, 2)
			,@default_flag		   nvarchar(20)
            
	select  @eod_date	= value
	from	dbo.sys_global_param
	where	code		= 'SYSDATE'

	begin try
		begin  
			declare c_amort cursor local fast_forward read_only for
			select	aa.asset_no
					,ai.maturity_date
					,aa.lease_rounded_amount
					,aa.return_date 
			from	dbo.agreement_asset aa
					inner join dbo.agreement_information ai on (aa.agreement_no = ai.agreement_no)
			where	aa.asset_status		<> 'RETURN'
 					and aa.agreement_no = @p_agreement_no


			open c_amort
			fetch c_amort
			into	@asset_no
					,@maturity_date	
					,@lease_rounded_amount
					,@return_date

			while @@fetch_status = 0  
			begin
				if (@return_date is not null)
				begin
					set @ovd_days = dbo.xfn_calculate_overdue_days_for_penalty(@maturity_date, @return_date) ;
				end ;
				else
				begin
					set @ovd_days = dbo.xfn_calculate_overdue_days_for_penalty(@maturity_date, @eod_date) ;
				end ;
				 
				-- calculate penalty
				begin
					select	top 1
							@charges_pct = ac.charges_rate / 100
							,@charges_amount = ac.charges_amount
							,@default_flag = ac.calculate_by
					from	agreement_charges ac with (nolock)
					where	ac.agreement_no		= @p_agreement_no
							and ac.charges_code = 'LRAP' ;

					if @default_flag = 'PCT'
						set @amount_penalty = @lease_rounded_amount * @ovd_days * @charges_pct ;
					else if @default_flag = 'AMOUNT'
						set @amount_penalty = @ovd_days * @charges_amount ;
				end ;
		
				if (@amount_penalty > 0)
				begin
					if not exists
					(
						select	1
						from	dbo.agreement_obligation with (nolock)
						where	agreement_no		= @p_agreement_no
								and asset_no		= @asset_no 
								and obligation_type = 'LRAP'
					)
					begin 
						exec dbo.xsp_agreement_obligation_insert @p_code				= 0
						                                         ,@p_agreement_no		= @p_agreement_no
																 ,@p_asset_no		    = @asset_no	
																 ,@p_invoice_no		    = 'LATE RETURN ASSET PENALTY'
						                                         ,@p_installment_no		= 0
						                                         ,@p_obligation_day		= @ovd_days
						                                         ,@p_obligation_date	= @eod_date
						                                         ,@p_obligation_type	= 'LRAP'
																 ,@p_obligation_name    = @charges_name
						                                         ,@p_obligation_reff_no = 'EOD'
						                                         ,@p_obligation_amount	= @amount_penalty
						                                         ,@p_remarks			= N'EOD LATE RETURN ASSET PENALTY'
						                                         ,@p_cre_date			= @mod_date       
						                                         ,@p_cre_by				= @mod_by         
						                                         ,@p_cre_ip_address		= @mod_ip_address 
						                                         ,@p_mod_date			= @mod_date      
						                                         ,@p_mod_by				= @mod_by         
						                                         ,@p_mod_ip_address		= @mod_ip_address 
						
					end
					else 
					begin
					    update	dbo.agreement_obligation 
						set		obligation_day			= @ovd_days
								,obligation_amount		= @amount_penalty
								,obligation_date		= @eod_date
								,mod_date				= @mod_date
								,mod_by					= @mod_by
								,mod_ip_address			= @mod_ip_address
						where	agreement_no			= @p_agreement_no
								and asset_no			= @asset_no
								and	obligation_type		= 'LRAP'

					end
				end

				update	dbo.agreement_information
				set		lra_days				= @ovd_days
						,lra_penalty_amount		= @amount_penalty
						,mod_date				= @mod_date
						,mod_by					= @mod_by
						,mod_ip_address			= @mod_ip_address
				where	agreement_no			= @p_agreement_no ;
					
					set @amount_penalty = 0
					set @ovd_days = 0
					set @charges_pct = 0
					set @charges_amount = 0
					set @default_flag = null

				fetch c_amort
				into	@asset_no
						,@maturity_date	
						,@lease_rounded_amount
						,@return_date
			end
			close c_amort
			deallocate c_amort

		end
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
	

