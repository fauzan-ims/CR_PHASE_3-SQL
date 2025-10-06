CREATE PROCEDURE dbo.xsp_client_kyc_detail_insert_from_cms
(
	@p_id					 bigint = 0
	,@p_client_code			 nvarchar(50)	 
	,@p_member_type			 nvarchar(20)	= ''
	,@p_member_code			 nvarchar(50)	= ''
	,@p_member_name			 nvarchar(250)	= ''
	,@p_is_pep				 nvarchar(1)    = '0'
	,@p_remarks_pep			 nvarchar(4000) = ''
	,@p_is_slik				 nvarchar(1)    = '0'
	,@p_remarks_slik		 nvarchar(4000) = ''
	,@p_is_dtto				 nvarchar(1)    = '0'
	,@p_remarks_dtto		 nvarchar(4000) = ''
	,@p_is_proliferasi		 nvarchar(1)    = '0'
	,@p_remarks_proliferasi	 nvarchar(4000) = ''
	,@p_is_npwp				 nvarchar(1)    = '0'
	,@p_remarks_npwp		 nvarchar(4000) = ''
	,@p_is_dukcapil			 nvarchar(1)    = '0'
	,@p_remarks_dukcapil	 nvarchar(4000) = ''
	,@p_is_jurisdiction		 nvarchar(1)    = '0'
	,@p_remarks_jurisdiction nvarchar(4000) = ''
	,@p_remarks				 nvarchar(4000) = ''
	--
	,@p_cre_date			 datetime
	,@p_cre_by				 nvarchar(15)
	,@p_cre_ip_address		 nvarchar(15)
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into client_kyc_detail
		(
			client_code
			,member_type
			,member_code
			,member_name
			,is_pep
			,remarks_pep
			,is_slik
			,remarks_slik
			,is_dtto
			,remarks_dtto
			,is_proliferasi
			,remarks_proliferasi
			,is_npwp
			,remarks_npwp
			,is_dukcapil
			,remarks_dukcapil
			,is_jurisdiction
			,remarks_jurisdiction
			,remarks
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_client_code
			,@p_member_type
			,isnull(@p_member_code, @p_client_code)
			,@p_member_name
			,@p_is_pep
			,@p_remarks_pep
			,@p_is_slik
			,@p_remarks_slik
			,@p_is_dtto
			,@p_remarks_dtto
			,@p_is_proliferasi
			,@p_remarks_proliferasi
			,@p_is_npwp
			,@p_remarks_npwp
			,@p_is_dukcapil
			,@p_remarks_dukcapil
			,@p_is_jurisdiction
			,@p_remarks_jurisdiction
			,@p_remarks
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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

