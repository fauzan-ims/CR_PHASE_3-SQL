CREATE PROCEDURE dbo.xsp_master_insurance_address_delete
(
	@p_id bigint
)
as
begin
	declare @msg nvarchar(max)  
			,@insurance_code	nvarchar(50)
			,@mod_date			datetime	
			,@mod_by 			nvarchar(15)
			,@mod_ip_address	nvarchar(15)
			,@is_latest			NVARCHAR(1)
	begin try
		select	@insurance_code	  = insurance_code
				,@mod_date		  = mod_date
				,@mod_by 		  = mod_by 
				,@mod_ip_address  = mod_ip_address
				,@is_latest		  = is_latest
		FROM	master_insurance_address
		where	id = @p_id ;

		delete master_insurance_address
		where	id = @p_id ;

		EXEC dbo.xsp_master_insurance_update_invalid @p_code			= @insurance_code                   
													,@p_mod_date		= @mod_date
													,@p_mod_by			= @mod_by 
													,@p_mod_ip_address	= @mod_ip_address

		IF @is_latest = '1'
		begin
			update dbo.master_insurance_address
			set is_latest = 1
			where ID in (
				SELECT top 1 ID 
				FROM master_insurance_address 
				where insurance_code = @insurance_code
			)
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




