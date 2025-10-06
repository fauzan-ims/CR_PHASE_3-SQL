

CREATE PROCEDURE dbo.xsp_master_insurance_insert
(
	@p_code							 nvarchar(50) OUTPUT 
	,@p_insurance_name				 nvarchar(250)
	,@p_contact_person_name			 nvarchar(250)
	,@p_contact_person_area_phone_no nvarchar(4)
	,@p_contact_person_phone_no		 nvarchar(15)
	,@p_insurance_type				 nvarchar(10)
	,@p_tax_file_type				 nvarchar(10) 
	,@p_tax_file_no					 nvarchar(50)  = NULL
	,@p_tax_file_name				 nvarchar(250) = NULL
	,@p_tax_file_address			 nvarchar(250) = NULL
	,@p_insurance_business_unit		 nvarchar(12)
	,@p_area_phone_no				 nvarchar(4)
	,@p_phone_no					 nvarchar(25)
	,@p_area_fax_no					 nvarchar(4)
	,@p_fax_no						 nvarchar(25)
	,@p_email						 nvarchar(100) = NULL
	,@p_website						 nvarchar(100) = NULL
	,@p_is_validate					 nvarchar(1)
	,@p_nitku						 nvarchar(50)  = ''
	,@p_npwp_ho					 nvarchar(50)  = ''
	--
	,@p_cre_date					 datetime
	,@p_cre_by						 nvarchar(15)
	,@p_cre_ip_address				 nvarchar(15)
	,@p_mod_date					 datetime
	,@p_mod_by						 nvarchar(15)
	,@p_mod_ip_address				 nvarchar(15)
)
as
begin
	declare @msg	       nvarchar(max)
			,@year	       nvarchar(2)
			,@month        nvarchar(2)
			,@code	       nvarchar(50) 
			,@insurance_no nvarchar(50);

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @insurance_no output -- nvarchar(50)
												,@p_branch_code			= N'' -- nvarchar(10)
												,@p_sys_document_code	= N'AMSINS' -- nvarchar(10)
												,@p_custom_prefix		= N'' -- nvarchar(10)
												,@p_year				= @year -- nvarchar(2)
												,@p_month				= @month -- nvarchar(2)
												,@p_table_name			= N'MASTER_INSURANCE' -- nvarchar(100)
												,@p_run_number_length	= 6 -- int
												,@p_delimiter			= N'.' -- nvarchar(1)
												,@p_run_number_only		= N'0' -- nvarchar(1)
												,@p_specified_column	= 'INSURANCE_NO'

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @code output
												,@p_branch_code			= ''
												,@p_sys_document_code	= N''
												,@p_custom_prefix		= 'I'
												,@p_year				= @year
												,@p_month				= @month
												,@p_table_name			= 'MASTER_INSURANCE'
												,@p_run_number_length	= 5
												,@p_delimiter			= ''
												,@p_run_number_only		= N'0' ;

	if @p_is_validate = 'T'
			set @p_is_validate = '1'
		else
			set @p_is_validate = '0'

	begin try
		if exists (select 1 from master_insurance where insurance_name = @p_insurance_name)
		begin
			SET @msg = 'Name already exist';
			raiserror(@msg, 16, -1) ;
		END
        
		if (len(@p_nitku) <> 6)
		begin 
			set @msg = 'NITKU Must be 6 Digits'
			raiserror (@msg,16,-1);
		end
		
		if (@p_tax_file_type = 'P23') AND (len(@p_npwp_ho) <> 16)
		begin 
			set @msg = 'NPWP HO Must be 16 Digits'
			raiserror (@msg,16,-1);
		end

		insert into master_insurance
		(
			code
			,insurance_no
			,insurance_name
			,contact_person_name
			,contact_person_area_phone_no
			,contact_person_phone_no
			,insurance_type
			,tax_file_type
			,tax_file_no
			,tax_file_name
			,tax_file_address
			,insurance_business_unit
			,area_phone_no
			,phone_no
			,area_fax_no
			,fax_no
			,email
			,website
			,is_validate
			,nitku
			,npwp_ho
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
			,@insurance_no 
			,UPPER(@p_insurance_name)
			,UPPER(@p_contact_person_name)
			,@p_contact_person_area_phone_no
			,@p_contact_person_phone_no
			,@p_insurance_type
			,@p_tax_file_type
			,@p_tax_file_no
			,UPPER(@p_tax_file_name)
			,@p_tax_file_address
			,@p_insurance_business_unit
			,@p_area_phone_no
			,@p_phone_no
			,@p_area_fax_no
			,@p_fax_no
			,lower(@p_email)
			,lower(@p_website)
			,@p_is_validate
			,@p_nitku
			,@p_npwp_ho
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_code = @code ;
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




