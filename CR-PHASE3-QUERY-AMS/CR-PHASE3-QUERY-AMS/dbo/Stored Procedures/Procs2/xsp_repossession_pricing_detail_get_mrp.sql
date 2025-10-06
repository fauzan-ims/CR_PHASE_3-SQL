CREATE PROCEDURE dbo.xsp_repossession_pricing_detail_get_mrp
(
	@p_id					bigint
	,@p_pricing_code		nvarchar(50)
	,@p_repossession_code	nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max)
			,@mak_fee_amount				   decimal(18, 2) = 0
			,@estimate_gain_loss_pct		   decimal(9, 6) = 0
			,@estimate_gain_loss_amount		   decimal(18, 2) = 0
			,@code_pricelist				   nvarchar(50)
			,@collateral_no					   nvarchar(50)
			,@vehicle_category_code			   nvarchar(50)
			,@vehicle_subcategory_code		   nvarchar(50)
			,@vehicle_merk_code				   nvarchar(50)
			,@vehicle_model_code			   nvarchar(50)
			,@vehicle_type_code				   nvarchar(50)
			,@vehicle_unit_code				   nvarchar(50)
			,@currency_code					   nvarchar(3)
			,@eff_date						   datetime
			,@pricelist_amount				   decimal(18, 2)
			,@pricing_amount				   decimal(18, 2)
			,@overdue_penalty_amount		   decimal(18, 2)
			,@overdue_installment_amount	   decimal(18, 2)
			,@outstanding_interest_amount	   decimal(18, 2)
			,@outstanding_principal_amount     decimal(18, 2)
			,@outstanding_installment_amount   decimal(18, 2)
			,@outstanding_deposit_amount	   decimal(18, 2) ;

	select	 @overdue_penalty_amount		   = overdue_penalty
			 ,@pricing_amount				   = pricing_amount
			 ,@overdue_installment_amount	   = overdue_installment
			 ,@outstanding_interest_amount	   = 0
			 ,@outstanding_principal_amount    = 0
			 ,@outstanding_installment_amount  = outstanding_installment
			 ,@outstanding_deposit_amount	   = outstanding_deposit
			
	from	dbo.repossession_main
	where	code							   = @p_repossession_code

	select	 @collateral_no					= agc.collateral_no
			 ,@vehicle_category_code		= agv.vehicle_category_code	
			 ,@vehicle_subcategory_code		= agv.vehicle_subcategory_code	
			 ,@vehicle_merk_code			= agv.vehicle_merk_code
			 ,@vehicle_model_code			= agv.vehicle_model_code		
			 ,@vehicle_type_code			= agv.vehicle_type_code		
			 ,@vehicle_unit_code			= agv.vehicle_unit_code		
	from	dbo.agreement_collateral agc
			inner join dbo.agreement_collateral_vehicle agv on (agv.collateral_no = agc.collateral_no)
	where	agc.collateral_no				= @collateral_no
	
	begin try
		if exists(select 1 from dbo.agreement_collateral where collateral_no = @collateral_no and collateral_type = 'VHCL')
		begin
			select	@code_pricelist = code
					,@currency_code	= mvd.currency_code
					,@eff_date		= mvd.effective_date
			from	dbo.master_vehicle_pricelist mvp
					inner join dbo.master_vehicle_pricelist_detail mvd on (mvd.vehicle_pricelist_code = mvp.code)
			where	cast(mvd.effective_date as date)		= cast(dbo.xfn_get_system_date() as date)
			 							
		if (isnull(@code_pricelist,'') <> '' )
			begin
				select	@pricelist_amount				= isnull(asset_value,0)
				from	master_vehicle_pricelist_detail
				where	vehicle_pricelist_code			= @code_pricelist
						and currency_code				= @currency_code
						and effective_date				< @eff_date
			end
		end

		set @pricelist_amount = isnull(@pricelist_amount,0)

		print @pricelist_amount

		update	dbo.repossession_pricing_detail
		set		pricelist_amount				= isnull(@pricelist_amount,0)
				--
				,mod_date						= @p_mod_date		
				,mod_by							= @p_mod_by			
				,mod_ip_address					= @p_mod_ip_address
		where	id								= @p_id

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
