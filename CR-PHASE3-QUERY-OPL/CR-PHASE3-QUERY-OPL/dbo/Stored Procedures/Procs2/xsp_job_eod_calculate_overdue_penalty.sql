/*
exec dbo.xsp_job_eod_calculate_overdue_penalty
*/
CREATE PROCEDURE dbo.xsp_job_eod_calculate_overdue_penalty
as
begin

	declare @msg			 nvarchar(max)
			,@eod_date		 datetime
			,@mod_date		 datetime	   = getdate()
			,@mod_by		 nvarchar(15)  = 'EOD1'
			,@mod_ip_address nvarchar(15)  = 'SYSTEM'
			,@billing_no	 nvarchar(50)
			,@agreement_no	 nvarchar(50)
			,@amount_penalty decimal(18, 2)
			,@ovd_days		 int
			,@due_date		 datetime
			,@charges_name	 nvarchar(250) = 'OVERDUE PENALTY - DAILY'
			,@invoice_no	 nvarchar(50)
			,@asset_no		 nvarchar(50) ;

	select  @eod_date	= value
	from	dbo.sys_global_param
	where	code		= 'SYSDATE'

	begin try
		begin 
			-- Hari - 15.Jul.2023 07:57 PM --	perubahan cara hitung per invoice detail per agreement, asset dan billing
			declare c_amort cursor local fast_forward read_only for
			select		 aiv.invoice_no
						,aiv.invoice_due_date 
			from		dbo.invoice					  aiv
			where		aiv.invoice_status	 = 'POST'
						and aiv.invoice_type = 'RENTAL'
						and cast(aiv.invoice_due_date as date) < cast(@eod_date as date)

			open c_amort
			fetch c_amort
			into	@invoice_no	
					,@due_date

			while @@fetch_status = 0  
			begin
				set @ovd_days = dbo.xfn_calculate_overdue_days_for_penalty(@due_date, @eod_date) ;

				declare c_amort_detail cursor local fast_forward read_only for
				select		 aid.agreement_no
							,aid.asset_no
							,aid.billing_no
				from		dbo.invoice_detail aid
				where		aid.invoice_no = @invoice_no

				open c_amort_detail
				fetch c_amort_detail
				into	@agreement_no
						,@asset_no
						,@billing_no

				while @@fetch_status = 0  
				begin

					set @amount_penalty = dbo.xfn_calculate_penalty_per_agreement(@agreement_no, @eod_date, @invoice_no, @asset_no) ;
		 
					if (@amount_penalty > 0)
					begin
						if not exists
						(
							select	1
							from	dbo.agreement_obligation with (nolock)
							where	agreement_no		= @agreement_no
									and asset_no		= @asset_no
									and invoice_no		= @invoice_no 
									and installment_no  = @billing_no
									and obligation_type = 'OVDP'
						)
						begin 
							exec dbo.xsp_agreement_obligation_insert @p_code				= 0
																	 ,@p_agreement_no		= @agreement_no
																	 ,@p_asset_no		    = @asset_no	
																	 ,@p_invoice_no		    = @invoice_no
																	 ,@p_installment_no		= @billing_no
																	 ,@p_obligation_day		= @ovd_days
																	 ,@p_obligation_date	= @eod_date
																	 ,@p_obligation_type	= 'OVDP'
																	 ,@p_obligation_name    = @charges_name
																	 ,@p_obligation_reff_no = 'EOD'
																	 ,@p_obligation_amount	= @amount_penalty
																	 ,@p_remarks			= N'EOD OVERDUE PENALTY'
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
							where	agreement_no			= @agreement_no
									and asset_no			= @asset_no
									and invoice_no			= @invoice_no
									and	installment_no		= @billing_no
									and	obligation_type		= 'OVDP'

						end
					
						set @amount_penalty = 0
					end

					fetch c_amort_detail
					into @agreement_no
						,@asset_no
						,@billing_no
				end
				close c_amort_detail
				deallocate c_amort_detail

					
				set @ovd_days = 0

				---
			fetch c_amort
			into @invoice_no	
				,@due_date

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
	

