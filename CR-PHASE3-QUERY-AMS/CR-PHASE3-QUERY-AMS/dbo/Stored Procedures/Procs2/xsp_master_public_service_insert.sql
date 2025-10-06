

CREATE PROCEDURE dbo.xsp_master_public_service_insert
(
	@p_code							 nvarchar(50)  = '' output
	,@p_public_service_name			 nvarchar(250)
	,@p_contact_person_name			 nvarchar(250)
	,@p_contact_person_area_phone_no nvarchar(4)
	,@p_contact_person_phone_no		 nvarchar(15)
	,@p_tax_file_type				 nvarchar(10)
	,@p_tax_file_no					 nvarchar(50)  = ''
	,@p_tax_file_name				 nvarchar(250) = ''
	,@p_tax_file_address			 nvarchar(250) = ''
	,@p_area_phone_no				 nvarchar(4)
	,@p_phone_no					 nvarchar(25)
	,@p_area_fax_no					 nvarchar(4)   = ''
	,@p_fax_no						 nvarchar(25)  = ''
	,@p_email						 nvarchar(100) = ''
	,@p_website						 nvarchar(100) = ''
	,@p_is_validate					 nvarchar(1)
	,@p_ktp_no						 nvarchar(20)  = null
	,@p_nitku						 nvarchar(50)  = ''
	,@p_npwp_pusat					 nvarchar(50)  = ''
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
	declare @msg			   nvarchar(max)
			,@code			   nvarchar(50)
			,@year			   nvarchar(4)
			,@month			   nvarchar(2)
			,@pubic_service_no nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @code output
												,''
												,''
												,'B'
												,@year
												,@month
												,'MASTER_PUBLIC_SERVICE'
												,5
												,''
												,'0'
												,'' ;

	exec dbo.xsp_get_next_unique_code_for_table @pubic_service_no output
												,''
												,''
												,'MPS'
												,@year
												,@month
												,'MASTER_PUBLIC_SERVICE'
												,5
												,''
												,'0'
												,'PUBLIC_SERVICE_NO' ;

	if @p_is_validate = 'T'
		set @p_is_validate = '1' ;
	else
		set @p_is_validate = '0' ;

	begin try
		if exists
		(
			select	1
			from	master_public_service
			where	public_service_name = @p_public_service_name
		)
		begin
			set @msg = N'Name already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (len(@p_nitku) <> 6)
		begin 
			set @msg = 'NITKU Must be 6 Digits'
			raiserror (@msg,16,-1);
		end
		
		if (@p_tax_file_type = 'P23') AND (len(@p_npwp_pusat) <> 16)
		begin 
			set @msg = 'NPWP HO Must be 16 Digits'
			raiserror (@msg,16,-1);
		end

		insert into master_public_service
		(
			code
			,public_service_no
			,public_service_name
			,contact_person_name
			,contact_person_area_phone_no
			,contact_person_phone_no
			,tax_file_type
			,tax_file_no
			,tax_file_name
			,tax_file_address
			,area_phone_no
			,phone_no
			,area_fax_no
			,fax_no
			,email
			,website
			,is_validate
			,ktp_no
			,nitku
			,npwp_pusat
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@code
			,@pubic_service_no
			,upper(@p_public_service_name)
			,upper(@p_contact_person_name)
			,@p_contact_person_area_phone_no
			,@p_contact_person_phone_no
			,@p_tax_file_type
			,@p_tax_file_no
			,upper(@p_tax_file_name)
			,@p_tax_file_address
			,@p_area_phone_no
			,@p_phone_no
			,@p_area_fax_no
			,@p_fax_no
			,lower(@p_email)
			,lower(@p_website)
			,@p_is_validate
			,@p_ktp_no
			,@p_nitku
			,@p_npwp_pusat
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
