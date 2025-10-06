CREATE PROCEDURE dbo.xsp_master_upload_table_update
(
	@p_code							nvarchar(50)
	,@p_description					nvarchar(250)
	,@p_tabel_name					nvarchar(250)
	,@p_template_name				nvarchar(250)
	--,@p_sp_validate_name			nvarchar(250)
	,@p_sp_post_name				nvarchar(250)
	,@p_sp_cancel_name				nvarchar(250)
	,@p_sp_upload_name				nvarchar(250)
	--,@p_sp_getrows_name				nvarchar(250)
	,@p_is_active					nvarchar(1)
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin TRY
		
		if exists
		(
			select	1
			from	master_upload_table
			where	code <> @p_code
			and		description = @p_description
			 
		)
		begin
			set @msg = 'Description already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		update	master_upload_table
		set		description				= upper(@p_description)
				,tabel_name				= upper(@p_tabel_name)
				,template_name			= upper(@p_template_name)
				--,sp_validate_name		= lower(@p_sp_validate_name)
				,sp_post_name			= lower(@p_sp_post_name)
				,sp_cancel_name			= lower(@p_sp_cancel_name)
				,sp_upload_name			= lower(@p_sp_upload_name)				
				--,sp_getrows_name		= lower(@p_sp_getrows_name)				

				,is_active				= @p_is_active
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code = @p_code ;

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
