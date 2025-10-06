CREATE PROCEDURE dbo.xsp_sppa_main_update
(
	@p_code			   nvarchar(50)
	--,@p_sppa_branch_code nvarchar(50)
	--,@p_sppa_branch_name nvarchar(250)
	,@p_sppa_date	   datetime
	,@p_sppa_status	   nvarchar(10)
	,@p_sppa_remarks   nvarchar(4000)		= ''
	--,@p_insurance_code	 nvarchar(50)
	--,@p_insurance_type	 nvarchar(10)
	--,@p_file_name		 nvarchar(250)
	--,@p_paths			 nvarchar(250)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if (@p_sppa_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Date must be less than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		update	sppa_main
		--set		sppa_branch_code	= @p_sppa_branch_code
		--		,sppa_branch_name	= @p_sppa_branch_name
		set		sppa_date = @p_sppa_date
				,sppa_status = @p_sppa_status
				,sppa_remarks = @p_sppa_remarks
				--,insurance_code		= @p_insurance_code
				--,insurance_type		= @p_insurance_type
				--,file_name			= @p_file_name
				--,paths				= @p_paths
				--
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code = @p_code ;
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
