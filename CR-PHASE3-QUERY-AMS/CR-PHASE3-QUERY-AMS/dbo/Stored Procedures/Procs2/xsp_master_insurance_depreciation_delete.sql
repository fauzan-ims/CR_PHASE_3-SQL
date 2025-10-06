CREATE PROCEDURE dbo.xsp_master_insurance_depreciation_delete
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
			,@is_default		nvarchar(1)

	begin try
		select	@insurance_code	  = insurance_code
				,@mod_date		  = mod_date
				,@mod_by 		  = mod_by 
				,@mod_ip_address  = mod_ip_address
				,@is_default	  = is_default
		FROM	master_insurance_depreciation
		where	id = @p_id ;
		
		delete master_insurance_depreciation
		where	id = @p_id ;

		IF @is_default = '1'
		begin
			update dbo.master_insurance_depreciation
			set is_default = 1
			where ID = (
				SELECT ID 
				FROM master_insurance_depreciation 
				where insurance_code = @insurance_code
			)
		END
        
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




