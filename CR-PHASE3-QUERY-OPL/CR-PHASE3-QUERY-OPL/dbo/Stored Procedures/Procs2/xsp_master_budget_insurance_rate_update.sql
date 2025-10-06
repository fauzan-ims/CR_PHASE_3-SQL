--created by, Rian at 05/06/2023 

--Created by, Rian at 05/06/2023 

--created by, Rian at 05/06/2023 

--created by, Rian at 05/06/2023 

--created by, Rian at 05/06/2023 

--created by, Rian at 05/06/2023 

CREATE PROCEDURE dbo.xsp_master_budget_insurance_rate_update
(
	@p_code						 nvarchar(50)
	,@p_vehicle_type_code		 nvarchar(50)
	,@p_vehicle_type_description nvarchar(50)
	,@p_coverage_code			 nvarchar(50)
	,@p_coverage_description	 nvarchar(250)
	,@p_is_active				 nvarchar(1)
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@value_exp_date nvarchar(50)
	begin try

		if exists
		(
			select	1
			from	dbo.master_budget_insurance_rate
			where	vehicle_type_code	= @p_vehicle_type_code
					and coverage_code	= @p_coverage_code
					and	code			<> @p_code
		)
		begin
			set	@msg = 'Data Already Exists.'
			raiserror (@msg, 16, -1)
		end

		if @p_is_active = 'T'
			set	@p_is_active = '1'
		else
			set	@p_is_active = '0' 
		
		select	@value_exp_date = value
		from	dbo.sys_global_param
		where	code = 'EXPDATE' ;

		update	dbo.master_budget_insurance_rate
		set		vehicle_type_code			= @p_vehicle_type_code		 
				,vehicle_type_description	= @p_vehicle_type_description 
				,coverage_code				= @p_coverage_code			 
				,coverage_description		= @p_coverage_description	  
				,is_active					= @p_is_active	
				,exp_date					= dateadd(month, convert (int, @value_exp_date), dbo.xfn_get_system_date())


				--			 		 
				,mod_date					= @p_mod_date				 
				,mod_by						= @p_mod_by					 
				,mod_ip_address				= @p_mod_ip_address		
		where	code						= @p_code	 

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
end
