CREATE PROCEDURE [dbo].[xsp_procurement_request_update]
(
	@p_code					nvarchar(50)
	,@p_company_code		nvarchar(50)
	,@p_request_date		datetime
	,@p_requestor_code		nvarchar(50)
	,@p_requestor_name		nvarchar(250)
	,@p_requirement_type	nvarchar(50)
	,@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(250)
	,@p_division_code		nvarchar(50)
	,@p_division_name		nvarchar(250)
	,@p_department_code		nvarchar(50)
	,@p_department_name		nvarchar(250)
	,@p_status				nvarchar(20)
	,@p_remark				nvarchar(4000)
	--,@p_procurement_type	nvarchar(15)
	,@p_is_reimburse		nvarchar(1)
	,@p_to_province_code	nvarchar(50)	= ''
	,@p_to_province_name	nvarchar(250)	= ''
	,@p_to_city_code		nvarchar(50)	= ''
	,@p_to_city_name		nvarchar(250)	= ''
	,@p_to_area_phone_no	nvarchar(4)		= ''
	,@p_to_phone_no			nvarchar(15)	= ''
	,@p_to_address			nvarchar(4000)	= ''
	,@p_eta_date			datetime		= null
	,@p_from_province_code	nvarchar(50)	= ''
	,@p_from_province_name	nvarchar(250)	= ''
	,@p_from_city_code		nvarchar(50)	= ''
	,@p_from_city_name		nvarchar(250)	= ''
	,@p_from_address		nvarchar(4000)	= ''
	,@p_from_area_phone_no	nvarchar(4)		= ''
	,@p_from_phone_no		nvarchar(15)	= ''
	,@p_mobilisasi_type		nvarchar(50)	= null
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@procurement_type	nvarchar(50)

	begin try
		if @p_is_reimburse = 'T'
			set @p_is_reimburse = '1' ;
		else if @p_is_reimburse = '1'
			set @p_is_reimburse = '1' ;
		else if @p_is_reimburse = '0'
			set @p_is_reimburse = '0' ;
		else
			set @p_is_reimburse = '0' ;

		if @p_request_date < dbo.xfn_get_system_date()
		begin
			set @msg = 'Request date must be greater or equal than system date.';
			raiserror(@msg, 16, -1) ;
		end ;

		select @procurement_type = procurement_type 
		from dbo.procurement_request
		where code = @p_code

		if @procurement_type = 'MOBILISASI'
		begin
			if @p_eta_date < @p_request_date
			begin
				set @msg = 'Eta date must be grater or equal than Request date.';
				raiserror(@msg, 16, -1) ;
			end
		end


		update	procurement_request
		set		company_code			= @p_company_code
				,request_date			= @p_request_date
				,requestor_code			= @p_requestor_code
				,requestor_name			= @p_requestor_name
				,requirement_type		= @p_requirement_type
				,branch_code			= @p_branch_code
				,branch_name			= @p_branch_name
				,division_code			= @p_division_code
				,division_name			= @p_division_name
				,department_code		= @p_department_code
				,department_name		= @p_department_name
				,status					= @p_status
				,remark					= @p_remark
				--,procurement_type		= @p_procurement_type
				,is_reimburse			= @p_is_reimburse
				,to_province_code		= @p_to_province_code
				,to_province_name		= @p_to_province_name
				,to_city_code			= @p_to_city_code
				,to_city_name			= @p_to_city_name
				,to_area_phone_no		= @p_to_area_phone_no
				,to_phone_no			= @p_to_phone_no
				,to_address				= @p_to_address
				,eta_date				= @p_eta_date
				,from_province_code		= @p_from_province_code
				,from_province_name		= @p_from_province_name
				,from_city_code			= @p_from_city_code
				,from_city_name			= @p_from_city_name
				,from_address			= @p_from_address
				,from_area_phone_no		= @p_from_area_phone_no
				,from_phone_no			= @p_from_phone_no
				,mobilisasi_type		= @p_mobilisasi_type
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code = @p_code ;
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
