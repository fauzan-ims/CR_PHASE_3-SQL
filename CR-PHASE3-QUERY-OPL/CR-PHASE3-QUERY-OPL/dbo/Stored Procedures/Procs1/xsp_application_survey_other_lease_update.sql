--created by, Rian at 24/05/2023 

CREATE PROCEDURE dbo.xsp_application_survey_other_lease_update 
(
	@p_id						bigint
	,@p_application_survey_code nvarchar(50)
	,@p_rental_company			nvarchar(250)	= null
	,@p_unit					int	= 0
	,@p_jenis_kendaraan			nvarchar(250)	= null
	,@p_os_periode				int	= 0
	,@p_nilai_pinjaman			decimal(18, 2)	= null
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare	@msg	nvarchar(max)
	begin try
		update	dbo.application_survey_other_lease
		set		rental_company		= @p_rental_company
				,unit				= @p_unit
				,jenis_kendaraan	= @p_jenis_kendaraan
				,os_periode			= @p_os_periode
				,nilai_pinjaman		= @p_nilai_pinjaman
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
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
