CREATE PROCEDURE dbo.xsp_client_address_insert_from_cms
(
	@p_code			   nvarchar(50) 
	,@p_client_code	   nvarchar(50)
	,@p_address		   nvarchar(4000)
	,@p_province_code  nvarchar(50)
	,@p_province_name  nvarchar(250)
	,@p_city_code	   nvarchar(50)
	,@p_city_name	   nvarchar(250)
	,@p_zip_code_code  nvarchar(50)
	,@p_zip_code	   nvarchar(50)
	,@p_zip_name	   nvarchar(250)
	,@p_sub_district   nvarchar(250)
	,@p_village		   nvarchar(250)
	,@p_rt			   nvarchar(5)
	,@p_rw			   nvarchar(5)
	,@p_area_phone_no  nvarchar(4)
	,@p_phone_no	   nvarchar(15)
	,@p_is_legal	   nvarchar(1)
	,@p_is_collection  nvarchar(1)
	,@p_is_mailing	   nvarchar(1)
	,@p_is_residence   nvarchar(1)
	,@p_range_in_km	   decimal(18, 2)
	,@p_ownership	   nvarchar(250)
	,@p_lenght_of_stay int
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = ''
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'LAD'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'CLIENT_ADDRESS'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try

		insert into client_address
		(
			code
			,client_code
			,address
			,province_code
			,province_name
			,city_code
			,city_name
			,zip_code_code
			,zip_code
			,zip_name
			,sub_district
			,village
			,rt
			,rw
			,area_phone_no
			,phone_no
			,is_legal
			,is_collection
			,is_mailing
			,is_residence
			,range_in_km
			,ownership
			,lenght_of_stay
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,@p_client_code
			,@p_address
			,@p_province_code
			,@p_province_name
			,@p_city_code
			,@p_city_name
			,@p_zip_code_code
			,@p_zip_code
			,@p_zip_name
			,@p_sub_district
			,@p_village
			,@p_rt
			,@p_rw
			,@p_area_phone_no
			,@p_phone_no
			,@p_is_legal
			,@p_is_collection
			,@p_is_mailing
			,@p_is_residence
			,@p_range_in_km
			,upper(@p_ownership)
			,@p_lenght_of_stay
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
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

