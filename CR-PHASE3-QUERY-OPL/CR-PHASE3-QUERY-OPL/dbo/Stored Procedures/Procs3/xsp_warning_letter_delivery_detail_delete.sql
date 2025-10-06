CREATE PROCEDURE dbo.xsp_warning_letter_delivery_detail_delete
(
	@p_id						bigint
    ,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
BEGIN
	

	declare @msg				nvarchar(max)
			,@letter_code		NVARCHAR(50)

	begin try
		
		select	@letter_code		=  letter_code
		from	dbo.warning_letter_delivery_detail
		where	id					= @p_id

		update	dbo.warning_letter
		set		letter_status		= 'ON PROCESS'
				,delivery_code		= null
				,delivery_date		= null
				,mod_date			= @p_mod_date			
				,mod_by				= @p_mod_by			
				,mod_ip_address		= @p_mod_ip_address
		where	letter_no			= @letter_code


		delete  dbo.warning_letter_delivery_detail
		where	id	= @p_id 

	end try
	Begin catch
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
