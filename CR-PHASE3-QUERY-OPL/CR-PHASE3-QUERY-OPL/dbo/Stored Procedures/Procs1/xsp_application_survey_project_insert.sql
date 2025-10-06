--created by, Rian at 24/05/2023 

CREATE PROCEDURE dbo.xsp_application_survey_project_insert
(
	@p_id						bigint output
	,@p_application_survey_code nvarchar(50)
	,@p_project_name			nvarchar(250)	= null
	,@p_project_owner			nvarchar(250)	= null
	,@p_main_kontraktor			nvarchar(250)	= null
	,@p_sub_kontraktor			nvarchar(250)	= null
	,@p_sub_sub_kontraktor		nvarchar(250)	= null
	,@p_main_kompetitor			nvarchar(250)	= null
	,@p_sub_kompetitor			nvarchar(250)	= null
	,@p_sub_sub_kompetitor		nvarchar(250)	= null
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
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.application_survey_project
		(
			application_survey_code
			,project_name
			,project_owner
			,main_kontraktor
			,sub_kontraktor
			,sub_sub_kontraktor
			,main_kompetitor
			,sub_kompetitor
			,sub_sub_kompetitor
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_application_survey_code
			,@p_project_name
			,@p_project_owner
			,@p_main_kontraktor
			,@p_sub_kontraktor
			,@p_sub_sub_kontraktor
			,@p_main_kompetitor
			,@p_sub_kompetitor
			,@p_sub_sub_kompetitor
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
