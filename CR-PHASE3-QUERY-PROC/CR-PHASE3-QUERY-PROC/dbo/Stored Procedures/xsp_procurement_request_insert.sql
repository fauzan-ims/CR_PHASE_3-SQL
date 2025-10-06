
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_procurement_request_insert]
(
	@p_code					nvarchar(50) output
	,@p_company_code		nvarchar(50) = 'DSF'
	,@p_request_date		datetime
	,@p_requestor_code		nvarchar(50)
	,@p_requestor_name		nvarchar(250)
	,@p_requirement_type	nvarchar(50)
	,@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(250)
	,@p_division_code		nvarchar(50)		= '00'
	,@p_division_name		nvarchar(250)		= 'KONSOLIDASI'
	,@p_department_code		nvarchar(50)		= '00.00'
	,@p_department_name		nvarchar(250)		= 'KONSOLIDASI'
	,@p_status				nvarchar(20)		= 'NEW'
	,@p_remark				nvarchar(4000)
	,@p_reff_no				nvarchar(50)		= null
	,@p_procurement_type	nvarchar(15)		
	,@p_is_reimburse		nvarchar(1)			
	,@p_to_province_code	nvarchar(50)		= null
	,@p_to_province_name	nvarchar(250)		= null
	,@p_to_city_code		nvarchar(50)		= null
	,@p_to_city_name		nvarchar(250)		= null
	,@p_to_area_phone_no	nvarchar(4)			= null
	,@p_to_phone_no			nvarchar(15)		= null
	,@p_to_address			nvarchar(4000)		= null
	,@p_eta_date			datetime			= null
	,@p_asset_no			nvarchar(50)		= null
	,@p_from_province_code	nvarchar(50)		= null
	,@p_from_province_name	nvarchar(250)		= null
	,@p_from_city_code		nvarchar(50)		= null
	,@p_from_city_name		nvarchar(250)		= null
	,@p_from_area_phone_no	nvarchar(4)			= null
	,@p_from_phone_no		nvarchar(15)		= null
	,@p_from_address		nvarchar(4000)		= null
	,@p_mobilisasi_type		nvarchar(50)		= null
	,@p_application_no		nvarchar(50)		= null
	,@p_built_year			nvarchar(4)			= null
	,@p_asset_colour		nvarchar(50)		= null
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
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code  nvarchar(50) ;

	begin try
		if cast(@p_request_date as date) <> cast(dbo.xfn_get_system_date() as date)
		begin
			set @msg = 'Request date must be equal than system date.';
			raiserror(@msg, 16, -1) ;
		end ;

		if @p_procurement_type = 'MOBILISASI'
		begin
			if @p_eta_date < @p_request_date
			begin
				set @msg = 'Eta date must be grater or equal than Request date.';
				raiserror(@msg, 16, -1) ;
			end
		end

		if @p_is_reimburse = 'T'
			set @p_is_reimburse = '1' ;
		else
			set @p_is_reimburse = '0' ;

		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @code output
													,@p_branch_code			= @p_company_code
													,@p_sys_document_code	= N''
													,@p_custom_prefix		= 'PRR'
													,@p_year				= @year
													,@p_month				= @month
													,@p_table_name			= 'PROCUREMENT_REQUEST'
													,@p_run_number_length	= 6
													,@p_delimiter			= '.'
													,@p_run_number_only		= N'0' ;

		insert into procurement_request
		(
			code
			,company_code
			,request_date
			,requestor_code
			,requestor_name
			,requirement_type
			,branch_code
			,branch_name
			,division_code
			,division_name
			,department_code
			,department_name
			,status
			,remark
			,reff_no
			,procurement_type
			,from_province_code
			,from_province_name
			,from_city_code
			,from_city_name
			,from_area_phone_no
			,from_phone_no
			,from_address
			,to_province_code
			,to_province_name
			,to_city_code
			,to_city_name
			,to_area_phone_no
			,to_phone_no
			,to_address
			,eta_date
			,is_reimburse
			,asset_no
			,mobilisasi_type
			,application_no
			,built_year
			,asset_colour
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
			,@p_company_code
			,@p_request_date
			,@p_requestor_code
			,@p_requestor_name
			,@p_requirement_type
			,@p_branch_code
			,@p_branch_name
			,@p_division_code
			,@p_division_name
			,@p_department_code
			,@p_department_name
			,@p_status
			,@p_remark
			,@p_reff_no
			,@p_procurement_type
			,@p_from_province_code
			,@p_from_province_name
			,@p_from_city_code
			,@p_from_city_name
			,@p_from_area_phone_no
			,@p_from_phone_no
			,@p_from_address
			,@p_to_province_code
			,@p_to_province_name
			,@p_to_city_code
			,@p_to_city_name
			,@p_to_area_phone_no
			,@p_to_phone_no
			,@p_to_address
			,@p_eta_date
			,@p_is_reimburse
			,@p_asset_no
			,@p_mobilisasi_type
			,@p_application_no
			,@p_built_year
			,@p_asset_colour
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

	set @p_code = @code;

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



