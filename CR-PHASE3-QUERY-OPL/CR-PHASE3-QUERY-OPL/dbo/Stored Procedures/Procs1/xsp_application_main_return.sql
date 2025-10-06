CREATE PROCEDURE [dbo].[xsp_application_main_return]
(
	@p_application_no	nvarchar(50)
	,@p_approval_code	nvarchar(50)  = null --(+) Raffi : jika return tidak melalui approval akan didefault
	,@p_approval_reff	nvarchar(250)  = ''
	,@p_approval_remark nvarchar(4000) = ''
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@id			bigint
			,@remarks		nvarchar(4000) 
			,@level_status	nvarchar(250)
			,@level_code	nvarchar(20) 
			,@is_simulation	nvarchar(1)

	begin try
		if exists
		(
			select	1
			from	dbo.application_main
			where	application_no		   = @p_application_no
					and application_status in ('ON PROCESS', 'APPROVE')
		)
		begin
			select	@level_status	= isnull(mw.description, am.level_status)
					,@level_code	= am.level_status
					,@is_simulation	= am.is_simulation
			from	dbo.application_main am
					left join dbo.master_workflow mw on (mw.code = am.level_status)
			where	application_no	= @p_application_no
			
			if	(@is_simulation = '1')
			begin
				set @remarks = 'SIMULATION RETURNED from ' + @level_status + ', ' + @p_approval_remark ;
				exec dbo.xsp_application_approval_comment_insert @p_id				= @id output -- bigint
																 ,@p_application_no = @p_application_no
																 ,@p_last_status	= 'RETURN'
																 ,@p_level_status	= @level_code		
																 ,@p_remarks		= @remarks
																 ,@p_cre_date		= @p_mod_date
																 ,@p_cre_by			= @p_mod_by
																 ,@p_cre_ip_address = @p_mod_ip_address
																 ,@p_mod_date		= @p_mod_date
																 ,@p_mod_by			= @p_mod_by
																 ,@p_mod_ip_address = @p_mod_ip_address

				set @remarks = 'SIMULATION BACK TO ENTRY from ' + @level_status + ', ' + @p_approval_remark ;
				exec dbo.xsp_application_log_insert @p_id				= @id output
													,@p_application_no	= @p_application_no
													,@p_log_date		= @p_mod_date
													,@p_log_description	= @remarks
													,@p_cre_date		= @p_mod_date
													,@p_cre_by			= @p_mod_by
													,@p_cre_ip_address	= @p_mod_ip_address
													,@p_mod_date		= @p_mod_date
													,@p_mod_by			= @p_mod_by
													,@p_mod_ip_address	= @p_mod_ip_address ;
			end
			else
			begin
				set @remarks = 'RETURNED from ' + @level_status + ', ' + @p_approval_remark ;
				exec dbo.xsp_application_approval_comment_insert @p_id				= @id output -- bigint
																 ,@p_application_no = @p_application_no
																 ,@p_last_status	= 'RETURN'
																 ,@p_level_status	= @level_code		
																 ,@p_remarks		= @remarks
																 ,@p_cre_date		= @p_mod_date
																 ,@p_cre_by			= @p_mod_by
																 ,@p_cre_ip_address = @p_mod_ip_address
																 ,@p_mod_date		= @p_mod_date
																 ,@p_mod_by			= @p_mod_by
																 ,@p_mod_ip_address = @p_mod_ip_address

				set @remarks = 'BACK TO ENTRY from ' + @level_status + ', ' + @p_approval_remark ;
				exec dbo.xsp_application_log_insert @p_id				= @id output
													,@p_application_no	= @p_application_no
													,@p_log_date		= @p_mod_date
													,@p_log_description	= @remarks
													,@p_cre_date		= @p_mod_date
													,@p_cre_by			= @p_mod_by
													,@p_cre_ip_address	= @p_mod_ip_address
													,@p_mod_date		= @p_mod_date
													,@p_mod_by			= @p_mod_by
													,@p_mod_ip_address	= @p_mod_ip_address ;
			end

			update	application_main
			set		application_status	= 'HOLD'
					,level_status		= 'ENTRY'
					,return_count		+= 1
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	application_no		= @p_application_no ;

			update	dbo.application_information
			set		approval_code		= @p_approval_code
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	application_no		= @p_application_no ;

			-- Louis Senin, 07 Juli 2025 18.02.05 -- update application asset status
			begin
				exec dbo.xsp_application_asset_update_asset_status @p_application_no = @p_application_no
																	,@p_status = 'HOLD'
					
			end

			exec dbo.xsp_application_main_return_notification @p_application_no		= @p_application_no
															  ,@p_cre_date			= @p_mod_date
															  ,@p_cre_by			= @p_mod_by
															  ,@p_cre_ip_address	= @p_mod_ip_address
															  ,@p_mod_date			= @p_mod_date
															  ,@p_mod_by			= @p_mod_by
															  ,@p_mod_ip_address	= @p_mod_ip_address
			
			
		end ;
		else
		begin
			set @msg = 'Data already process';
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
end ;

