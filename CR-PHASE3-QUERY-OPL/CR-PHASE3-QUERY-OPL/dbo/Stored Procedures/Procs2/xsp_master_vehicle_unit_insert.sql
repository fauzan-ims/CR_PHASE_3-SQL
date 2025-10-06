---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_vehicle_unit_insert
(
	@p_code						 nvarchar(50) output
	,@p_vehicle_category_code	 nvarchar(50)
	,@p_vehicle_subcategory_code nvarchar(50)
	,@p_vehicle_merk_code		 nvarchar(50)
	,@p_vehicle_model_code		 nvarchar(50)
	,@p_vehicle_type_code		 nvarchar(50)
	,@p_vehicle_name			 nvarchar(250)
	,@p_description				 nvarchar(250)
	,@p_is_cbu					 nvarchar(1)
	,@p_is_karoseri				 nvarchar(1)
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
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
												,@p_branch_code = N''
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'UV'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'MASTER_VEHICLE_UNIT'
												,@p_run_number_length = 8
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	if @p_is_cbu = 'T'
		set @p_is_cbu = '1' ;
	else
		set @p_is_cbu = '0' ;

	if @p_is_karoseri = 'T'
		set @p_is_karoseri = '1' ;
	else
		set @p_is_karoseri = '0' ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		if exists (select 1 from master_vehicle_unit where description = @p_description)
		begin
			set @msg = 'Description already exist';
			raiserror(@msg, 16, -1) ;
		end 

		insert into master_vehicle_unit
		(
			code
			,vehicle_category_code
			,vehicle_subcategory_code
			,vehicle_merk_code
			,vehicle_model_code
			,vehicle_type_code
			,vehicle_name
			,description
			,is_cbu
			,is_karoseri
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
			,@p_vehicle_category_code
			,@p_vehicle_subcategory_code
			,@p_vehicle_merk_code
			,@p_vehicle_model_code
			,@p_vehicle_type_code
			,upper(@p_vehicle_name)
			,upper(@p_description)
			,@p_is_cbu
			,@p_is_karoseri
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


