--created by, Rian at 13/05/2023 

--created by, Rian at 13/05/2023 

--created by, Rian at 13/05/2023 

--created by, Rian at 13/05/2023 

CREATE PROCEDURE dbo.xsp_master_budget_maintenance_group_service_update
(
	@p_id							  bigint 
	,@p_unit_qty					  int =0
	,@p_unit_cost					  decimal(18,2) =0
	,@p_labor_cost					  decimal(18,2) =0
	,@p_budget_maintenance_code		  nvarchar(50)
	--
	,@p_mod_date					  datetime
	,@p_mod_by						  nvarchar(15)
	,@p_mod_ip_address				  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@total_cost	decimal(18,2)
			,@unit_qty		int
			,@unit_cost		decimal(18,2)
			,@probability	decimal(9,6)
			,@labor_cost	decimal(18,2)
			,@group_code	nvarchar(50)

	begin try

		select		@probability	= mbg.probability_pct
		from		dbo.master_budget_maintenance_group_service  bmgs
		inner join	dbo.master_budget_maintenance_group mbg on (mbg.group_code = bmgs.group_code)
		where		bmgs.id							= @p_id
					and bmgs.budget_maintenance_code = @p_budget_maintenance_code ;

		set	@total_cost = ((@p_unit_cost * @p_unit_qty) * (@probability / 100)) + @p_labor_cost

		update	dbo.master_budget_maintenance_group_service
		set		unit_qty							= @p_unit_qty
				,unit_cost							= @p_unit_cost
				,labor_cost							= @p_labor_cost 
				,total_cost							= @total_cost
				--
				,mod_date							= @p_mod_date
				,mod_by								= @p_mod_by
				,mod_ip_address						= @p_mod_ip_address
		where	id									= @p_id
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
