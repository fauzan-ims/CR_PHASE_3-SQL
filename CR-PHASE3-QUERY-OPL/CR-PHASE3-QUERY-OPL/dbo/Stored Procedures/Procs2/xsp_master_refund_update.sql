---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_refund_update
(
	@p_code				  nvarchar(50)
	,@p_description		  nvarchar(250)
	,@p_calculate_by	  nvarchar(10)
	,@p_refund_amount	  decimal(18, 2) = 0
	,@p_refund_pct		  decimal(9, 6)	 = 0
	,@p_max_refund_amount decimal(18, 2) = 0
	,@p_fn_default_name	  nvarchar(250)  = null
	,@p_is_fn_override	  nvarchar(1)
	,@p_fn_override_name  nvarchar(250)	 = null
	,@p_is_psak			  nvarchar(1)
	,@p_is_active		  nvarchar(1)
	--
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@code  nvarchar(50);

	if @p_is_fn_override = 'T'
		set @p_is_fn_override = '1' ;
	else
		set @p_is_fn_override = '0' ;

	if @p_is_psak = 'T'
		set @p_is_psak = '1' ;
	else
		set @p_is_psak = '0' ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		if exists (select 1 from master_refund where description = @p_description and code <> @p_code)
		begin
			set @msg = 'Description already exist';
			raiserror(@msg, 16, -1) ;
		end 
		
		update	master_refund
		set		description			= upper(@p_description)
				,calculate_by		= @p_calculate_by
				,refund_amount		= @p_refund_amount
				,refund_pct			= @p_refund_pct
				,max_refund_amount	= @p_max_refund_amount
				,fn_default_name	= lower(@p_fn_default_name)
				,is_fn_override		= @p_is_fn_override
				,fn_override_name	= lower(@p_fn_override_name)
				,is_psak			= @p_is_psak
				,is_active			= @p_is_active
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code ;
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

