CREATE PROCEDURE dbo.xsp_cashier_main_mutation_update
(
	@p_code					nvarchar(50)
	,@p_mutation_amount		decimal(18, 2)
	--,@p_approval_reff		nvarchar(250)
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
	declare	@msg				nvarchar(max)
			,@cashier_db_amount	decimal(18, 2)
			,@cashier_cr_amount	decimal(18, 2)
			,@employee_code		nvarchar(50);

	begin try
		
		if (@p_mutation_amount > 0)
		begin
			set @cashier_db_amount =  @p_mutation_amount
			set @cashier_cr_amount =  0
		end
		else
		begin
		    set @cashier_db_amount =  0
			set @cashier_cr_amount = abs(@p_mutation_amount)
		end

		if	exists (select 1 from dbo.cashier_main where code = @p_code and cashier_status = 'OPEN')
		begin
			set @msg = 'This cahier already Open';
			raiserror(@msg ,16,-1)
		end
		else if ((select cashier_open_amount + cashier_db_amount - cashier_cr_amount + @p_mutation_amount from dbo.cashier_main where code = @p_code) < 0)
		begin
			set @msg = 'Invalid mutation, saldo cashier minus';
			raiserror(@msg ,16,-1)
		end
		else
		begin

			update	dbo.cashier_main
			set		cashier_cr_amount		= cashier_cr_amount + @cashier_cr_amount
					,cashier_db_amount		= cashier_db_amount + @cashier_db_amount
					,cashier_close_amount	= cashier_open_amount + cashier_db_amount - cashier_cr_amount + @p_mutation_amount
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code					= @p_code
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

