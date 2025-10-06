CREATE PROCEDURE dbo.xsp_sys_general_subcode_insert
(
	@p_code			   nvarchar(50)
	,@p_description	   nvarchar(4000)
	,@p_general_code   nvarchar(50)
	,@p_ojk_code	   nvarchar(50)
	,@p_order_key	   int
	,@p_is_active	   nvarchar(1)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@old_order_key int
			,@count			int ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		if exists
		(
			select	1
			from	sys_general_subcode
			where	description		 = @p_description
					and general_code = @p_general_code
		)
		begin
			set @msg = 'Description already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;
		
		if (@p_order_key < 1)
		begin
			set @msg = 'Order Key must be greater than 0' ;

			raiserror(@msg, 16, -1) ;
		end ;
		
		insert into sys_general_subcode
		(
			code
			,description
			,general_code
			,ojk_code
			,order_key
			,is_active
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	upper(@p_code)
			,upper(@p_description)
			,@p_general_code
			,@p_ojk_code
			,@p_order_key
			,@p_is_active
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		select	@count = count(code)
		from	dbo.sys_general_subcode
		where	general_code = @p_general_code ;

		if (@count + 1 < @p_order_key)
		begin
			set @msg = 'Maximum Order Key is ' + cast(@count + 1 as nvarchar(3)) ;

			raiserror(@msg, 16, -1) ;
		end ;

		select	@old_order_key = order_key
		from	dbo.sys_general_subcode
		where	code			 = @p_code
				and general_code = @p_general_code ;

		begin
			if @old_order_key > @p_order_key
			begin
				update	dbo.sys_general_subcode
				set		order_key = order_key + 1
				where	order_key
						between @p_order_key and @old_order_key
						and general_code = @p_general_code ;
			end ;
			else if @old_order_key < @p_order_key
			begin
				update	dbo.sys_general_subcode
				set		order_key = order_key - 1
				where	order_key
						between @old_order_key and @p_order_key
						and general_code = @p_general_code ;
			end ;
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
