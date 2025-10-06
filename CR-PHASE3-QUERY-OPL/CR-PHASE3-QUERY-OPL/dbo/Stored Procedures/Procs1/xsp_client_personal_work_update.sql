CREATE PROCEDURE dbo.xsp_client_personal_work_update
(
	@p_id						  bigint
	,@p_client_code				  nvarchar(50)
	,@p_company_name			  nvarchar(250)
	,@p_company_business_line	  nvarchar(250)
	,@p_company_sub_business_line nvarchar(250)
	,@p_area_phone_no			  nvarchar(4)  = null
	,@p_phone_no				  nvarchar(15) = null
	,@p_area_fax_no				  nvarchar(4)  = null
	,@p_fax_no					  nvarchar(15) = null
	,@p_work_type_code			  nvarchar(50)
	,@p_work_department_name	  nvarchar(250)
	,@p_work_start_date			  datetime
	,@p_work_end_date			  datetime	   = null
	,@p_work_position			  nvarchar(250)
	,@p_province_code			  nvarchar(50)	 = null
	,@p_province_name			  nvarchar(250)	 = null
	,@p_city_code				  nvarchar(50)	 = null
	,@p_city_name				  nvarchar(250)	 = null
	,@p_zip_code				  nvarchar(50)	 = null
	,@p_zip_name				  nvarchar(250)	 = null
	,@p_sub_district			  nvarchar(250)	 = null
	,@p_village					  nvarchar(250)	 = null
	,@p_address					  nvarchar(4000) = null
	,@p_rt						  nvarchar(5)	 = null
	,@p_rw						  nvarchar(5)	 = null
	,@p_is_latest				  nvarchar(1)
	--
	,@p_mod_date				  datetime
	,@p_mod_by					  nvarchar(15)
	,@p_mod_ip_address			  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_latest = 'T'
		set @p_is_latest = '1' ;
	else
		set @p_is_latest = '0' ;

	begin try
	
		if  (@p_work_end_date < @p_work_start_date)
		begin
			set @msg = 'End Date must be greater than Start Date';
			raiserror(@msg, 16, -1) ;
		end 

		exec [dbo].[xsp_client_update_invalid] @p_client_code		= @p_client_code  
												,@p_mod_date		= @p_mod_date
												,@p_mod_by			= @p_mod_by
												,@p_mod_ip_address	= @p_mod_ip_address

		update	client_personal_work
		set		client_code					= @p_client_code
				,company_name				= upper(@p_company_name)
				,company_business_line		= upper(@p_company_business_line)
				,company_sub_business_line	= upper(@p_company_sub_business_line)
				,area_phone_no				= @p_area_phone_no
				,phone_no					= @p_phone_no
				,area_fax_no				= @p_area_fax_no
				,fax_no						= @p_fax_no
				,work_type_code				= @p_work_type_code
				,work_department_name		= @p_work_department_name
				,work_start_date			= @p_work_start_date
				,work_end_date				= @p_work_end_date
				,work_position				= @p_work_position
				,province_code				= @p_province_code
				,province_name				= @p_province_name
				,city_code					= @p_city_code
				,city_name					= @p_city_name
				,zip_code					= @p_zip_code
				,zip_name					= @p_zip_name
				,sub_district				= @p_sub_district
				,village					= @p_village
				,address					= @p_address
				,rt = @p_rt
				,rw = @p_rw
				,is_latest					= @p_is_latest
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id							= @p_id ;
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

