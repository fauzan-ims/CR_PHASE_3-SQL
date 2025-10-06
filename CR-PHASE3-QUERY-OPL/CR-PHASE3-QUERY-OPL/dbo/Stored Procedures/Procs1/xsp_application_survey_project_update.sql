--created by, Rian at 24/05/2023 

CREATE PROCEDURE dbo.xsp_application_survey_project_update
(
	@p_id						bigint
	,@p_application_survey_code nvarchar(50)
	,@p_project_name			nvarchar(250)	 = null
	,@p_project_owner			nvarchar(250)	 = null
	,@p_main_kontraktor			nvarchar(250)	 = null
	,@p_sub_kontraktor			nvarchar(250)	 = null
	,@p_sub_sub_kontraktor		nvarchar(250)	 = null
	,@p_main_kompetitor			nvarchar(250)	 = null
	,@p_sub_kompetitor			nvarchar(250)	 = null
	,@p_sub_sub_kompetitor		nvarchar(250)	 = null
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
AS
BEGIN
	declare	@msg	nvarchar(max)
	begin try
		update	dbo.APPLICATION_SURVEY_PROJECT
		set		project_name			= @p_project_name			
				,project_owner			= @p_project_owner			
				,main_kontraktor		= @p_main_kontraktor			
				,sub_kontraktor			= @p_sub_kontraktor			
				,sub_sub_kontraktor		= @p_sub_sub_kontraktor		
				,main_kompetitor		= @p_main_kompetitor			
				,sub_kompetitor			= @p_sub_kompetitor			
				,sub_sub_kompetitor		= @p_sub_sub_kompetitor				
				,mod_date				= @p_mod_date				
				,mod_by					= @p_mod_by					
				,mod_ip_address			= @p_mod_ip_address	
		where	application_survey_code	= @p_application_survey_code
		and		id						= @p_id	
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
END
