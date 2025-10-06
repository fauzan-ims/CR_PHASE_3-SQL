CREATE PROCEDURE dbo.xsp_client_corporate_shareholder_update
(
	@p_id						   bigint
	,@p_client_code				   nvarchar(50)
	,@p_shareholder_client_type	   nvarchar(10)
	,@p_shareholder_client_code	   nvarchar(50)	  = null
	,@p_shareholder_pct			   decimal(9, 6)  = null
	,@p_is_officer				   nvarchar(1)	  = 'F'
	,@p_officer_signer_type		   nvarchar(10)	  = null
	,@p_officer_position_type_code nvarchar(50)	  = null
	,@p_order_key				   int			  = 0
	--
	,@p_mod_date				   datetime
	,@p_mod_by					   nvarchar(15)
	,@p_mod_ip_address			   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_officer = 'T'
		set @p_is_officer = '1' ;
	else
		set @p_is_officer = '0' ;

	begin try
		exec [dbo].[xsp_client_update_invalid] @p_client_code		= @p_client_code  
												,@p_mod_date		= @p_mod_date
												,@p_mod_by			= @p_mod_by
												,@p_mod_ip_address	= @p_mod_ip_address
		update	client_corporate_shareholder
		set		client_code					= @p_client_code
				,shareholder_client_type	= @p_shareholder_client_type
				,shareholder_client_code	= @p_shareholder_client_code
				,shareholder_pct			= @p_shareholder_pct
				,is_officer					= @p_is_officer
				,officer_signer_type		= @p_officer_signer_type
				,officer_position_type_code = @p_officer_position_type_code
				,order_key					= @p_order_key
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

