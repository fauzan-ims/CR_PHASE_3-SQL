CREATE PROCEDURE dbo.xsp_master_auction_branch_delete
(
	@p_id bigint
)
as
BEGIN

	declare @msg				nvarchar(max) 
			,@auction_code		nvarchar(50)
			,@id				bigint;
	
	select	@auction_code = auction_code
	from	dbo.master_auction_branch 
	where	id = @p_id

	begin try
    
		delete master_auction_branch
		where	id = @p_id ;

		if not exists ( select 1 from dbo.master_auction_branch where auction_code = @auction_code)
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
