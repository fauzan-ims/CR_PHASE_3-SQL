CREATE PROCEDURE dbo.xsp_master_application_flow_detail_update
(
	@p_id					  bigint
	,@p_is_approval			  nvarchar(1)
	,@p_is_sign				  nvarchar(1)
	,@p_order_key			  int
	,@p_application_flow_code nvarchar(50)
	--
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@old_order_key int
			,@count			int ;

	begin try
		if @p_is_approval = 'T'
			set @p_is_approval = '1' ;
		else
			set @p_is_approval = '0' ;

		if @p_is_sign = 'T'
			set @p_is_sign = '1' ;
		else
			set @p_is_sign = '0' ;

		if (@p_order_key <= 0)
		begin
			set @msg = 'Step Order must be greater than 0' ;

			raiserror(@msg, 16, -1) ;
		end ;

		select	@count = count(id)
		from	master_application_flow_detail
		where	application_flow_code = @p_application_flow_code ;

		if (@count < @p_order_key)
		begin
			set @msg = 'Maximum Step Order is ' + cast(@count as nvarchar(3)) ;

			raiserror(@msg, 16, -1) ;
		end ;

		select	@old_order_key = order_key
		from	dbo.master_application_flow_detail
		where	id						  = @p_id 
				and application_flow_code = @p_application_flow_code;

		begin
			if @old_order_key > @p_order_key
			begin
				update	dbo.master_application_flow_detail
				set		order_key = order_key + 1
				where	order_key
				between @p_order_key and @old_order_key
				and application_flow_code = @p_application_flow_code;
			end ;
			else if @old_order_key < @p_order_key
			begin
				update	dbo.master_application_flow_detail
				set		order_key = order_key - 1
				where	order_key
				between @old_order_key and @p_order_key 
				and application_flow_code = @p_application_flow_code;
			end ;
		end ;
		

		update	master_application_flow_detail
		set		is_approval					= @p_is_approval
				,is_sign					= @p_is_sign
				,order_key					= @p_order_key
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id							= @p_id 
				and application_flow_code	= @p_application_flow_code;


		if @p_is_approval = '1'
		begin
			update	dbo.master_application_flow_detail
			set		is_approval				= '0'
			where	application_flow_code	= @p_application_flow_code
			and		id						<> @p_id
		end

		if @p_is_sign = '1'
		begin
			update	dbo.master_application_flow_detail
			set		is_sign					= '0'
			where	application_flow_code	= @p_application_flow_code
			and		id						<> @p_id
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
