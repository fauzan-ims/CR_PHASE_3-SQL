CREATE PROCEDURE dbo.xsp_master_public_service_branch_service_update
(
	@p_id						   bigint 
	,@p_service_fee_amount		   decimal(18,2)
	,@p_estimate_finish_day		   int
	--
	,@p_mod_date				   datetime
	,@p_mod_by					   nvarchar(15)
	,@p_mod_ip_address			   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin TRY
		
		if(@p_service_fee_amount <= 0)
		begin
        
			set @msg = 'Service Fee Amount must be greather than 0' ;

			raiserror(@msg, 16, -1) ;

        end

		update	master_public_service_branch_service
		set		service_fee_amount			= @p_service_fee_amount
				,estimate_finish_day		= @p_estimate_finish_day
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id							= @p_id ;
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



