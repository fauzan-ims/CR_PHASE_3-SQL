CREATE PROCEDURE dbo.xsp_master_deskcoll_result_detail_update
(
	@p_code				   nvarchar(50)
	,@p_result_code		   nvarchar(50)
	,@p_result_detail_name nvarchar(250)
	,@p_is_active		   nvarchar(1)
	--
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;

	if @p_is_active = 'F'
		set @p_is_active = '0' ;

	begin try
		
		if exists
		(
			select	1
			from	master_deskcoll_result_detail
			where	code <> @p_code
			and		result_detail_name = @p_result_detail_name
		)
		begin
			set @msg = 'Description already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		update	master_deskcoll_result_detail
		set		result_detail_name  = upper(@p_result_detail_name)
				,is_active			= @p_is_active
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code ;

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
