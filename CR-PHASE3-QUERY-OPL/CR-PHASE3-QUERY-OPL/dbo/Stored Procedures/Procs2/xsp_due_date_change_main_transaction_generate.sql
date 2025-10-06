CREATE PROCEDURE dbo.xsp_due_date_change_main_transaction_generate
(
	@p_code				nvarchar(50)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)

as
begin
	declare @msg					nvarchar(max)
			,@transaction_code		nvarchar(50)
			,@order_key				int
			,@is_transaction		nvarchar(1)
			,@transaction_amount	decimal(18, 2)
			,@disc_pct				decimal(9, 6)
			,@disc_amount			decimal(18, 2)
			,@agreement_no			nvarchar(50)
			,@date					datetime
			,@is_amount_editable	nvarchar(1)
			,@is_discount_editable  nvarchar(1)
	
	begin try

		select	@agreement_no	= agreement_no
				,@date			= change_date
		from	dbo.due_date_change_main
		where	code = @p_code

		declare c_mt cursor local fast_forward read_only for
		select  mt.code
				,mtp.order_key
				,mtp.is_transaction
				,maximum_disc_pct				
				,maximum_disc_amount	 
				,mtp.is_amount_editable
				,mtp.is_discount_editable
		from	dbo.master_transaction mt with(nolock)
				inner join dbo.master_transaction_parameter mtp with(nolock) on (mtp.transaction_code = mt.code)
		where	mtp.process_code ='DUE DATE'

		open c_mt
		fetch c_mt
		into @transaction_code
			,@order_key
			,@is_transaction
			,@disc_pct
			,@disc_amount
			,@is_amount_editable
			,@is_discount_editable

		while @@fetch_status = 0
		begin
		 
			exec dbo.xsp_due_date_change_transaction_insert @p_id = 0
															,@p_due_date_change_code	= @p_code
															,@p_transaction_code		= @transaction_code
															,@p_transaction_amount		= 0
															,@p_disc_pct				= @disc_pct
															,@p_disc_amount				= @disc_amount
															,@p_total_amount			= 0
															,@p_order_key				= @order_key
															,@p_is_amount_editable		= @is_discount_editable
															,@p_is_discount_editable	= @is_discount_editable
															,@p_is_transaction			= @is_transaction
															--
															,@p_cre_date				= @p_mod_date
															,@p_cre_by					= @p_mod_by
															,@p_cre_ip_address			= @p_mod_ip_address
															,@p_mod_date				= @p_mod_date
															,@p_mod_by					= @p_mod_by
															,@p_mod_ip_address			= @p_mod_ip_address 

			fetch c_mt
			into @transaction_code
				,@order_key
				,@is_transaction
				,@disc_pct
				,@disc_amount
				,@is_amount_editable
				,@is_discount_editable
		end
		close c_mt
		deallocate c_mt
		
		
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
	



