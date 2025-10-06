CREATE PROCEDURE dbo.xsp_endorsement_detail_insert
(
	@p_id						 bigint = 0 output
	,@p_endorsement_code		 nvarchar(50)
	,@p_old_or_new				 nvarchar(3)
	,@p_occupation_code			 nvarchar(50)   = null
	,@p_region_code				 nvarchar(50)   = null
	,@p_collateral_category_code nvarchar(50)   = null
	,@p_object_name				 nvarchar(4000)
	,@p_insured_name			 nvarchar(250)
	,@p_insured_qq_name			 nvarchar(250)
	,@p_eff_date				 datetime
	,@p_exp_date				 datetime
	--
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(15)
	,@p_cre_ip_address			 nvarchar(15)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into endorsement_detail
		(
			endorsement_code
			,old_or_new
			,occupation_code
			,region_code
			,collateral_category_code
			,object_name
			,insured_name
			,insured_qq_name
			,eff_date
			,exp_date
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_endorsement_code
			,@p_old_or_new
			,@p_occupation_code
			,@p_region_code
			,@p_collateral_category_code
			,@p_object_name
			,@p_insured_name
			,@p_insured_qq_name
			,@p_eff_date
			,@p_exp_date
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


