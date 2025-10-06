CREATE PROCEDURE dbo.xsp_et_main_update_et_transaction
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg								  nvarchar(max)
			,@transaction_amount_and_total_amount decimal(18, 2) ;

	begin try
		select	@transaction_amount_and_total_amount = sum(et.os_rental_amount)
		from	dbo.et_detail et
		where	et_code = @p_code ;

		if not exists
		(
			select	1
			from	dbo.et_transaction
			where	et_code				 = @p_code
					and transaction_code = 'PRAJ_ET'
		)
		begin
			insert into dbo.et_transaction
			(
				et_code
				,transaction_code
				,transaction_amount
				,disc_pct
				,disc_amount
				,total_amount
				,order_key
				,is_amount_editable
				,is_discount_editable
				,is_transaction
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	@p_code
				,'PRAJ_ET'
				,isnull(@transaction_amount_and_total_amount, 0)
				,0
				,0
				,isnull(@transaction_amount_and_total_amount, 0)
				,99
				,'1'
				,'0'
				,'1'
				--
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;

			if (isnull(@transaction_amount_and_total_amount, 0) = 0)
			begin
				delete dbo.et_transaction
				where	et_code				 = @p_code
						and transaction_code = 'PRAJ_ET' ;
			end ;
		end ;
		else 
		begin
			update	dbo.et_transaction
			set		transaction_amount = @transaction_amount_and_total_amount
					,total_amount	= @transaction_amount_and_total_amount
			where	et_code				 = @p_code
					and transaction_code = 'PRAJ_ET'
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


