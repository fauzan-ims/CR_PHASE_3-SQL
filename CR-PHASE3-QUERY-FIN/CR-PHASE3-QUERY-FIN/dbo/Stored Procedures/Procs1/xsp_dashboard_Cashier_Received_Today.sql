CREATE PROCEDURE dbo.xsp_dashboard_Cashier_Received_Today
--(
--	@p_year nvarchar(4)
--)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		declare @myTableVariable table (branch_name nvarchar(50), amount_cash decimal(18,2), amount_noncash decimal(18,2))
	declare @branch_name		nvarchar(250)
			,@branch_code		nvarchar(50)
			,@amount_cash		decimal(18,2)
			,@amount_noncash	decimal(18,2) 


	declare cur_cashier_transaction cursor fast_forward read_only for
			
		select		distinct
					branch_code
					,branch_name
		from		dbo.cashier_transaction
		where		cashier_status = 'PAID'

		open cur_cashier_transaction
		
		fetch next from cur_cashier_transaction 
		into	@branch_code
				,@branch_name

		while @@fetch_status = 0
		begin
			
			select	@amount_cash = sum(cashier_base_amount)
			from	dbo.cashier_transaction 
			where	cashier_type = 'CASH'
					and branch_code  = @branch_code
					and CASHIER_STATUS = 'PAID'
					and cast(CASHIER_TRX_DATE as date) = cast(dbo.xfn_get_system_date() as date)
			select	@amount_noncash = sum(cashier_base_amount)
			from	dbo.cashier_transaction 
			where	cashier_type <> 'CASH'
					and branch_code  = @branch_code
					and CASHIER_STATUS = 'PAID'
					and cast(CASHIER_TRX_DATE as date) = cast(dbo.xfn_get_system_date() as date)
			insert into @myTableVariable
			(
				branch_name
				,amount_cash
				,amount_noncash
			)
			values
			(	@branch_name
				,isnull(@amount_cash,0)
				,isnull(@amount_noncash,0)
			) 
			fetch next from cur_cashier_transaction 
			into	@branch_code
					,@branch_name

		end
	close cur_cashier_transaction
	deallocate cur_cashier_transaction

	SELECT data.reff_name
		  ,data.total_data
		  ,data.series_name
	FROM	(

				SELECT top 5 branch_name 'reff_name'
					  ,amount_cash 'total_data'
					  ,'Cash' 'series_name'
				from @myTableVariable

				union
				SELECT top 5 branch_name 'reff_name'
					  ,amount_noncash 'total_data'
					  ,'Non Cash' 'series_name'
				from @myTableVariable 
			) data order by data.series_name

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
