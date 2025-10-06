CREATE PROCEDURE dbo.xsp_master_auction_document_delete
(
	@p_id				bigint
    --			 
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin

	declare @msg			nvarchar(max) 
			,@auction_code	nvarchar(50) ;

	begin try
		
		select	@auction_code = auction_code
		from	dbo.master_auction_document
		where	id = @p_id ;		

		exec	dbo.xsp_master_auction_update_invalid 
				@auction_code						
				--
		        ,@p_mod_date					
		        ,@p_mod_by					
		        ,@p_mod_ip_address

		delete	dbo.master_auction_document
		where	id = @p_id ;

	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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
