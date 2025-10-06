--created by, Rian at /05/2023 

CREATE PROCEDURE dbo.xsp_application_survey_customer_insert
(
	@p_id						bigint output
	,@p_application_survey_code nvarchar(50) 
	,@p_name					nvarchar(250)	= null
	,@p_business				nvarchar(250)	= null
	,@p_business_location		nvarchar(4000)	= null
	,@p_unit					BIGINT	= 0
	,@p_additional_info			nvarchar(4000)	= null
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
		insert into dbo.APPLICATION_SURVEY_CUSTOMER
		(
			application_survey_code
			,name
			,business
			,business_location
			,unit
			,additional_info
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
			,@p_name
			,@p_business
			,@p_business_location
			,@p_unit
			,@p_additional_info
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
