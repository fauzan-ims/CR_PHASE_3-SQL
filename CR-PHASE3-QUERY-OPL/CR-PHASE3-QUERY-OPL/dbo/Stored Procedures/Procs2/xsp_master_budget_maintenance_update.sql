--created by, Rian at 11/05/2023 

--created by, Rian at 12/05/2023 

--created by, Rian at 12/05/2023 

CREATE PROCEDURE dbo.xsp_master_budget_maintenance_update
(
	@p_code				 nvarchar(50)
	,@p_unit_code		 nvarchar(50)
	,@p_unit_description nvarchar(250)
	,@p_year			 int
	,@p_inflation		 decimal(9, 6)
	,@p_location		 nvarchar(10)
	,@p_eff_date		 datetime
	,@p_exp_date		 datetime	  = null
	,@p_is_active		 nvarchar(1)
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg			 nvarchar(max)
			,@value_exp_date nvarchar(50) ;

	begin try

		select	@value_exp_date = value
		from	dbo.sys_global_param
		where	code = 'EXPDATE' ;

		set @p_exp_date = dateadd(month, convert(int, @value_exp_date), @p_eff_date) ;

		if	@p_is_active = 'T'
			set	@p_is_active = '1'
		else 
			set	@p_is_active = '0'

		update	dbo.master_budget_maintenance
		set		unit_code			= @p_unit_code
				,unit_description	= @p_unit_description
				,year				= @p_year
				,inflation			= @p_inflation
				,location			= @p_location
				,eff_date			= @p_eff_date
				,exp_date			= @p_exp_date
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
