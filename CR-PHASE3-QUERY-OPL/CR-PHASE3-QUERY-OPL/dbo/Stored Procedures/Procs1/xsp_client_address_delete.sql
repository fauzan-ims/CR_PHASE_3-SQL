CREATE PROCEDURE dbo.xsp_client_address_delete
(
	@p_code nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max) 
			,@client_code		nvarchar(50)
			,@is_legal			nvarchar(1)
			,@is_collection		nvarchar(1)
			,@is_mailing		nvarchar(1)
			,@is_residence		nvarchar(1);
			
	begin try
		select @client_code		= client_code 
			   ,@is_legal		= is_legal		
			   ,@is_collection	= is_collection	
			   ,@is_mailing		= is_mailing		
			   ,@is_residence	= is_residence	
		from dbo.client_address where code = @p_code;

		exec [dbo].[xsp_client_update_invalid] @p_client_code		= @client_code  
												,@p_mod_date		= @p_mod_date
												,@p_mod_by			= @p_mod_by
												,@p_mod_ip_address	= @p_mod_ip_address

		delete client_address
		where	code = @p_code ;
		
		if @is_legal = '1'
		begin
			update dbo.client_address
			set is_legal = '1'
			where code =
			(
				select top 1 code
				from client_address
				where client_code = @client_code
			);
		end;
		
		if @is_collection = '1'
		begin
			update dbo.client_address
			set is_collection = '1'
			where code =
			(
				select top 1 code
				from client_address
				where client_code = @client_code
			);
		end;
		
		if @is_mailing = '1'
		begin
			update dbo.client_address
			set is_mailing = '1'
			where code =
			(
				select top 1 code
				from client_address
				where client_code = @client_code
			);
		end;
		
		if @is_residence = '1'
		begin
			update dbo.client_address
			set is_residence = '1'
			where code =
			(
				select top 1 code
				from client_address
				where client_code = @client_code
			);
		end;
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


