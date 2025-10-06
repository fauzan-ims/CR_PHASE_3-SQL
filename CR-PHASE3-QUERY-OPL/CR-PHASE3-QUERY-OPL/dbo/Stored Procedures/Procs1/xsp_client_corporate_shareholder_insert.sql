CREATE PROCEDURE dbo.xsp_client_corporate_shareholder_insert
(
	@p_id						   bigint = 0 output
	,@p_client_code				   nvarchar(50) = null
	,@p_shareholder_client_type	   nvarchar(10)	
	,@p_shareholder_client_code	   nvarchar(50)	= null
	,@p_shareholder_pct			   decimal(9, 6)
	,@p_is_officer				   nvarchar(1) = 'F'
	,@p_officer_signer_type		   nvarchar(10)	= null
	,@p_officer_position_type_code nvarchar(50)	= null
	,@p_order_key				   int			= 0
	--
	,@p_cre_date				   datetime
	,@p_cre_by					   nvarchar(15)
	,@p_cre_ip_address			   nvarchar(15)
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

		insert into client_corporate_shareholder
		(
			client_code
			,shareholder_client_type
			,shareholder_client_code
			,shareholder_pct
			,is_officer
			,officer_signer_type
			,officer_position_type_code
			,order_key
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
			,@p_shareholder_client_type
			,@p_shareholder_client_code
			,@p_shareholder_pct
			,@p_is_officer
			,@p_officer_signer_type
			,@p_officer_position_type_code
			,@p_order_key
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

 

