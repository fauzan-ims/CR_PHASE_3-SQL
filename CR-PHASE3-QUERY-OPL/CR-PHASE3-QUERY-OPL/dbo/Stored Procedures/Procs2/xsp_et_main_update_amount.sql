CREATE PROCEDURE dbo.xsp_et_main_update_amount
(
	@p_code				nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
	,@p_total_amount	decimal(18,2) = 0 output
)
as
begin
	declare @msg					nvarchar(max) 
			,@et_exp_date			datetime 
			,@total_amount			decimal(18, 2)	
			,@sum_credit_amount		decimal(18,2)	
			,@sum_refund_amount		decimal(18,2)	
			,@penalty_charges		decimal(18,2)
			,@et_interim			decimal(18,2)
			
	begin try
		
		select	@total_amount = isnull(sum(total_amount), 0)
		from	dbo.et_transaction
		where	et_code			   = @p_code
				and is_transaction = '1' ;

		select	@sum_credit_amount	= isnull(sum(credit_amount),0)
				,@sum_refund_amount = isnull(sum(refund_amount),0)
		from	dbo.et_detail
		where	et_code = @p_code ;

		select	@penalty_charges = isnull(sum(total_amount), 0)
		from	dbo.et_transaction
		where	et_code				 = @p_code
				and transaction_code = 'CETP' ;

		select	@et_interim = isnull(sum(total_amount), 0)
		from	dbo.et_transaction
		where	et_code				 = @p_code
				and transaction_code = 'ET_INTERIM' ;
			
		set @penalty_charges =  @penalty_charges + @et_interim
		
		while @penalty_charges > 0
		begin
				if @sum_refund_amount > 0
				begin
					if (@sum_refund_amount - @penalty_charges < 0)
					begin
						set @penalty_charges = abs(@sum_refund_amount - @penalty_charges)
						set @sum_refund_amount = 0
						set @total_amount = @total_amount - @penalty_charges
					end
					else
					begin
						set @sum_refund_amount = @sum_refund_amount - @penalty_charges
						set @penalty_charges = 0
						set @total_amount = @penalty_charges
					end
				end
				else if @sum_credit_amount > 0
				begin
					if (@sum_credit_amount - @penalty_charges < 0)
					begin
						set @penalty_charges = abs(@sum_credit_amount - @penalty_charges)
						set @sum_credit_amount = 0
						set @total_amount = @total_amount - @penalty_charges

					end
					else
					begin
						set @sum_credit_amount = @sum_credit_amount - @penalty_charges
						set @penalty_charges = 0
						set @total_amount = @penalty_charges

					end
				end
                else
                begin
                    set @total_amount = @penalty_charges
					set @penalty_charges = 0
                end
		end
		
		update	et_main
		set		et_amount					= @total_amount
				,credit_note_amount			= @sum_credit_amount
				,refund_amount				= @sum_refund_amount
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;

	
		set @p_total_amount = @total_amount
				
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

