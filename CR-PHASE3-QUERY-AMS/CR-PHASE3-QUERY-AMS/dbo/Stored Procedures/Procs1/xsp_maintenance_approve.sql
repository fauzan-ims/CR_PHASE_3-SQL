CREATE PROCEDURE dbo.xsp_maintenance_approve
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@is_replacement	nvarchar(1)
			,@code				nvarchar(50)
			,@branch_code		nvarchar(50)
			,@branch_name		nvarchar(250)
			,@agreement_no		nvarchar(50)
			,@remark			nvarchar(4000)
			,@asset_no			nvarchar(50)
			,@delivery_address	nvarchar(4000)
			,@contact_name		nvarchar(250)
			,@contact_phone_no	nvarchar(50)
			,@remarks			nvarchar(4000)
			,@asset_code		nvarchar(50)
			,@sysdate			datetime = dbo.xfn_get_system_date()
			,@reason_code		nvarchar(50)
			,@reason			nvarchar(250)
			,@requestor			nvarchar(50)
			,@estimate_finish_date	datetime

	begin try
		update	dbo.maintenance
		set		status			= 'APPROVE'
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code = @p_code ;

		select	@is_replacement		= is_request_replacement
				,@branch_code		= a.branch_code
				,@branch_name		= a.branch_name
				,@agreement_no		= b.agreement_no
				,@remark			= a.remark
				,@asset_no			= b.asset_no
				,@delivery_address	= a.delivery_address
				,@contact_name		= a.contact_name
				,@contact_phone_no	= a.contact_phone_no
				,@asset_code		= a.asset_code
				--
				,@reason_code		= a.reason_code
				,@reason			= sgs.description
				,@requestor			= a.requestor_name
				,@estimate_finish_date = a.estimated_finish_date
		from	dbo.maintenance		 a
				inner join dbo.asset b on a.asset_code = b.code
				left join dbo.sys_general_subcode sgs on sgs.code = a.reason_code
		where	a.code = @p_code ;

		if (@is_replacement = '1')
		begin
			set @remarks = @reason + ', By: ' + @requestor + ', To: ' + @delivery_address
			--'Asset replacement from maintenance ' + @asset_code + ' to ' + @delivery_address
			exec dbo.xsp_ams_interface_asset_replacement_insert @p_code				= @code output
																,@p_branch_code		= @branch_code
																,@p_branch_name		= @branch_name
																,@p_date			= @sysdate
																,@p_agreement_no	= @agreement_no
																,@p_remark			= @remarks
																,@p_status			= 'HOLD'
																,@p_job_status		= 'HOLD'
																,@p_failed_remark	= ''
																,@p_cre_date		= @p_mod_date
																,@p_cre_by			= @p_mod_by
																,@p_cre_ip_address	= @p_mod_ip_address
																,@p_mod_date		= @p_mod_date
																,@p_mod_by			= @p_mod_by
																,@p_mod_ip_address	= @p_mod_ip_address ;

			exec dbo.xsp_ams_interface_asset_replacement_detail_insert @p_id						= 0
																	   ,@p_replacement_code			= @code
																	   ,@p_old_asset_no				= @asset_no
																	   ,@p_new_fa_code				= ''
																	   ,@p_new_fa_name				= ''
																	   ,@p_new_fa_ref_no_01			= ''
																	   ,@p_new_fa_ref_no_02			= ''
																	   ,@p_new_fa_ref_no_03			= ''
																	   ,@p_replacement_type			= 'MAINTENANCE'
																	   ,@p_reason_code				= @reason_code
																	   ,@p_estimate_return_date		= @estimate_finish_date
																	   ,@p_old_handover_in_date		= null
																	   ,@p_old_handover_out_date	= null
																	   ,@p_new_handover_out_date	= null
																	   ,@p_new_handover_in_date		= null
																	   ,@p_remark					= @remarks
																	   ,@p_delivery_address			= @delivery_address
																	   ,@p_contact_name				= @contact_name
																	   ,@p_contact_phone_no			= @contact_phone_no
																	   ,@p_ref_no					= @p_code
																	   ,@p_cre_date					= @p_mod_date
																	   ,@p_cre_by					= @p_mod_by
																	   ,@p_cre_ip_address			= @p_mod_ip_address
																	   ,@p_mod_date					= @p_mod_date
																	   ,@p_mod_by					= @p_mod_by
																	   ,@p_mod_ip_address			= @p_mod_ip_address ;
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
