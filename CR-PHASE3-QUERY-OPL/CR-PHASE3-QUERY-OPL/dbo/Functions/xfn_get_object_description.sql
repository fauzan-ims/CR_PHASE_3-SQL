
CREATE function dbo.xfn_get_object_description
(
	@p_reff_no nvarchar(50)
	,@p_type   nvarchar(20)
	,@p_source nvarchar(10)
)
returns nvarchar(max)
as
begin
	declare @result						nvarchar(max)
			,@client_name				nvarchar(250)
			,@facility_description		nvarchar(250)
			,@application_remarks		nvarchar(4000)
			,@unit_desc					nvarchar(250)
			,@year						nvarchar(4)
			,@asset_value				decimal(18, 2)
			,@dp_amount					decimal(18, 2)
			,@rent_amount				decimal(18, 2)
			,@plafond_no				nvarchar(250)
			,@gender					nvarchar(4000)
			,@company_name				nvarchar(250)
			,@work_position				nvarchar(250)
			,@company_business_line		nvarchar(250)
			,@company_sub_business_line nvarchar(250)
			,@client_address			nvarchar(250)
			,@umur_client				int 
			,@application_external_no	nvarchar(50);

	if (@p_type = 'CLIENT')
	begin
		if exists
		(
			select	1
			from	dbo.client_personal_info
			where	client_code = @p_reff_no
		)
		begin
			select	@client_name					= full_name
					,@umur_client					= datediff(yy, cpi.date_of_birth, getdate())
					,@gender						= sgs.description
					,@work_position					= cpw.work_position
					,@company_name					= cpw.company_name
					,@company_business_line			= cpw.company_business_line
					,@company_sub_business_line		= cpw.company_sub_business_line
					,@client_address				= ca.province_name + ' ' + ca.city_name + ' ' + ca.zip_code + ' ' + ca.address
			from	client_personal_info cpi
					left join dbo.client_personal_work cpw on (
																  cpw.client_code	 = cpi.client_code
																  and  cpw.is_latest = '1'
															  )
					left join dbo.sys_general_subcode sgs on (sgs.code				 = cpi.gender_code)
					left join dbo.client_address ca on (
														   ca.client_code			 = cpi.client_code
														   and ca.is_legal			 = '1'
													   )
			where	cpi.client_code = @p_reff_no ;

			set @result = @p_source + ' For Client No ' + @p_reff_no + ' - ' + @client_name + ', Gender : ' + @gender + ', Age : ' + @umur_client + ' Work at ' + @company_name + @company_business_line + @company_sub_business_line + '. And Position at ' + @work_position + ' Address : ' + @client_address ;
		end ;
		else
		begin
			select	@client_name					= full_name
					,@company_name					= sgs.description
					,@company_business_line			= sgs2.description
					,@company_sub_business_line		= sgsd.description
					,@client_address				= ca.province_name + ' ' + ca.city_name + ' ' + ca.zip_code + ' ' + ca.address
			from	dbo.client_corporate_info cpi
					left join dbo.sys_general_subcode sgs on (sgs.code							= cpi.corporate_type_code)
					left join dbo.sys_general_subcode sgs2 on (sgs2.code						= cpi.business_line_code)
					left join dbo.sys_general_subcode_detail sgsd on (sgsd.general_subcode_code = sgs2.code)
					left join dbo.client_address ca on (
														   ca.client_code						= cpi.client_code
														   and ca.is_legal						= '1'
													   )
			where	cpi.client_code = @p_reff_no ;

			set @result = @p_source + ' For Client No ' + @p_reff_no + ' - ' + @company_name + @client_name + ', Businnes Line : ' + @company_business_line + ', Sub Businnes Line : ' + @company_sub_business_line + '. Address : ' + @client_address ;
		end ;
	end ;
	else if (@p_type = 'APPLICATION')
	begin
		select	@client_name				= cm.client_name
				,@facility_description		= mf.description
				,@application_remarks		= am.application_remarks
				,@rent_amount				= am.rental_amount
				,@application_external_no	= am.application_external_no
		from	dbo.application_main am
				inner join dbo.client_main cm on (cm.code	  = am.client_code)
				inner join dbo.master_facility mf on (mf.code = am.facility_code)
		where	application_no = @p_reff_no ;

		set @result = @p_source + ' For Application No ' + @application_external_no + ' - ' + @client_name + ', For Facility ' + @facility_description + '. Total Rental Amount ' + cast(@rent_amount as nvarchar(50)) + '. ' + @application_remarks ;
	end ;   

	return @result ;
end ;


