CREATE PROCEDURE dbo.xsp_deposit_release_detail_update
(
	@p_id					 bigint
	,@p_deposit_release_code nvarchar(50)
	--,@p_deposit_code		 nvarchar(50)
	,@p_deposit_amount		 decimal(18, 2)
	,@p_release_amount		 decimal(18, 2)
	--
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max) 
			,@sum_amount	decimal(18, 2) 


	begin try
		if	(@p_release_amount > @p_deposit_amount)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Release Amount','Deposit Amount');
			raiserror(@msg ,16,-1)
		end

		if	(@p_release_amount <= 0)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_greater_than('Release Amount','0');
			raiserror(@msg ,16,-1)
		end

		update	deposit_release_detail
		set		deposit_release_code	= @p_deposit_release_code
				--,deposit_code			= @p_deposit_code
				--,deposit_amount		= @p_deposit_amount
				,release_amount			= @p_release_amount
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;

		select	@sum_amount		= sum(release_amount)
		from	dbo.deposit_release_detail
		where	deposit_release_code = @p_deposit_release_code

		update	dbo.deposit_release
		set		release_amount	= @sum_amount
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	code			= @p_deposit_release_code

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
