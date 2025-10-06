CREATE PROCEDURE dbo.xsp_application_step_period_update
(
	@p_code							nvarchar(50)
	,@p_application_no				nvarchar(50)
	,@p_step_no						int
	,@p_recovery_flag				nvarchar(15)
	,@p_recovery_principal_amount	decimal(18, 2)
	,@p_recovery_installment_amount decimal(18, 2)
	,@p_even_method					nvarchar(15)
	,@p_payment_schedule_type_code	nvarchar(50)
	,@p_number_of_installment		int
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
	
		if (@p_number_of_installment <= 0)
		begin
			set @msg = 'Number of Installment must be greater than 0';
			raiserror(@msg, 16, -1) ;
		end 

		update	application_step_period
		set		recovery_flag					= @p_recovery_flag
				,recovery_principal_amount		= @p_recovery_principal_amount
				,recovery_installment_amount	= @p_recovery_installment_amount
				,even_method					= @p_even_method
				,payment_schedule_type_code		= @p_payment_schedule_type_code
				,number_of_installment			= @p_number_of_installment
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	code							= @p_code ;

		--mengecek dan mengupdate installment sama atau tidak dengan tenor
		declare @payment_schedule		 nvarchar(10)
				,@installment			 int
				,@principal_amount		 decimal(18, 2)
				,@step_no				 int
				--
				,@schedule_month		 int
				,@tenor_outstanding		 int
				,@total_tenor			 int			= 0
				,@total_principal_amount decimal(18, 2) = 0
				,@principal_outstanding	 decimal(18, 2)
				--
				,@application_no		 nvarchar(50)
				,@tenor					 int
				,@leasead				 decimal(18, 2) ;

		select	@application_no = apt.application_no
				--
				,@tenor = apt.tenor
				,@leasead = am.financing_amount
		--from	dbo.application_step_period asp
		from	dbo.application_tc apt --on (asp.application_no = apt.application_no)
				inner join dbo.application_main am on (am.application_no = apt.application_no)
		where	apt.application_no = @p_application_no ;

		-- mengambil step yang paling atas
		select top 1
					@step_no = step_no
		from		dbo.application_step_period
		where		application_no = @p_application_no
		order by	step_no desc ;

		-- open cursor
		declare c_main cursor for
		select	 payment_schedule_type_code
				 ,number_of_installment
				 ,recovery_principal_amount
		from	 dbo.application_step_period
		where	 application_no = @p_application_no
		order by step_no asc ;

		open c_main ;

		fetch c_main
		into @payment_schedule
			 ,@installment
			 ,@principal_amount ;

		while @@fetch_status = 0
		begin
			-- mengambil multipier di master payment schedule
			select	@schedule_month = multiplier
			from	dbo.master_payment_schedule
			where	code = @payment_schedule ;

			set @total_tenor += @installment * @schedule_month ;
			set @total_principal_amount += @principal_amount ;

			fetch c_main
			into @payment_schedule
				 ,@installment
				 ,@principal_amount ;
		end ;

		close c_main ;
		deallocate c_main ;
		-- last checking
		declare @last_payment_schedule nvarchar(10) ;

		select top 1
					@last_payment_schedule = payment_schedule_type_code
		from		dbo.application_step_period
		where		application_no = @p_application_no
		order by	step_no desc ;

		-- mengambil multipier di master payment schedule
		select	@schedule_month = multiplier
		from	dbo.master_payment_schedule
		where	code = @last_payment_schedule ;
	 
		set @tenor_outstanding = (@tenor - @total_tenor) / @schedule_month ;
		set @principal_outstanding = @leasead - @total_principal_amount ;
	 
		update	dbo.application_step_period
		set		number_of_installment = ISNULL(number_of_installment,0) + @tenor_outstanding
				,recovery_principal_amount = recovery_principal_amount + @principal_outstanding
		where	application_no = @p_application_no
				and step_no	   = @step_no ;

		-- ambil installment & amount principal yang terakhir
		select	@tenor_outstanding = number_of_installment
				,@principal_outstanding = recovery_principal_amount
		from	dbo.application_step_period
		where	application_no = @p_application_no
				and step_no	   = @step_no ;

		
		-- menambah validasi jika kelebihan step
		if (@tenor_outstanding <= 0)
		begin
			set @msg = 'Overload Number of Installment ';
			raiserror(@msg, 16, -1) ;
		end ;
		if (@principal_outstanding <= 0)
		begin
			set @msg = 'Overload Allocation Principal Amount';
			raiserror(@msg, 16, -1) ;
		end ;
		
	---- ngupdate ke application asset amortization
	exec dbo.xsp_calculate_amortization_step @p_reff_no				= @p_application_no
											 ,@p_leasead_value		= null
											 ,@p_tenor				= 0
											 ,@p_interest_rate_eff	= null
											 ,@p_rate_flat			= null
											 ,@p_payment_schedule	= N''
											 ,@p_first_payment_type = N''
											 ,@p_day_in_one_year	= N''
											 ,@p_rv_type			= N''
											 ,@p_residual_value		= 0
											 ,@p_due_date			= @p_mod_date
											 ,@p_rounding_value		= null
											 ,@p_rounding_type		= N''
											 ,@p_facility_code		= N''
											 ,@p_last_due_date		= @p_mod_date
											 ,@p_cre_date			= @p_mod_date
											 ,@p_cre_by				= @p_mod_by
											 ,@p_cre_ip_address		= @p_mod_ip_address
											 ,@p_mod_date			= @p_mod_date
											 ,@p_mod_by				= @p_mod_by
											 ,@p_mod_ip_address		= @p_mod_ip_address
											 ,@p_until_step_no		= @p_step_no ; 
	
	-- jika step no merupakan 1 step sebelum step terakhir (mengupdate stepp terakhir)   
	if (@p_step_no + 1 = @step_no)
	begin
		declare  @steprecovery_flag					nvarchar(15)
				 ,@steprecovery_principal_amount	decimal(18, 2)
				 ,@steprecovery_installment_amount	decimal(18, 2)	
				 ,@stepeven_method					nvarchar(15)
				 ,@steppayment_schedule_type_code	nvarchar(50)
				 ,@stepnumber_of_installment		int

		select	@steprecovery_flag					= recovery_flag
				,@steprecovery_principal_amount		= recovery_principal_amount
				,@steprecovery_installment_amount	= recovery_installment_amount
				,@stepeven_method					= even_method
				,@steppayment_schedule_type_code	= payment_schedule_type_code
				,@stepnumber_of_installment			= number_of_installment
		from	dbo.application_step_period
		where	application_no = @p_application_no
				and step_no	   = @p_step_no ;
				
		exec dbo.xsp_application_step_period_update @p_code							= @p_code
													,@p_application_no				= @p_application_no
													,@p_step_no						= @step_no
													,@p_recovery_flag				= @steprecovery_flag					
													,@p_recovery_principal_amount	= @steprecovery_principal_amount	  
													,@p_recovery_installment_amount = @steprecovery_installment_amount	  
													,@p_even_method					= @stepeven_method					  
													,@p_payment_schedule_type_code	= @steppayment_schedule_type_code	  
													,@p_number_of_installment		= @stepnumber_of_installment		  
													,@p_mod_date					= @p_mod_date
													,@p_mod_by						= @p_mod_by
													,@p_mod_ip_address				= @p_mod_ip_address
	end
																					 
	end try
	Begin catch
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





