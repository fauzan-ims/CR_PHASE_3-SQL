CREATE PROCEDURE [dbo].[xsp_ext_client_personal_info_insert]
(
	@p_client_code				nvarchar(50) 
	,@p_CustFullName			nvarchar(250) = ''
	,@p_NickName				nvarchar(250) = ''
	,@p_BirthPlace				nvarchar(250) = ''
	,@p_BirthDt					datetime
	,@p_MotherMaidenName		nvarchar(250) = ''
	,@p_MrGenderCode			nvarchar(1)   = ''
	,@p_MrReligionCode			nvarchar(50)  = ''
	,@p_MrEducationCode			nvarchar(50)  = ''
	,@p_MrNationalityCode		nvarchar(50)  = ''
	,@p_MrMaritalStatCode		nvarchar(50)  = ''
	,@p_MobilePhnNo1			nvarchar(15)  = ''
	,@p_Email1					nvarchar(50)  = ''
	,@p_NoOfDependents			int 		  = 0
	--
	
	,@p_cre_date					datetime	   
	,@p_cre_by					nvarchar(15)  
	,@p_cre_ip_address			nvarchar(15)  
	,@p_mod_date				datetime	   
	,@p_mod_by					nvarchar(15)  
	,@p_mod_ip_address			nvarchar(15)  
)
as
begin
	declare @msg			nvarchar(max)  

	begin try  
		insert into client_personal_info
		(
			client_code
			,full_name
			,mother_maiden_name
			,place_of_birth
			,date_of_birth
			,nationality_type_code
			,alias_name
			,gender_code
			,religion_type_code
			,education_type_code
			,marriage_type_code
			,mobile_no
			,email
			,dependent_count
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
			,UPPER(@p_CustFullName)
			,upper(@p_MotherMaidenName)
			,upper(@p_BirthPlace)
			,@p_BirthDt
			,null--@p_MrNationalityCode
			,@p_NickName
			,null--@p_MrGenderCode
			,null--case when @p_MrReligionCode = 'I' then 'ISLAM' else '' end
			,null--@p_MrEducationCode
			,null--@p_MrMaritalStatCode
			,@p_MobilePhnNo1
			,@p_Email1
			,@p_NoOfDependents
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ; 

		exec dbo.sys_client_doc_generate_default_document @p_client_code		= @p_client_code
														  ,@p_client_type		= 'PERSONAL' 
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





