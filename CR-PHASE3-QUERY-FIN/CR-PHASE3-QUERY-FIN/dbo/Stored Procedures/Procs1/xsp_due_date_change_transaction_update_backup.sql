CREATE PROCEDURE [dbo].[xsp_due_date_change_transaction_update_backup]
(
	@p_id					 bigint
	,@p_due_date_change_code nvarchar(50)
	,@p_transaction_amount	 decimal(18, 2)
	,@p_disc_pct		   decimal(9, 6)
	,@p_disc_amount		   decimal(18, 2)
	--
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@due_date_change_amount		decimal(18, 2)
			,@total_et_amount				decimal(18, 2)
			,@amount_paid					decimal(18, 2)
			,@total_deposit					decimal(18, 2)  ;

	begin try
		if (@p_disc_amount < 0)
		begin
			set @msg = 'Discount Amount must be greater or equal than 0' ;

			raiserror(@msg, 16, 1) ;
		end ;

		if (@p_disc_pct < 0)
		begin
			set @msg = 'Discount PCT must be greater or equal than 0' ;

			raiserror(@msg, 16, 1) ;
		end ;

		if (@p_disc_pct > 100)
		begin
			set @msg = 'Discount PCT must be less or equal than 100' ;

			raiserror(@msg, 16, 1) ;
		end ;

		--if exists (	select	1 
		--			from	dbo.due_date_change_transaction 
		--			where	id	= @p_id
		--					and transaction_code = 'DPIALC' 
		--		  )
		--begin

		--	--if (@p_transaction_amount > 0)
		--	--begin
		--	--	set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('DEPOSIT INSTALLMENT ALLOCATE','0');
		--	--	raiserror(@msg, 16, 1)
		--	--end

		--	if exists (	select	1 
		--				from	dbo.due_date_change_transaction 
		--				where	due_date_change_code = @p_due_date_change_code
		--						and transaction_code = 'DPS_INST' 
		--						and transaction_amount < abs(@p_transaction_amount)
		--			  )
		--	begin
		--		set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('DEPOSIT INSTALLMENT ALLOCATE','DEPOSIT INSTALLMENT');
		--		raiserror(@msg, 16, 1)
		--	end
		--end

		

		update	due_date_change_transaction
		set		transaction_amount		 = @p_transaction_amount
				,disc_pct				 = @p_disc_pct
				,disc_amount			 = @p_disc_amount
				,total_amount			 = @p_transaction_amount - @p_disc_amount
				--						 
				,mod_date				 = @p_mod_date
				,mod_by					 = @p_mod_by
				,mod_ip_address			 = @p_mod_ip_address
		where	id						 = @p_id
				and due_date_change_code = @p_due_date_change_code 
				and transaction_code <> 'DPIALC'

		select	@total_et_amount = isnull(sum(total_amount), 0)
		from	dbo.due_date_change_transaction
		where	due_date_change_code = @p_due_date_change_code
				and is_transaction	= '1'
				and transaction_code <> 'DPIALC' ;

		select	@total_deposit = isnull(sum(transaction_amount),0)
		from	dbo.due_date_change_transaction
		where	due_date_change_code	= @p_due_date_change_code
		and		transaction_code	= 'DPS_INST'

		if (@total_deposit < @total_et_amount)
		begin
		    set @amount_paid = @total_et_amount - @total_deposit

			update dbo.due_date_change_transaction
			set		transaction_amount = @total_deposit*-1
					,total_amount	   = @total_deposit*-1
			where   transaction_code   = 'DPIALC'
			and		due_date_change_code			   = @p_due_date_change_code
			
		end
		else
		begin
		    set @amount_paid = 0

			update dbo.due_date_change_transaction
			set		transaction_amount = @total_et_amount*-1
					,total_amount	   = @total_et_amount*-1
			where   transaction_code   = 'DPIALC'
			and		due_date_change_code = @p_due_date_change_code
		end

		--select	@due_date_change_amount	 = isnull(sum(ct.total_amount), 0)
		--from	dbo.due_date_change_transaction ct
		--where	due_date_change_code = @p_due_date_change_code 
		--		and ct.is_transaction = '1';

		update	dbo.due_date_change_main
		set		change_amount = @amount_paid
				,is_amortization_valid = '1'
		where	code = @p_due_date_change_code ;

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
