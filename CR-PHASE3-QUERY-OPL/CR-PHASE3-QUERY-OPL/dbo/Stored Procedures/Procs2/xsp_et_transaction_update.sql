CREATE PROCEDURE dbo.xsp_et_transaction_update
(
	@p_id				   bigint
	,@p_et_code			   nvarchar(50)
	,@p_transaction_amount decimal(18, 2)
	,@p_disc_pct		   decimal(9, 6)
	,@p_disc_amount		   decimal(18, 2)
	,@p_total_amount	   decimal(18, 2)
	--
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@total_et_amount			decimal(18, 2)
			,@total_deposit				decimal(18,2)
			,@amount_paid				decimal(18,2)  ;

	begin try
		--if (@p_disc_amount < 0)
		--begin
		--	set @msg = 'Discount Amount must be greater or equal than 0' ;

		--	raiserror(@msg, 16, 1) ;
		--end ;

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

		update	et_transaction
		set		transaction_amount		= @p_transaction_amount
				,disc_pct				= @p_disc_pct
				,disc_amount			= @p_total_amount - @p_transaction_amount
				,total_amount			= @p_total_amount
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id
				and et_code				= @p_et_code 
				and transaction_code <> 'DPIALC' ;

		select	@total_et_amount = isnull(sum(total_amount), 0)
		from	dbo.et_transaction
		where	et_code				= @p_et_code
				and is_transaction	= '1'
				and transaction_code <> 'DPIALC' ;
        
		select	@total_deposit = isnull(sum(transaction_amount),0)
		from	dbo.et_transaction
		where	et_code				= @p_et_code
		and		transaction_code	= 'DPS_INST';

		if (@total_deposit < @total_et_amount)
		begin
		    set @amount_paid = @total_et_amount - @total_deposit;

			update dbo.et_transaction
			set		transaction_amount = @total_deposit*-1
					,total_amount	   = @total_deposit*-1
			where   transaction_code   = 'DPIALC'
			and		et_code			   = @p_et_code;
			
		end;
		else
		begin
		    set @amount_paid = 0;

			update dbo.et_transaction
			set		transaction_amount = @total_et_amount*-1
					,total_amount	   = @total_et_amount*-1
			where   transaction_code   = 'DPIALC'
			and		et_code			   = @p_et_code;
		end;

		--update	dbo.et_main
		--set		et_amount = @amount_paid 
		--where	code = @p_et_code ;

		exec dbo.xsp_et_main_update_amount @p_code = @p_et_code,                       -- nvarchar(50)
		                                   @p_mod_date = @p_mod_date, -- datetime
		                                   @p_mod_by = @p_mod_by,                     -- nvarchar(15)
		                                   @p_mod_ip_address = @p_mod_ip_address             -- nvarchar(15)
		
		if exists
		(
			select	1
			from	dbo.et_transaction
			where	id					 = @p_id
					and transaction_code = 'PRAJ_ET'
		)
		begin 
			if exists
			(
				select	1
				from	dbo.et_transaction
				where	et_code				   = @p_et_code
						and transaction_code   = 'OS_PRINC'
						and transaction_amount < @p_transaction_amount
			)
			begin
				set @msg = 'OS PRINCIPAL PAID must be less or equal than OS PRINCIPAL' ;
				raiserror(@msg, 16, 1) ;
			end ;
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
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end;
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	
end ;
