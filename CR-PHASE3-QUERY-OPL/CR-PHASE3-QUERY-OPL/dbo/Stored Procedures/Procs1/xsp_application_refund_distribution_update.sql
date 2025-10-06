CREATE PROCEDURE dbo.xsp_application_refund_distribution_update
(
	@p_id						bigint
	,@p_application_refund_code nvarchar(50)
	,@p_staff_position_code		nvarchar(50)
	,@p_staff_position_name		nvarchar(250)
	,@p_staff_code				nvarchar(50)
	,@p_staff_name				nvarchar(250)
	,@p_refund_pct				decimal(9, 6)
	,@p_distribution_amount		decimal(18, 2)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	application_refund_distribution
		set		application_refund_code = @p_application_refund_code
				,staff_position_code	= @p_staff_position_code
				,staff_position_name	= @p_staff_position_name
				,staff_code				= @p_staff_code
				,staff_name				= @p_staff_name
				,refund_pct				= @p_refund_pct
				,distribution_amount	= @p_distribution_amount
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;

		if ((
				select	sum(distribution_amount)
				from	dbo.application_refund_distribution
				where	application_refund_code = @p_application_refund_code
			) >
		   (
			   select	refund_amount
			   from		dbo.application_refund
			   where	code = @p_application_refund_code
		   )
		   )
		begin
			set @msg = 'Distribution Amount must be less or equal than Refund Amount' ;

			raiserror(@msg, 16, 1) ;
		end ;

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

