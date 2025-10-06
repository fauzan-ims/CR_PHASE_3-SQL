/*
exec xsp_job_eod_agreement_deposit_revenue
*/
-- Louis Handry 27/02/2023 20:44:35 -- 
create procedure dbo.xsp_job_eod_agreement_deposit_revenue
as
begin
	declare @msg				   nvarchar(max)
			,@max_day			   int
			,@system_date		   datetime		 = dbo.xfn_get_system_date()
			,@mod_date			   datetime		 = getdate()
			,@mod_by			   nvarchar(15)	 = 'EOD'
			,@mod_ip_address	   nvarchar(15)	 = '127.0.0.1'
			,@branch_code		   nvarchar(50)
			,@branch_name		   nvarchar(250)
			,@revenue_amount	   decimal(18, 2)
			,@deposit_revenue_code nvarchar(50)
			,@deposit_code		   nvarchar(50)
			,@agreement_no		   nvarchar(50)
			,@deposit_type		   nvarchar(15)
			,@currency_code		   nvarchar(3) 

	begin try
		begin
			select	@max_day = cast(value as bigint)
			from	dbo.sys_global_param
			where	code = 'MAXDYDPS' ;

			declare curagreementinformation cursor fast_forward read_only for
			select	adm.agreement_no
					,adm.branch_code
					,adm.branch_name
					,adm.deposit_amount
					,am.currency_code
					,adm.code
					,adm.deposit_type
			from	agreement_deposit_main adm
					inner join agreement_main am on (am.agreement_no			= adm.agreement_no)
					inner join dbo.agreement_information ai on (ai.agreement_no = adm.agreement_no)
			where	agreement_status												  = 'TERMINATE'
					and adm.deposit_amount											  > 0
					and ai.ovd_rental_amount										  = 0
					and ai.ovd_rental_amount										  = 0
					and ai.os_rental_amount											  = 0
					and datediff(day, am.termination_date, dbo.xfn_get_system_date()) >= @max_day ;

			open curagreementinformation ;

			fetch next from curagreementinformation
			into @agreement_no
				,@branch_code	  
				,@branch_name	  
				,@revenue_amount  
				,@currency_code
				,@deposit_code
				,@deposit_type

			while @@fetch_status = 0
			begin 
				exec dbo.xsp_opl_interface_deposit_revenue_insert @p_code			  = @deposit_revenue_code output
																  ,@p_branch_code	  = @branch_code
																  ,@p_branch_name	  = @branch_name
																  ,@p_revenue_status  = N'HOLD'
																  ,@p_revenue_date	  = @system_date
																  ,@p_revenue_amount  = @revenue_amount
																  ,@p_revenue_remarks = N'Automatic Deposit to Revenue'
																  ,@p_agreement_no	  = @agreement_no
																  ,@p_currency_code   = @currency_code
																  ,@p_exch_rate		  = 1
																  --
																  ,@p_cre_date		  = @mod_date		
																  ,@p_cre_by		  = @mod_by		
																  ,@p_cre_ip_address  = @mod_ip_address
																  ,@p_mod_date		  = @mod_date		
																  ,@p_mod_by		  = @mod_by		
																  ,@p_mod_ip_address  = @mod_ip_address 

				exec dbo.xsp_opl_interface_deposit_revenue_detail_insert @p_deposit_revenue_code	= @deposit_revenue_code
																		 ,@p_deposit_code			= @deposit_code
																		 ,@p_deposit_type			= @deposit_type
																		 ,@p_deposit_amount			= @revenue_amount
																		 ,@p_revenue_amount			= @revenue_amount
																		 --
																		 ,@p_cre_date				= @mod_date		
																		 ,@p_cre_by					= @mod_by		
																		 ,@p_cre_ip_address			= @mod_ip_address
																		 ,@p_mod_date				= @mod_date		
																		 ,@p_mod_by					= @mod_by		
																		 ,@p_mod_ip_address			= @mod_ip_address 
				
				fetch next from curagreementinformation
				into @agreement_no
					,@branch_code	  
					,@branch_name	  
					,@revenue_amount  
					,@currency_code
					,@deposit_code
					,@deposit_type
			end ;

			close curagreementinformation ;
			deallocate curagreementinformation ;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
