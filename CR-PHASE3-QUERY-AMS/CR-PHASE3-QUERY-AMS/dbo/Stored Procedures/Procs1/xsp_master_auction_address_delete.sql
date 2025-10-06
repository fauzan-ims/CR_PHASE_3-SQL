CREATE procedure dbo.xsp_master_auction_address_delete
(
	@p_id bigint
)
as
BEGIN

	declare @msg			nvarchar(max) 
			,@auction_code	nvarchar(50)
			,@code			nvarchar(50)
			,@id			bigint;

	select	@auction_code = auction_code
	from	dbo.master_auction_address 
	where	id = @p_id

	begin try
    
		delete master_auction_address
		where	id = @p_id ;

		if exists ( select 1 from dbo.master_auction_address where auction_code = @auction_code)
		begin
        
			select	top 1 @id = id 
			from	dbo.master_auction_address
			where	auction_code = @auction_code

			update	dbo.master_auction_address 
			set		is_latest = '1' 
			where	id = @id 
			
			select	@code = code 
			from	dbo.master_auction
			where	code = @auction_code

			update	dbo.master_auction
			set		is_validate = 0
			where	code = @code

		end 
		else 
		begin
        
			update	dbo.master_auction 
			set		is_validate = '0' 
			where	code = @auction_code 

		end
        
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
