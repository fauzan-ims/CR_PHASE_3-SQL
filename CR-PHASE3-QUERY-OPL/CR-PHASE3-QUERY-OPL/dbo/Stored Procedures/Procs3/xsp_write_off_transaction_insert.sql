/*
    alterd : Rinda, 16 Nopember 2020
*/
CREATE PROCEDURE dbo.xsp_write_off_transaction_insert
(
	@p_id				   bigint = 0 output
	,@p_wo_code			   nvarchar(50)
	,@p_transaction_code	nvarchar(50)
	,@p_transaction_amount decimal(18, 2)
	,@p_is_transaction	   nvarchar(1)
	,@p_order_key		   int
	--
	,@p_cre_date		   datetime
	,@p_cre_by			   nvarchar(15)
	,@p_cre_ip_address	   nvarchar(15)
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into write_off_transaction
		(
			wo_code
			,transaction_code
			,transaction_amount
			,is_transaction
			,order_key
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	
			@p_wo_code
			,@p_transaction_code
			,@p_transaction_amount
			,@p_is_transaction
			,@p_order_key
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;

		if(@p_transaction_code = 'OS_PRINC')
		begin
		    update	dbo.write_off_main
			set		wo_amount = @p_transaction_amount
			where	code = @p_wo_code
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
end ;

