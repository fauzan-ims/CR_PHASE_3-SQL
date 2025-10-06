CREATE PROCEDURE dbo.xsp_application_main_reject
(
	@p_application_no	nvarchar(50)
	,@p_approval_reff	nvarchar(250)
	,@p_approval_remark nvarchar(4000)
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
			,@level_code	nvarchar(20)  ;

	begin try
		if exists
		(
			select	1
			from	dbo.application_main
			where	application_no		   = @p_application_no
					and application_status = 'ON PROCESS'
		)
		begin
			select	@level_status	= isnull(mw.description, am.level_status)
					,@level_code	= am.level_status
			from	dbo.application_main am
					left join dbo.master_workflow mw on (mw.code = am.level_status)
			where	application_no	= @p_application_no

			update	application_main
			set		application_status	= 'REJECT'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address	= @p_mod_ip_address
			where	application_no	= @p_application_no ;
			
			set @remarks = 'REJECTED from ' + @level_status + ', ' + @p_approval_remark ;
			
			exec dbo.xsp_application_approval_comment_insert @p_id				= @id output
															 ,@p_application_no = @p_application_no
															 ,@p_last_status	= 'REJECT'
															 ,@p_level_status	= @level_code		
															 ,@p_remarks		= @remarks
															 ,@p_cre_date		= @p_mod_date
															 ,@p_cre_by			= @p_mod_by
															 ,@p_cre_ip_address = @p_mod_ip_address
															 ,@p_mod_date		= @p_mod_date
															 ,@p_mod_by			= @p_mod_by
															 ,@p_mod_ip_address = @p_mod_ip_address
		end ;
		else
		begin
			raiserror('Data already process', 16, 1) ;
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

