--created by, Rian at 24/05/2023 

CREATE PROCEDURE [dbo].[xsp_application_survey_bank_detail_update]
(
	@p_id						   bigint
	,@p_application_survey_bank_id nvarchar(50)
	,@p_company					   nvarchar(250) = ''
	,@p_monthly_amount			   decimal(18, 2) = 0
	,@p_average					   decimal(18, 2) = 0
	-- (+) Ari 2023-09-19 ket : add mutation month & year
	,@p_mutation_month			   nvarchar(20)		  = null 
	,@p_mutation_year			   nvarchar(4)		  = null 
	,@p_mod_date				   datetime
	,@p_mod_by					   nvarchar(15)
	,@p_mod_ip_address			   nvarchar(15)
)
as
begin
	declare	@msg	nvarchar(max)
	begin try
		update	dbo.APPLICATION_SURVEY_BANK_DETAIL
		set		company			= @p_company					  
				,monthly_amount	= @p_monthly_amount			  
				,average		= @p_average		
				-- (+) Ari 2023-09-19 ket : add mutation month & year
				,mutation_month	= @p_mutation_month
				,mutation_year	= @p_mutation_year
				--
				,mod_date		= @p_mod_date				  
				,mod_by			= @p_mod_by					  
				,mod_ip_address	= @p_mod_ip_address			  
		where	application_survey_bank_id = @p_application_survey_bank_id
		and		id							= @p_id
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
