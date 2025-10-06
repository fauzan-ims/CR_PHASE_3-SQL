CREATE PROCEDURE dbo.xsp_client_doc_delete
(
	@p_id			   bigint
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg		  nvarchar(max) 
			,@client_code nvarchar(50)
			,@is_default  nvarchar(1) ;
			
	begin try

		select @client_code = client_code, @is_default = is_default from dbo.client_doc where id = @p_id;

		exec [dbo].[xsp_client_update_invalid] @p_client_code		= @client_code  
												,@p_mod_date		= @p_mod_date
												,@p_mod_by			= @p_mod_by
												,@p_mod_ip_address	= @p_mod_ip_address
		delete client_doc
		where	id				  = @p_id ;
		
		if @is_default = '1'
		begin
			update	dbo.client_doc
			set		is_default = '1'
			where	id =
			(
				select top 1
						id
				from	client_doc
				where	client_code = @client_code
			) ;
		end ;
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

