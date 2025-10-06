CREATE PROCEDURE dbo.xsp_suspend_allocation_update
(
	@p_code						 nvarchar(50)
	,@p_branch_code				 nvarchar(50)
	,@p_branch_name				 nvarchar(250)
	--,@p_cashier_code			 nvarchar(50)
	,@p_allocation_status		 nvarchar(10)
	,@p_allocation_trx_date		 datetime
	,@p_allocation_value_date	 datetime
	,@p_allocation_orig_amount	 decimal(18, 2)
	,@p_allocation_currency_code nvarchar(3)
	,@p_allocation_exch_rate	 decimal(18, 6)
	,@p_allocation_base_amount	 decimal(18, 2)
	,@p_allocationt_remarks		 nvarchar(4000)
	,@p_suspend_code			 nvarchar(50)
	,@p_suspend_amount			 decimal(18, 2)
	,@p_agreement_no			 nvarchar(50)
	--,@p_suspend_gl_link_code	 nvarchar(50)
	,@p_is_received_request		 nvarchar(1)
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	--if @p_is_received_request = 'T'
	--	set @p_is_received_request = '1' ;
	--else
	--	set @p_is_received_request = '0' ;

	begin try
		if (@p_allocation_value_date > dbo.xfn_get_system_date()) 
				begin
					set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Value Date','System Date');
					raiserror(@msg ,16,-1)
				end

		if (@p_allocation_orig_amount > @p_suspend_amount) 
				begin
					set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Orig Amount','Outstanding Suspend Amount');
					raiserror(@msg ,16,-1)
				end

		update	suspend_allocation
		set		branch_code					= @p_branch_code
				,branch_name				= @p_branch_name
				--,cashier_code				= @p_cashier_code
				,allocation_status			= @p_allocation_status
				,allocation_trx_date		= @p_allocation_trx_date
				,allocation_value_date		= @p_allocation_value_date
				,allocation_orig_amount		= @p_allocation_orig_amount
				,allocation_currency_code	= @p_allocation_currency_code
				,allocation_exch_rate		= @p_allocation_exch_rate
				,allocation_base_amount		= @p_allocation_base_amount
				,allocationt_remarks		= upper(@p_allocationt_remarks)
				,suspend_code				= @p_suspend_code
				,suspend_amount				= @p_suspend_amount
				,agreement_no				= @p_agreement_no
				--,suspend_gl_link_code		= @p_suspend_gl_link_code
				,is_received_request		= @p_is_received_request
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;
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
