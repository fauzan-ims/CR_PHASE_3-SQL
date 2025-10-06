CREATE PROCEDURE [dbo].[xsp_application_amortization_move_upload]
(
	@p_application_no  nvarchar(50)
	-- 
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						   nvarchar(max) 
			,@payment_schedule			   nvarchar(50)  	
			,@schedule_month			   int  
			,@tenor						   int
			,@count_installment_no		   int = 0
			,@installment_no			   int
			,@due_date					   datetime
			,@principal_amount			   decimal(18, 2)
			,@installment_amount		   decimal(18, 2)
			,@installment_interest_amount  decimal(18, 2)
			,@os_principal_amount		   decimal(18, 2)
			,@installment_principal_amount decimal(18, 2)
			,@financing_amount			   decimal(18, 2)
			,@rv_type					   nvarchar(20)
			,@residual_value			   decimal(18, 2)
			,@max_installment_no		   int
			,@application_date			   datetime ; --(+) Saparudin : 26-10-2021 

	begin try
		delete dbo.application_amortization
		where	application_no = @p_application_no ;

		select	@application_date = dm.application_date
				,@payment_schedule = dt.payment_schedule_type_code 
				,@rv_type = dt.residual_value_type
				,@residual_value = isnull(dt.residual_value_amount, 0)
		from	dbo.application_tc dt
				inner join dbo.application_main dm on (dm.application_no = dt.application_no)
		where	dt.application_no = @p_application_no ;

		-- jika rv_type = national maka tidak ada sisa (residual_value = 0)
		if (@rv_type = 'NOTIONAL')
			set @residual_value = 0 ;
		
		-- mengambil multipier di master payment schedule
		select	@schedule_month = multiplier
		from	dbo.master_payment_schedule
		where	code = @payment_schedule ;

		--validation
		begin
			if not exists
			(
				select	1
				from	dbo.amortization_calculate
				where	reff_no			   = @p_application_no
						and installment_no = 0
			)
			begin
				set @msg = 'Installment No : 0, is not exists' ;

				raiserror(@msg, 16, 1) ;

				return ;
			end ;

			if ((
					select	max(installment_no)
					from	dbo.amortization_calculate
					where	reff_no = @p_application_no
				) <>
			   (
				   select	tenor / @schedule_month
				   from		dbo.application_tc
				   where	application_no = @p_application_no
			   )
			   )
			begin
				set @msg = 'Installment No must be equal to Tenor' ;

				raiserror(@msg, 16, 1) ;

				return ;
			end ;

			declare applicationamortization cursor fast_forward read_only for
			select		installment_no
						,due_date
						,principal_amount
						,installment_amount
						,installment_principal_amount
						,installment_interest_amount
						,os_principal_amount
			from		dbo.amortization_calculate
			where		reff_no = @p_application_no
			order by	installment_no asc ;

			open applicationamortization ;

			fetch next from applicationamortization
			into @installment_no
				 ,@due_date
				 ,@principal_amount
				 ,@installment_amount
				 ,@installment_principal_amount
				 ,@installment_interest_amount
				 ,@os_principal_amount ;

			while @@fetch_status = 0
			begin
				if (@installment_no <> @count_installment_no)
				begin
					set @msg = 'Installment No must be sequential' ;

					raiserror(@msg, 16, 1) ;

					return ;
				end

				if (
					   @installment_amount = 0
					   and	@installment_no > 0
				   )
				begin
					set @msg = 'Installment amount cannot be 0, Installment no : ' + cast(@installment_no as nvarchar(5)) ;

					raiserror(@msg, 16, 1) ;

					return ;
				end ;

				if (cast(@due_date as date) < cast(@application_date as date))
				begin
					set @msg = 'Due Date cannot be less than Application Date, Installment no : ' + cast(@installment_no as nvarchar(5)) ;

					raiserror(@msg, 16, 1) ;

					return ;
				end ;

				if (isnull(@installment_principal_amount, 0) < 0)
				begin
					set @msg = 'Principal Amount must be greater than 0' ;

					raiserror(@msg, 16, 1) ;

					return ;
				end ;

				if (@installment_interest_amount < 0)
				begin
					set @msg = 'Interest Amount must be greater than 0' ;

					raiserror(@msg, 16, 1) ;

					return ;
				end ;

				if (isnull(@installment_principal_amount, 0) + isnull(@installment_interest_amount, 0) <> isnull(@installment_amount, 0))
				begin
					set @msg = 'Principal Amount + Interest Amount must be equal to Installment Amount' ;

					raiserror(@msg, 16, 1) ;

					return ;
				end ;

				set @count_installment_no = @count_installment_no + 1;

				fetch next from applicationamortization
				into @installment_no
					 ,@due_date
					 ,@principal_amount
					 ,@installment_amount
					 ,@installment_principal_amount
					 ,@installment_interest_amount
					 ,@os_principal_amount ;
			end ;

			close applicationamortization ;
			deallocate applicationamortization ; 
		end
		
		insert into dbo.application_amortization
		(
			application_no
			,installment_no
			,due_date
			,principal_amount
			,installment_amount
			,installment_principal_amount
			,installment_interest_amount
			,os_principal_amount
			,os_interest_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	 @p_application_no
				,installment_no
				,due_date
				,0
				,installment_amount
				,installment_principal_amount
				,installment_interest_amount
				,0
				,0
				--
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.amortization_calculate
		where	reff_no = @p_application_no ;

		update	application_amortization
		set		principal_amount = isnull((
											  select	sum(aa1.installment_principal_amount)
											  from		application_amortization aa1
											  where		aa1.installment_no	   >= aa2.installment_no
														and aa1.application_no = aa2.application_no
										  ), 0
										 )
				,os_principal_amount = isnull((
												  select	sum(aa1.installment_principal_amount) + @residual_value
												  from		application_amortization aa1
												  where		aa1.installment_no	   > aa2.installment_no
															and aa1.application_no = aa2.application_no
											  ), 0
											 )
				,os_interest_amount = isnull((
												 select sum(aa1.installment_interest_amount)
												 from	application_amortization aa1
												 where	aa1.installment_no	   > aa2.installment_no
														and aa1.application_no = aa2.application_no
											 ), 0
											)
		from	application_amortization aa2
		where	aa2.application_no = application_no ;

		delete amortization_calculate
		where	reff_no = @p_application_no ;

		update	dbo.application_tc
		set		is_amortization_valid = '1'
		where	application_no = @p_application_no ;

		select	@max_installment_no = max(installment_no)
		from	dbo.application_amortization
		where	application_no = @p_application_no ; 

		update	application_amortization
		set		os_principal_amount = @residual_value 
		where	application_no = @p_application_no
		and		installment_no = @max_installment_no
	end try
	begin catch
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

