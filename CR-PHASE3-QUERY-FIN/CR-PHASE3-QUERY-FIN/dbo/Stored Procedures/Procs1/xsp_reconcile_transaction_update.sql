CREATE PROCEDURE dbo.xsp_reconcile_transaction_update
(
	@p_id					   bigint
	,@p_reconcile_code		   nvarchar(50)
	--,@p_transaction_source	   nvarchar(20)
	--,@p_transaction_no		   nvarchar(50)
	--,@p_transaction_reff_no	   nvarchar(250)
	--,@p_transaction_value_date datetime
	--,@p_transaction_amount	   decimal(18, 2)
	--,@p_is_system			   nvarchar(1)
	,@p_is_reconcile		   nvarchar(1)
	--
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max) 
			,@sum_system		decimal(18, 2)
			,@sum_upload		decimal(18,2);

	--if @p_is_system = 'T'
	--	set @p_is_system = '1' ;
	--else
	--	set @p_is_system = '0' ;

	if @p_is_reconcile = 'T'
		set @p_is_reconcile = '1' ;
	else
		set @p_is_reconcile = '0' ;

	begin try
		update	reconcile_transaction
		set		reconcile_code			= @p_reconcile_code
				--,transaction_source		= @p_transaction_source
				--,transaction_no			= @p_transaction_no
				--,transaction_reff_no	= @p_transaction_reff_no
				--,transaction_value_date = @p_transaction_value_date
				--,transaction_amount		= @p_transaction_amount
				--,is_system				= @p_is_system
				,is_reconcile			= @p_is_reconcile
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;

		select	@sum_system		= isnull(sum(transaction_amount),0)
		from	dbo.reconcile_transaction
		where	reconcile_code = @p_reconcile_code
				and is_system = '1'
				and	is_reconcile	= '1'

		select	@sum_upload		= isnull(sum(transaction_amount),0)
		from	dbo.reconcile_transaction
		where	reconcile_code = @p_reconcile_code
				and is_system = '0'
				and	is_reconcile	= '1'

		update	dbo.reconcile_main
		set		system_amount			= @sum_system
				,upload_amount			= @sum_upload
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_reconcile_code

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
