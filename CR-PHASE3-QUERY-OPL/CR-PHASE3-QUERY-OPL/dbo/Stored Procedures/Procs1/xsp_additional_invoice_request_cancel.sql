-- Louis Rabu, 31 Mei 2023 10.51.46 -- 
CREATE PROCEDURE dbo.xsp_additional_invoice_request_cancel
(
	@p_code				 nvarchar(50) 
	--
	,@p_cre_date		 datetime
	,@p_cre_by			 nvarchar(15)
	,@p_cre_ip_address	 nvarchar(15)
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@reff_code	nvarchar(50)
			,@reff_name	nvarchar(250);

	begin try
	
	select @reff_code  = reff_code
	       ,@reff_name = reff_name
	from additional_invoice_request
	where code = @p_code

	if @reff_name <> 'ET'
	begin
		if exists
		(
			select	1
			from	dbo.additional_invoice_request
			where	code	   = @p_code
					and status = 'HOLD'
		)
		begin 
		    update	dbo.additional_invoice_request
			set		status			= 'CANCEL' 
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	code			= @p_code

			update	dbo.opl_interface_additional_invoice_request
			set		request_status	   = 'CANCEL'
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	reff_code		= @reff_code

			if (@reff_name IN('LATE RETURN','LATERETURN'))-- RAFFY 2025/08/11 CR FASE 3
			begin
				update	dbo.agreement_asset_late_return
				set		payment_status = 'HOLD'
						--
						,mod_date		= @p_mod_date		
						,mod_by			= @p_mod_by			
						,mod_ip_address	= @p_mod_ip_address
				where	asset_no = @reff_code
			end
		end
        else
		begin
		    set @msg = 'Error data already proceed';
			raiserror(@msg, 16, -1) ;
		end	
	end
	else
	begin
		set @msg = 'This transaction can''t be cancel : ' + @p_code;
		raiserror(@msg, 16, -1) ;
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
