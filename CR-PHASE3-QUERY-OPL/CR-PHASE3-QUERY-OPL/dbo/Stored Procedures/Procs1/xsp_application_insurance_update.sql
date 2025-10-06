CREATE PROCEDURE dbo.xsp_application_insurance_update
(
	@p_id				  bigint
	,@p_application_no	  nvarchar(50)
	,@p_adjustment_amount decimal(18, 2)
	,@p_total_sell_amount decimal(18, 2)
	--
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@insurance_type  nvarchar(10);

	begin try 
		select	@insurance_type  = insurance_type 
		from	dbo.application_insurance
		where	id = @p_id ;

		update	application_insurance
		set		adjustment_amount	= @p_adjustment_amount
				,total_sell_amount	= @p_total_sell_amount
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id
				and application_no	= @p_application_no ;
				
		exec dbo.xsp_application_insurance_fee_update @p_application_no		= @p_application_no
													  ,@p_insurance_type	= @insurance_type
													  ,@p_mod_date			= @p_mod_date
													  ,@p_mod_by			= @p_mod_by
													  ,@p_mod_ip_address	= @p_mod_ip_address
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

