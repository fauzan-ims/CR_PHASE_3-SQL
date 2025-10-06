CREATE PROCEDURE dbo.xsp_client_reference_update
(
	@p_id						bigint
	,@p_client_code				nvarchar(50)
	,@p_reference_type_code		nvarchar(50)
	,@p_reference_full_name		nvarchar(250)
	,@p_reference_address		nvarchar(4000)
	,@p_reference_identity_no	nvarchar(50)
	,@p_reference_area_phone_no nvarchar(4)
	,@p_reference_phone_no		nvarchar(15)
	,@p_relationship			nvarchar(250)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists (select 1 from client_reference where reference_identity_no = @p_reference_identity_no and reference_type_code = @p_reference_type_code and @p_id <> id and client_code = @p_client_code)
		begin
			set @msg = 'Reference already exist';
			raiserror(@msg, 16, -1) ;
		end 

		exec [dbo].[xsp_client_update_invalid] @p_client_code		= @p_client_code  
												,@p_mod_date		= @p_mod_date
												,@p_mod_by			= @p_mod_by
												,@p_mod_ip_address	= @p_mod_ip_address

		update	client_reference
		set		client_code					= @p_client_code
				,reference_type_code		= @p_reference_type_code
				,reference_full_name		= upper(@p_reference_full_name)
				,reference_address			= @p_reference_address
				,reference_identity_no		= @p_reference_identity_no
				,reference_area_phone_no	= @p_reference_area_phone_no
				,reference_phone_no			= @p_reference_phone_no
				,relationship				= upper(@p_relationship)
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

