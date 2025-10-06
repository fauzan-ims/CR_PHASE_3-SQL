CREATE PROCEDURE dbo.xsp_client_kyc_insert_from_cms
(
	@p_client_code		 nvarchar(50)
	,@p_ao_remark		 nvarchar(100)  = null
	,@p_ao_source_fund	 nvarchar(100)  = null
	,@p_result_status	 nvarchar(20)   = null
	,@p_result_remark	 nvarchar(4000) = null
	,@p_kyc_officer_code nvarchar(50)   = null
	,@p_kyc_officer_name nvarchar(250)  = null
	--
	,@p_cre_date		 datetime
	,@p_cre_by			 nvarchar(15)
	,@p_cre_ip_address	 nvarchar(15)
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into client_kyc
		(
			client_code
			,ao_remark
			,ao_source_fund
			,result_status
			,result_remark 
			,kyc_officer_code
			,kyc_officer_name
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
			,@p_ao_remark
			,@p_ao_source_fund
			,@p_result_status
			,@p_result_remark 
			,@p_kyc_officer_code
			,@p_kyc_officer_name
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

