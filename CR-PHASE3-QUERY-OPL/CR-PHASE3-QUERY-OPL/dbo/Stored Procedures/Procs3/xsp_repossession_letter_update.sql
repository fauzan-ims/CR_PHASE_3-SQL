CREATE PROCEDURE dbo.xsp_repossession_letter_update
(
	@p_code									nvarchar(50)
	,@p_branch_code							nvarchar(50)
	,@p_branch_name							nvarchar(250)
	,@p_letter_date							datetime
	,@p_letter_remarks						nvarchar(4000)
	,@p_agreement_no						nvarchar(50)
	,@p_letter_proceed_by					nvarchar(1)
	,@p_letter_executor_code				nvarchar(50)	= null
	,@p_letter_collector_code				nvarchar(50)	= null
	,@p_letter_collector_name				nvarchar(50)	= null
	,@p_letter_collector_position			nvarchar(50)	= null
	,@p_letter_signer_collector_code		nvarchar(50)	= null
	,@p_letter_signer_collector_name		nvarchar(50)	= null
	,@p_letter_signer_collector_position	nvarchar(50)	= null
	,@p_letter_eff_date						datetime		= null
	,@p_letter_exp_date						datetime		= null
	,@p_companion_name						nvarchar(250)	= null
	,@p_companion_id_no						nvarchar(50)	= null
	,@p_companion_job						nvarchar(50)	= null
	--
	,@p_mod_date							datetime
	,@p_mod_by								nvarchar(15)
	,@p_mod_ip_address						nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		
		--validsi letter date tidak boleh lebih kecil dari system date
		if (@p_letter_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Letter Date must be less than System Date.' ;
			raiserror(@msg, 16, -1) ;
		end

		--validsi letter eff date tidak boleh lebih kecil dari system date
		if (@p_letter_eff_date < dbo.xfn_get_system_date())
		begin
			set @msg = 'Letter Eff Date must be greater or equal to System Date.' ;
			raiserror(@msg, 16, -1) ;
		end

		--validsi letter exp date tidak boleh lebih kecil dari system date
		if (@p_letter_exp_date < dbo.xfn_get_system_date())
		begin
			set @msg = 'Letter Exp Date must be greater or equal to  System Date.' ;
			raiserror(@msg, 16, -1) ;
		end

		--validasi exp date tidak boleh lebih kecil dari eff date
		if (@p_letter_exp_date < @p_letter_eff_date)
		begin
			set	@msg = 'Letter Exp Date must be equal or greater than Letter Eff Date.'
			raiserror(@msg, 16, -1)
		end

		update	repossession_letter
		set		branch_code							= @p_branch_code
				,branch_name						= @p_branch_name
				,letter_date						= @p_letter_date
				,letter_remarks						= @p_letter_remarks
				,agreement_no						= @p_agreement_no
				,letter_proceed_by					= @p_letter_proceed_by
				,letter_executor_code				= @p_letter_executor_code
				,letter_collector_code				= @p_letter_collector_code
				,letter_collector_name				= @p_letter_collector_name
				,letter_collector_position			= @p_letter_collector_position
				,letter_signer_collector_code		= @p_letter_signer_collector_code
				,letter_signer_collector_name		= @p_letter_signer_collector_name
				,letter_signer_collector_position	= @p_letter_signer_collector_position
				,letter_eff_date					= @p_letter_eff_date
				,letter_exp_date					= @p_letter_exp_date
				,companion_name						= @p_companion_name
				,companion_id_no					= @p_companion_id_no
				,companion_job						= @p_companion_job
				--
				,mod_date							= @p_mod_date
				,mod_by								= @p_mod_by
				,mod_ip_address						= @p_mod_ip_address
		where	code								= @p_code ;
	end try
	begin catch
			declare @error int ;
	
			set @error = @@error ;
	
			if (@error = 2627) -- jika insert / update
			begin
				set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
			end ;
	
			if (len(@msg) <> 0)
			begin
				set @msg = 'V' + ';' + @msg ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
	
			raiserror(@msg, 16, -1) ;
	
			return ;
		end catch ;
end ;
