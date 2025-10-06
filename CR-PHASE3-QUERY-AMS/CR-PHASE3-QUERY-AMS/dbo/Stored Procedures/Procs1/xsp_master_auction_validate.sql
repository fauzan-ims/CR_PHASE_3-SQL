CREATE PROCEDURE dbo.xsp_master_auction_validate
(
	@p_code				nvarchar(50)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)	
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin

	declare @msg				nvarchar(max)
			--
			,@is_validate		nvarchar(1)
	
	begin try
	    
	select	@is_validate	= is_validate
	from	dbo.master_auction
	where	code			= @p_code ;
	
	if not exists (select 1 from dbo.master_auction_address where auction_code = @p_code)
	begin
			
		set @msg = 'Please add at least one address' ;
		raiserror(@msg, 16, -1) ;
	
	END
    
	if not exists (select 1 from dbo.master_auction_address where auction_code = @p_code and is_latest = '1')
	begin
			
		set @msg = 'Please input latest address' ;
		raiserror(@msg, 16, -1) ;
	
	end
	
	if not exists (select 1 from dbo.master_auction_bank where auction_code = @p_code)
	begin
			
		set @msg = 'Please add at least one bank' ;
		raiserror(@msg, 16, -1) ;
	
	END
    
	if not exists (select 1 from dbo.master_auction_bank where auction_code = @p_code and is_default = '1')
	begin
			
		set @msg = 'Please input default bank' ;
		raiserror(@msg, 16, -1) ;
	
	end
	
	--if exists
	--(
	--	select	1
	--	from	dbo.master_auction_document
	--	where	isnull(FILE_NAME, '') = ''
	--	and		auction_code		  = @p_code
	--)
	--begin
	--	set @msg = 'Please upload required document' ;

	--	raiserror(@msg, 16, 1) ;
	--end ;
			

	if (@is_validate = '1')
		set @is_validate = '0' ;
	else
		set @is_validate = '1' ;
	
	update	dbo.master_auction
	set		is_validate			= @is_validate
			--
			,mod_date			= @p_mod_date		
			,mod_by				= @p_mod_by			
			,mod_ip_address		= @p_mod_ip_address
	where	code = @p_code

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


