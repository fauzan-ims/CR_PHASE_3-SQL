CREATE PROCEDURE dbo.xsp_order_detail_update
(
	@p_id							bigint
	,@p_dp_to_public_service		decimal(18,2)	
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max) 
			,@order_code					nvarchar(50)
			,@sum_amount					decimal(18, 2) 
			,@dp_from_customer_amount		decimal(18, 2);

	select	
			@order_code			  = order_code
	from	dbo.order_detail
	where	id = @p_id

	begin try
		

		
		update	order_detail
		set		dp_to_public_service		= @p_dp_to_public_service
			
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	id								= @p_id ;

		select	@sum_amount = sum(dp_to_public_service)
		from	dbo.order_detail
		where	order_code = @order_code


		update	order_main
		set		order_amount					= @sum_amount
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	code							= @order_code;

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


