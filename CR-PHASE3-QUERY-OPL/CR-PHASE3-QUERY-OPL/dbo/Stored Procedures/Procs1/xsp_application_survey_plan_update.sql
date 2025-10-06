--created by, Rian at 24/05/2023 

CREATE PROCEDURE dbo.xsp_application_survey_plan_update
(
	@p_id						bigint
	,@p_application_survey_code nvarchar(50)
	,@p_description				nvarchar(4000) = ''
	,@p_ni_amount				decimal(18, 2) = 0
	--,@p_total_ni_amount			decimal(18, 2)
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
	declare	@msg	nvarchar(max)
	begin try
		update	dbo.APPLICATION_SURVEY_PLAN
		set		description				= @p_description
				,ni_amount				= @p_ni_amount
				--,total_ni_amount		= @p_total_ni_amount
				--
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
end
