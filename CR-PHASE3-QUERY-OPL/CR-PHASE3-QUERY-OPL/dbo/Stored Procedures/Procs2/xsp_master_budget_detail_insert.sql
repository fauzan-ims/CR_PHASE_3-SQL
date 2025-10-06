--created by, Rian at 11/05/2023 

--created by, Rian at 11/05/2023 

CREATE PROCEDURE dbo.xsp_master_budget_detail_insert
(
	@p_id			   bigint = 0 output
	,@p_budget_code	   nvarchar(50)
	,@p_eff_date	   datetime
	,@p_budget_rate	   decimal(9, 6)
	,@p_base_calculate nvarchar(10)
	,@p_cycle		   nvarchar(20)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max) 
			,@exp_date			datetime
			,@max_eff_date		datetime
			,@value_exp_date	nvarchar(5)

	begin try
		insert into dbo.master_budget_detail
		(
			budget_code
			,eff_date
			,budget_rate
			,base_calculate
			,cycle
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_budget_code
			,@p_eff_date
			,@p_budget_rate
			,@p_base_calculate
			,@p_cycle
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		select	@value_exp_date = value
		from	dbo.sys_global_param
		where	code = 'EXPDATE' ;

		--select	@max_eff_date	= max(eff_date)
		--from	dbo.master_budget_detail
		--where	budget_code = @p_budget_code ;

		set	@exp_date = dateadd(month, convert (int, @value_exp_date), dbo.xfn_get_system_date())

		update	dbo.master_budget
		set		exp_date		= @exp_date
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	code		= @p_budget_code

		set @p_id = @@identity ;
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
