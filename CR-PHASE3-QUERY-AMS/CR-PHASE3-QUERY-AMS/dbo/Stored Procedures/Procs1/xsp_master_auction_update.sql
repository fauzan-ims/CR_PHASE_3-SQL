

CREATE PROCEDURE dbo.xsp_master_auction_update
(
	@p_code							 nvarchar(50)
	,@p_auction_name				 nvarchar(250)
	,@p_contact_person_name			 nvarchar(250)
	,@p_contact_person_area_phone_no nvarchar(4)
	,@p_contact_person_phone_no		 nvarchar(15)
	,@p_tax_file_type				 nvarchar(10)
	,@p_tax_file_no					 nvarchar(50)=''
	,@p_tax_file_name				 nvarchar(250)=''
	,@p_tax_file_address			 nvarchar(250)=''
	,@p_area_phone_no				 nvarchar(4)
	,@p_phone_no					 nvarchar(25)
	,@p_area_fax_no					 nvarchar(4)
	,@p_fax_no						 nvarchar(25)
	,@p_email						 nvarchar(100)=''
	,@p_website						 nvarchar(100)=''
	,@p_is_validate					 nvarchar(1)
	,@p_ktp_no						 nvarchar(20)  = null
	,@p_nitku						 nvarchar(50)  = ''
	,@p_npwp_ho						 nvarchar(50)  = ''
	--
	,@p_mod_date					 datetime
	,@p_mod_by						 nvarchar(15)
	,@p_mod_ip_address				 nvarchar(15)
)
as
BEGIN

	declare @msg nvarchar(max) ;

	if @p_is_validate = 'T'
		set @p_is_validate = '1'
	else
		set @p_is_validate = '0'

	begin TRY
		
		if exists
		(
			select	1
			from	master_auction
			where	auction_name = @p_auction_name
			and		code <> @p_code
		)
		begin
			set @msg = 'Name already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

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

		update	master_auction
		set		auction_name					= upper(@p_auction_name)
				,contact_person_name			= upper(@p_contact_person_name)
				,contact_person_area_phone_no	= @p_contact_person_area_phone_no
				,contact_person_phone_no		= @p_contact_person_phone_no
				,tax_file_type					= @p_tax_file_type
				,tax_file_no					= @p_tax_file_no
				,tax_file_name					= upper(@p_tax_file_name)
				,tax_file_address				= @p_tax_file_address
				,area_phone_no					= @p_area_phone_no
				,phone_no						= @p_phone_no
				,area_fax_no					= @p_area_fax_no
				,fax_no							= @p_fax_no
				,email							= lower(@p_email)
				,website						= lower(@p_website)
				,is_validate					= @p_is_validate
				,ktp_no							= @p_ktp_no
				,nitku							= @p_nitku
				,npwp_ho						= @p_npwp_ho
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	code							= @p_code ;
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
