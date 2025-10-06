CREATE PROCEDURE dbo.xsp_due_date_change_transaction_insert
(
	@p_id					 bigint = 0 output
	,@p_due_date_change_code nvarchar(50)
	,@p_transaction_code	 nvarchar(50)
	,@p_transaction_amount	 decimal(18, 2)
	,@p_disc_pct			 decimal(9, 6)
	,@p_disc_amount			 decimal(18, 2)
	,@p_total_amount		 decimal(18, 2) = 0
	,@p_order_key			 int
	,@p_is_amount_editable	 nvarchar(1)
	,@p_is_discount_editable nvarchar(1)
	,@p_is_transaction		 nvarchar(1)
	--
	,@p_cre_date			 datetime
	,@p_cre_by				 nvarchar(15)
	,@p_cre_ip_address		 nvarchar(15)
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@due_date_change_amount		decimal(18, 2) ;

	begin try
		if not exists
		(
			select	1
			where	@p_transaction_amount = 0
					and @p_is_transaction = '1'
					and @p_is_amount_editable = '0'
		) or    @p_transaction_code = 'DPIALC'
		begin
			insert into due_date_change_transaction
			(
				due_date_change_code
				,transaction_code
				,transaction_amount
				,disc_pct
				,disc_amount
				,total_amount
				,order_key
				,is_amount_editable
				,is_discount_editable
				,is_transaction
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	@p_due_date_change_code
				,@p_transaction_code
				,@p_transaction_amount
				,@p_disc_pct
				,@p_disc_amount
				,@p_total_amount
				,@p_order_key
				,@p_is_amount_editable
				,@p_is_discount_editable
				,@p_is_transaction
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;			

			set @p_id = @@identity ;

			--select	@due_date_change_amount	 = isnull(sum(transaction_amount), 0)
			--from	dbo.due_date_change_transaction et
			--where	due_date_change_code = @p_due_date_change_code 
			--		and et.is_transaction = '1';

			--update	dbo.due_date_change_main
			--set		change_amount = @due_date_change_amount
			--where	code = @p_due_date_change_code ;
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

