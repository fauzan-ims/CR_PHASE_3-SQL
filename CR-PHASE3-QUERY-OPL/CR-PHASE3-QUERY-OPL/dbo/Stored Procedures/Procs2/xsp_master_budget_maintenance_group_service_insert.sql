--created by, Rian at 12/05/2023 

CREATE PROCEDURE dbo.xsp_master_budget_maintenance_group_service_insert
(
	@p_id							  bigint = 0 output
	,@p_budget_maintenance_code		  nvarchar(50)
	,@p_group_code					  nvarchar(50)
	,@p_service_code				  nvarchar(50)
	,@p_service_description			  nvarchar(250)
	,@p_unit_qty					  int = 0	
	,@p_unit_cost					  decimal(18, 2) = 0
	,@p_labor_cost					  decimal(18, 2) = 0
	,@p_replacement_cycle			  int = 0
	,@p_replacement_type			  nvarchar(10) = ''
	,@p_total_cost					  decimal(18, 2) = 0
	--
	,@p_cre_date					  datetime
	,@p_cre_by						  nvarchar(15)
	,@p_cre_ip_address				  nvarchar(15)
	,@p_mod_date					  datetime
	,@p_mod_by						  nvarchar(15)
	,@p_mod_ip_address				  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@maintenance_group_code	nvarchar(50);

	begin try

		select	@maintenance_group_code = code
		from	dbo.master_budget_maintenance_group
		where	budget_maintenance_code = @p_budget_maintenance_code
				and group_code			= @p_group_code ;

		insert into dbo.master_budget_maintenance_group_service
		(
			budget_maintenance_code
			,budget_maintenance_group_code
			,group_code
			,service_code
			,service_description
			,unit_qty
			,unit_cost
			,labor_cost
			,replacement_cycle
			,replacement_type
			,total_cost
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_budget_maintenance_code
			,@maintenance_group_code
			,@p_group_code
			,@p_service_code
			,@p_service_description
			,@p_unit_qty
			,@p_unit_cost
			,@p_labor_cost
			,@p_replacement_cycle
			,@p_replacement_type
			,@p_total_cost
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

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
