create PROCEDURE [dbo].[xsp_transaction_lock_active] 
(
	@p_id				bigint
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg		nvarchar(max);

	begin try
			if exists (	select 1 from dbo.transaction_lock 
						where id = @p_id 
						and is_active = '1')
		
			begin
				update	dbo.transaction_lock 
				set		is_active	= '0'
						--
						,mod_date		= @p_mod_date		
						,mod_by			= @p_mod_by			
						,mod_ip_address	= @p_mod_ip_address
				where	id			= @p_id
			end
            else
            begin
				
				update	dbo.transaction_lock 
				set		is_active	= '1'
						--
						,mod_date		= @p_mod_date		
						,mod_by			= @p_mod_by			
						,mod_ip_address	= @p_mod_ip_address
				where	id				= @p_id
			end
		    
			
	end try
	begin catch
		if (len(@msg) <> 0)  
		begin
			set @msg = 'V' + ';' + @msg;
		end
        else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + ERROR_MESSAGE();
		end;

		raiserror(@msg, 16, -1) ;
		return ;  
	end catch ;
end ;
