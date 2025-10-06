create PROCEDURE dbo.xsp_insert_to_transaction_lock
(
	@p_user_id				nvarchar(50)
	,@p_user_name			nvarchar(250)	= null
	,@p_reff_name			nvarchar(250)	= null
	,@p_reff_code			nvarchar(50)	= null
	,@p_reff_code_detail	nvarchar(50)	= null
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	
	declare @msg				nvarchar(max)
			,@date				datetime = getdate()
			,@user				nvarchar(250) = ''
			,@data_user			nvarchar(250)


	begin try
	if(isnull(@p_reff_code,'') = '')
	begin
		if exists(select 1 from dbo.transaction_lock where is_active = '1' and user_id = @p_user_id)
		begin
			update dbo.transaction_lock
			set is_active = '0'
			where user_id = @p_user_id
		end

		exec dbo.xsp_transaction_lock_insert @p_id				= 0
											,@p_user_id			= @p_user_id
											,@p_user_name		= @p_user_name
											,@p_reff_name		= @p_reff_name
											,@p_reff_code		= ''
											,@p_access_date		= @date
											,@p_is_active		= '0'
											,@p_cre_date		= @p_mod_date		
											,@p_cre_by			= @p_mod_by		
											,@p_cre_ip_address	= @p_mod_ip_address
											,@p_mod_date		= @p_mod_date		
											,@p_mod_by			= @p_mod_by		
											,@p_mod_ip_address	= @p_mod_ip_address	
	end
	else
	begin
		if exists(select * from dbo.transaction_lock where is_active = '1' and user_id <> @p_user_id and reff_code = @p_reff_code)
		begin
			select @user = user_name 
			from dbo.transaction_lock
			where reff_code	= @p_reff_code
			and is_active	= '1'
		end
		else
		begin
			if(isnull(@p_reff_code_detail, '') = '')
			begin
				update	dbo.transaction_lock
				set		is_active = '0'
				where user_id = @p_user_id
				and	is_active = '1'

				exec dbo.xsp_transaction_lock_insert @p_id				= 0
											 ,@p_user_id		= @p_user_id
											 ,@p_user_name		= @p_user_name
											 ,@p_reff_name		= @p_reff_name
											 ,@p_reff_code		= @p_reff_code
											 ,@p_access_date	= @date
											 ,@p_is_active		= '1'
											 ,@p_cre_date		= @p_mod_date		
											 ,@p_cre_by			= @p_mod_by		
											 ,@p_cre_ip_address	= @p_mod_ip_address
											 ,@p_mod_date		= @p_mod_date		
											 ,@p_mod_by			= @p_mod_by		
											 ,@p_mod_ip_address	= @p_mod_ip_address	
			end
		end
		
		
	end
		
        

		SELECT @user 'username'
			
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;

end



