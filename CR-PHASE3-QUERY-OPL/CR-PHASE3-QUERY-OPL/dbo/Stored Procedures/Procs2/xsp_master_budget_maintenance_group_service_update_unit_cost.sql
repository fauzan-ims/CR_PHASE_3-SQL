--created by, Rian at 13/05/2023 

CREATE PROCEDURE [dbo].[xsp_master_budget_maintenance_group_service_update_unit_cost]
(
	@p_id							  bigint
	,@p_budget_maintenance_code		  nvarchar(50)
	,@p_unit_cost					  decimal(18,2)
	--
	,@p_mod_date					  datetime
	,@p_mod_by						  nvarchar(15)
	,@p_mod_ip_address				  nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max) 
			,@unit_qty				int
			,@unit_cost				decimal(18,2)
			,@probability			decimal(9,6)
			,@labor_cost			decimal(18,2)
			,@group_code			nvarchar(50)
			,@total_cost			decimal(18,2)

	begin try

		update	dbo.master_budget_maintenance_group_service
		set		budget_maintenance_code				= @p_budget_maintenance_code
				,unit_cost							= @p_unit_cost
				--
				,mod_date							= @p_mod_date
				,mod_by								= @p_mod_by
				,mod_ip_address						= @p_mod_ip_address
		where	id									= @p_id
				and budget_maintenance_code			= @p_budget_maintenance_code

		select		@unit_qty			 = bmgs.unit_qty
					,@unit_cost			 = bmgs.unit_cost
					,@labor_cost		 = bmgs.labor_cost
					,@group_code		 = bmgs.group_code
					,@probability		 = mbg.probability_pct
		from		dbo.master_budget_maintenance_group_service  bmgs
		--inner join	dbo.master_budget_maintenance_group mbg on (mbg.group_code = bmgs.group_code)
		inner join	dbo.master_budget_maintenance_group mbg on (mbg.group_code = bmgs.group_code and mbg.code = bmgs.budget_maintenance_group_code) -- (+) Ari 2023-09-22 ket : add join per group code
		where		bmgs.id							= @p_id
					and bmgs.budget_maintenance_code = @p_budget_maintenance_code ;

		set	@total_cost = (@unit_cost * @unit_qty * (@probability / 100)) + @labor_cost

		update	dbo.master_budget_maintenance_group_service
		set		total_cost = isnull(@total_cost, 0)
		where	id							= @p_id
				and budget_maintenance_code = @p_budget_maintenance_code 
				
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
