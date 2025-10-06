CREATE PROCEDURE dbo.xsp_ext_client_corporate_info_insert
(
	@p_client_code				nvarchar(50) 
	,@p_MrCompanyTypeCode		nvarchar(50) = ''
	,@p_EstablishmentDt			datetime	= NULL	
	,@p_Website					nvarchar(50) = ''
	,@p_PhnArea1				nvarchar(4)  = ''
	,@p_Phn1					nvarchar(15) = ''
	,@p_PhnArea2				nvarchar(4)  = ''
	,@p_Phn2					nvarchar(15) = ''
	,@p_Email1					nvarchar(50) = ''
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)  
			,@business_experience_year	int  
			,@CustFullName				nvarchar(250)
			 

	begin try
		set @business_experience_year = datediff(yy, @p_EstablishmentDt, getdate()) 

		select	@custfullname = client_name
		from	dbo.client_main
		where	code = @p_client_code ;
		 
		insert into client_corporate_info
		(
			client_code
			,full_name
			,est_date
			,business_experience_year
			,corporate_type_code
			,website
			,area_mobile_no
			,mobile_no
			,area_fax_no
			,fax_no
			,email
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
			,upper(@custfullname)
			,@p_EstablishmentDt
			,@business_experience_year
			,'PT'--@p_MrCompanyTypeCode
			,@p_Website
			,@p_PhnArea1
			,@p_Phn1
			,@p_PhnArea2
			,@p_Phn2
			,@p_Email1
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
										
		exec dbo.sys_client_doc_generate_default_document @p_client_code		= @p_client_code
														  ,@p_client_type		= 'CORPORATE' 
														  ,@p_cre_date			= @p_cre_date
														  ,@p_cre_by			= @p_cre_by
														  ,@p_cre_ip_address	= @p_cre_ip_address
														  ,@p_mod_date			= @p_mod_date
														  ,@p_mod_by			= @p_mod_by
														  ,@p_mod_ip_address	= @p_mod_ip_address 
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
