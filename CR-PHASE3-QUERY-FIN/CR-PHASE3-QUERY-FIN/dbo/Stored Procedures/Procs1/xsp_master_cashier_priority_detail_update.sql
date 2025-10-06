CREATE PROCEDURE dbo.xsp_master_cashier_priority_detail_update
(
	@p_id					  bigint
	,@p_cashier_priority_code nvarchar(50)
	,@p_order_no			  int
	,@p_is_partial			  nvarchar(1)
	--
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
BEGIN

	declare		@msg			nvarchar(max) 
				,@old_order_no	int 
				,@count			int; 


	if @p_is_partial = 'T'
		set	@p_is_partial = '1'
	else
		set	@p_is_partial = '0'
		
	begin TRY
		
		select	@count = count(id) 
		from	master_cashier_priority_detail 
		where	cashier_priority_code = @p_cashier_priority_code

		if (@p_order_no <= 0)
		begin
			set @msg = 'Order No must be greater than 0';
			raiserror(@msg, 16, -1) ;
		end
		
		if (@count < @p_order_no)
		begin
			set @msg = 'Maximum Order No is ' + cast(@count as nvarchar(3));
			raiserror(@msg, 16, -1) ;
		end ;

		select	@old_order_no	= order_no
		from	dbo.master_cashier_priority_detail
		where	id = @p_id

		if @old_order_no > @p_order_no
		begin
			update	dbo.master_cashier_priority_detail
			set		order_no = order_no + 1
			where	order_no between @p_order_no and @old_order_no
		end
		else if @old_order_no < @p_order_no
		begin
			update	dbo.master_cashier_priority_detail
			set		order_no = order_no - 1
			where	order_no between @old_order_no and @p_order_no
		end
        
		update	master_cashier_priority_detail
		set		order_no					= @p_order_no
				,is_partial					= @p_is_partial
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id							= @p_id ;
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
