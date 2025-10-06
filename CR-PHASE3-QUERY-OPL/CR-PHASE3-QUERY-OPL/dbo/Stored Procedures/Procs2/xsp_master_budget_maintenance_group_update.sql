--created by, Rian at 12/05/2023 

CREATE PROCEDURE dbo.xsp_master_budget_maintenance_group_update
(
	@p_code						nvarchar(50)
	,@p_budget_maintenance_code nvarchar(50)
	,@p_probability_pct			decimal(9,6) = 0
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare	@msg			nvarchar(max)
			,@id			bigint
			,@unit_qty		int
			,@unit_cost		decimal(18,2)
			,@labor_cost	decimal(18,2)
			,@probability	decimal(9,6)
			,@total_cost	decimal(18,2)
	begin try
		update	dbo.master_budget_maintenance_group
		set		code						= @p_code
				,budget_maintenance_code	= @p_budget_maintenance_code
				,probability_pct			= @p_probability_pct
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code
		and		budget_maintenance_code		= @p_budget_maintenance_code

		select	@probability = probability_pct
		from	dbo.master_budget_maintenance_group
		where	budget_maintenance_code = @p_budget_maintenance_code
				and code				= @p_code ;

		declare	c_maintenance_group cursor for
		select	id
				,unit_qty
				,unit_cost
				,labor_cost
		from	dbo.master_budget_maintenance_group_service
		where	budget_maintenance_group_code = @p_code
				and budget_maintenance_code	  = @p_budget_maintenance_code ;

		open	c_maintenance_group
		fetch	c_maintenance_group
		into	@id
				,@unit_qty
				,@unit_cost
				,@labor_cost
	
		while	@@fetch_status = 0
		begin

			set	@total_cost	= (@unit_cost * @unit_qty * (@probability / 100)) + @labor_cost

			update	dbo.master_budget_maintenance_group_service
			set		total_cost					= isnull(@total_cost, 0)
					--
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address
			where	budget_maintenance_code	= @p_budget_maintenance_code
			and		id						= @id
			
			fetch	c_maintenance_group
			into	@id
					,@unit_qty
					,@unit_cost
					,@labor_cost
		end

		close		c_maintenance_group
		deallocate	c_maintenance_group

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
