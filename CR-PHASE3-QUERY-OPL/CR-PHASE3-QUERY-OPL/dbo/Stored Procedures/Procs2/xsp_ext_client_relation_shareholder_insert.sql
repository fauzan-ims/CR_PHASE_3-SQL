CREATE PROCEDURE dbo.xsp_ext_client_relation_shareholder_insert
(
	
	@p_client_code					   nvarchar(50)	  = null
	--
	,@p_ShareholderName					nvarchar(250)  = null
	--
	,@p_cre_date					   datetime
	,@p_cre_by						   nvarchar(15)
	,@p_cre_ip_address				   nvarchar(15)
	,@p_mod_date					   datetime
	,@p_mod_by						   nvarchar(15)
	,@p_mod_ip_address				   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	--if @p_is_officer = 'T'
	--	set @p_is_officer = '1' ;
	--else
	--	set @p_is_officer = '0' ;

	--if @p_is_emergency_contact = 'T'
	--	set @p_is_emergency_contact = '1' ;
	--else
	--	set @p_is_emergency_contact = '0' ;

	--if @p_shareholder_type = 'PUBLIC'
	--	set @p_full_name = 'PUBLIC'
	begin try
		insert into client_relation
		(
			client_code
			,relation_type
			,client_type
			,full_name
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
			,'SHAREHOLDER'
			,''
			,@p_ShareholderName
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		exec [dbo].[xsp_client_update_invalid] @p_client_code		= @p_client_code  
												,@p_mod_date		= @p_mod_date
												,@p_mod_by			= @p_mod_by
												,@p_mod_ip_address	= @p_mod_ip_address
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
end ;

