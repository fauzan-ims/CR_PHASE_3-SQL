CREATE PROCEDURE dbo.xsp_application_deviation_update
(
	@p_id				bigint
	,@p_application_no	nvarchar(50)
	,@p_deviation_code	nvarchar(50)
	,@p_position_code	nvarchar(50)
	,@p_position_name	nvarchar(250)
	,@p_remarks			nvarchar(4000)
	,@p_is_manual		nvarchar(1)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_manual = 'T'
		set @p_is_manual = '1' ;
	else
		set @p_is_manual = '0' ;

	begin try
		update	application_deviation
		set		application_no			= @p_application_no
				,deviation_code		= @p_deviation_code
				,remarks			= @p_remarks
				,position_code		= @p_position_code
				,position_name		= @p_position_name
				,is_manual			= @p_is_manual
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id ;
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

