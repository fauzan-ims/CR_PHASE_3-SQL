CREATE PROCEDURE dbo.xsp_endorsement_detail_update
(
	@p_id						 bigint
	,@p_endorsement_code		nvarchar(50)
	,@p_occupation_code			 nvarchar(50)  = NULL
	,@p_region_code				 nvarchar(50)  = NULL
	,@p_collateral_category_code nvarchar(50)  = NULL
	,@p_object_name				 nvarchar(4000)
	,@p_insured_name			 nvarchar(250)
	,@p_insured_qq_name			 nvarchar(250)
	--,@p_eff_date				 datetime
	,@p_exp_date				 datetime	  = null
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg					   nvarchar(max)
			,@occupation_code		   nvarchar(50)
			,@region_code			   nvarchar(50)
			,@collateral_category_code nvarchar(50)
			,@object_name			   nvarchar(4000)
			,@insured_name			   nvarchar(250)
			,@insured_qq_name		   nvarchar(250)
			,@eff_date				   datetime
			,@exp_date				   datetime 
			,@policy_code			   nvarchar(50)
			,@to_year				   int;

	begin try

		select	@occupation_code			= occupation_code
				,@region_code				= region_code
				,@collateral_category_code	= collateral_category_code
				,@object_name				= object_name
				,@insured_name				= insured_name
				,@insured_qq_name			= insured_qq_name
				,@eff_date					= eff_date
				,@exp_date					= exp_date
				,@policy_code				= policy_code
		from	dbo.endorsement_detail ed
				inner join endorsement_main em on (em.code = ed.endorsement_code)
		where	endorsement_code			= @p_endorsement_code 
				and old_or_new				= 'NEW';

		update	endorsement_detail
		set		occupation_code				= @occupation_code
				,region_code				= @region_code				
				,collateral_category_code	= @collateral_category_code	
				,object_name				= @object_name				
				,insured_name				= @insured_name				
				,insured_qq_name			= upper(@insured_qq_name)			
				,eff_date					= @eff_date					
				,exp_date					= @exp_date					
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	endorsement_code			= @p_endorsement_code 
				and old_or_new				= 'OLD';
					
		update	endorsement_detail
		set		occupation_code				= @p_occupation_code
				,region_code				= @p_region_code
				,collateral_category_code	= @p_collateral_category_code
				,object_name				= @p_object_name
				,insured_name				= @p_insured_name
				,insured_qq_name			= upper(@p_insured_qq_name)
				,eff_date					= @eff_date
				,exp_date					= @p_exp_date
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	endorsement_code			= @p_endorsement_code 
				and old_or_new				= 'NEW';

		set @to_year = round((datediff(month, @eff_date, @p_exp_date)/12.0),0, 0)

		update insurance_policy_main
		set    policy_exp_date = @p_exp_date
			   ,to_year		   = @to_year
			   ,insured_name   = @p_insured_name
			   ,insured_qq_name = upper(@p_insured_qq_name)
		where code = @policy_code
		
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



