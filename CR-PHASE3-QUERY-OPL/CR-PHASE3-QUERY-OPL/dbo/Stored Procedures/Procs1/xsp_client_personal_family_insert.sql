CREATE PROCEDURE dbo.xsp_client_personal_family_insert
(
	@p_id					 bigint = 0 output
	,@p_client_code			 nvarchar(50)
	,@p_family_type_code	 nvarchar(50)
	,@p_family_client_code	 nvarchar(50)
	,@p_is_emergency_contact nvarchar(1)
	--
	,@p_cre_date			 datetime
	,@p_cre_by				 nvarchar(15)
	,@p_cre_ip_address		 nvarchar(15)
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_emergency_contact = 'T'
		set @p_is_emergency_contact = '1' ;
	else
		set @p_is_emergency_contact = '0' ;

	begin TRY
		if exists (select 1 from client_personal_family where client_code = @p_client_code AND family_client_code =  @p_family_client_code)
		begin
			SET @msg = 'Client already registed';
			raiserror(@msg, 16, -1) ;
		end
		
		exec [dbo].[xsp_client_update_invalid] @p_client_code		= @p_client_code  
												,@p_mod_date		= @p_mod_date
												,@p_mod_by			= @p_mod_by
												,@p_mod_ip_address	= @p_mod_ip_address

		insert into client_personal_family
		(
			client_code
			,family_type_code
			,family_client_code
			,is_emergency_contact
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_client_code
			,@p_family_type_code
			,@p_family_client_code
			,@p_is_emergency_contact
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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

 

