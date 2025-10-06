CREATE PROCEDURE [dbo].[xsp_stop_billing_approve]
(
	@p_code				nvarchar(50)
	,@p_approval_reff	nvarchar(250)
	,@p_approval_remark nvarchar(4000)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg			 nvarchar(max)
			,@aggreement_no  nvarchar(50) 
			,@terminate_date datetime

	begin try
		if exists
		(
			select	1
			from	dbo.stop_billing
			where	status	 = 'ON PROCESS'
					and code = @p_code
		)
		begin

			-- update application main
			update	dbo.stop_billing
			set		status			= 'APPROVE'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;

			select	@aggreement_no = agreement_no
					,@terminate_date = date
			from	dbo.stop_billing
			where	code = @p_code ;
		 
			update	dbo.agreement_main
			set		is_stop_billing			= '1'
					,agreement_status		= 'TERMINATE'
					,termination_date		= @terminate_date
					,termination_status		= 'STOP BILLING'
					,agreement_sub_status	= 'INCOMPLETE'
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	agreement_no			= @aggreement_no ;
			 
			exec dbo.xsp_aggrement_asset_to_handover_asset_insert @p_code				= @p_code
																  ,@p_agreement_no		= @aggreement_no
																  ,@p_date				= @p_mod_date
																  ,@p_cre_date			= @p_mod_date
																  ,@p_cre_by			= @p_mod_by
																  ,@p_cre_ip_address	= @p_mod_ip_address
																  ,@p_mod_date			= @p_mod_date
																  ,@p_mod_by			= @p_mod_by
																  ,@p_mod_ip_address	= @p_mod_ip_address 

			exec dbo.xsp_agreement_main_update_terminate_status @p_agreement_no			= @aggreement_no
																,@p_termination_date	= @terminate_date
																,@p_mod_date			= @p_mod_date
																,@p_mod_by				= @p_mod_by
																,@p_mod_ip_address		= @p_mod_ip_address

			-- update opl status
			exec dbo.xsp_agreement_main_update_opl_status @p_agreement_no = @aggreement_no
														  ,@p_status = N'' ;
		end ;
		else
		begin
			set @msg = N'Data already process' ;

			raiserror(@msg, 16, 1) ;
		end ;
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
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
