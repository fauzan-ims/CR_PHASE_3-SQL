CREATE procedure dbo.xsp_master_auction_bank_delete
(
	@p_id		bigint
)
as
begin

	declare		@msg					nvarchar(max) 
				--	
				,@id					bigint
				,@is_default			nvarchar(1)
				,@auction_code			nvarchar(50);
	
	select	@auction_code = auction_code
	from	dbo.master_auction_bank 
	where	id = @p_id

	begin try
		
		delete	master_auction_bank
		where	id = @p_id ;

		if exists ( select 1 from dbo.master_auction_bank where auction_code = @auction_code)
		begin
        
			select	top 1 @id = id 
			from	dbo.master_auction_bank
			where	auction_code = @auction_code

			update	dbo.master_auction_bank 
			set		is_default = '1' 
			where	id = @id 

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
