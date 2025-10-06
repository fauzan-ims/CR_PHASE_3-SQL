---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_vehicle_pricelist_insert
(
	@p_code						 nvarchar(50) output
	,@p_description				 nvarchar(250) = ''
	,@p_vehicle_category_code	 nvarchar(50)
	,@p_vehicle_subcategory_code nvarchar(50)
	,@p_vehicle_merk_code		 nvarchar(50)
	,@p_vehicle_model_code		 nvarchar(50)
	,@p_vehicle_type_code		 nvarchar(50)
	,@p_vehicle_unit_code		 nvarchar(50)
	,@p_asset_year				 nvarchar(4)
	,@p_condition				 nvarchar(10)
	,@p_is_active				 nvarchar(1)
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
	declare @msg				  nvarchar(max)
			,@year				  nvarchar(4)
			,@month				  nvarchar(2)
			,@batch_currency_code nvarchar(3) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	declare @p_unique_code nvarchar(50) ;

	exec dbo.xsp_get_next_unique_code_for_table @p_code output
												,@p_branch_code = N''
												,@p_sys_document_code = N''
												,@p_custom_prefix = N'MVP'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = N'MASTER_VEHICLE_PRICELIST'
												,@p_run_number_length = 6
												,@p_delimiter = N'.'
												,@p_run_number_only = N'0' ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		--if exists (select 1 from master_vehicle_pricelist where description = @p_description)
		--begin
		--	set @msg = 'Description already exist';
		--	raiserror(@msg, 16, -1) ;
		--end 

		insert into master_vehicle_pricelist
		(
			code
			,description
			,vehicle_category_code
			,vehicle_subcategory_code
			,vehicle_merk_code
			,vehicle_model_code
			,vehicle_type_code
			,vehicle_unit_code
			,asset_year
			,condition
			,is_active
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	upper(@p_code)
			,@p_description
			,@p_vehicle_category_code
			,@p_vehicle_subcategory_code
			,@p_vehicle_merk_code
			,@p_vehicle_model_code
			,@p_vehicle_type_code
			,@p_vehicle_unit_code
			,@p_asset_year
			,@p_condition
			,@p_is_active
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
	end try
	Begin catch
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


