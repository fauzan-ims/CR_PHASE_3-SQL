CREATE PROCEDURE dbo.xsp_cashier_main_update_mutation
(
	@p_code				nvarchar(50)
	,@p_amount			decimal(18,2)
	--,@p_approval_remark	nvarchar(4000)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@msg			nvarchar(max)
			,@db_amount		decimal(18,2)
			,@cr_amount		decimal(18,2)
			,@close_amount	decimal(18,2)

	begin try

		
		if(@p_amount > 0)
		begin
		    set @db_amount = @p_amount
		    set @cr_amount = 0
		end 
        else
		begin
		    set @db_amount = 0
		    set @cr_amount = abs(@p_amount)
		end

		--set @p_amount = abs(@p_amount)

		update	dbo.cashier_main
		set		cashier_db_amount		= cashier_db_amount + @db_amount
				,cashier_cr_amount		= cashier_cr_amount + @cr_amount
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code = @p_code

		select  @close_amount = cashier_innitial_amount + cashier_open_amount + cashier_db_amount - cashier_cr_amount
		from	dbo.cashier_main 
		where	code = @p_code 

		update	dbo.cashier_main
		set		cashier_close_amount	= @close_amount
		where	code = @p_code

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
