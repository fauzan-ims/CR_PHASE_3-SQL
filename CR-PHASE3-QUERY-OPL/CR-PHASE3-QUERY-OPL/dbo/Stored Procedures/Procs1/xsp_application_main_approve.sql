CREATE PROCEDURE [dbo].[xsp_application_main_approve]
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
			,@level_code	nvarchar(20) 
			,@branch_code	nvarchar(50) 
			,@branch_name	nvarchar(50) ;

	begin try
		if exists
		(
			select	1
			from	dbo.application_main
			where	application_no			= @p_application_no
					and application_status	= 'ON PROCESS'
		)
		begin
			select	@level_status	= isnull(mw.description, am.level_status)
					,@level_code	= am.level_status
					,@branch_code	= am.branch_code	
					,@branch_name	= am.branch_name	
			from	dbo.application_main am
					left join dbo.master_workflow mw on (mw.code = am.level_status)
			where	application_no	= @p_application_no
			
			-- update application main
			update	application_main
			set		application_status		= 'APPROVE'
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	application_no			= @p_application_no ; 

			-- Louis Senin, 07 Juli 2025 18.02.05 -- update application asset status
			begin
				exec dbo.xsp_application_asset_update_asset_status @p_application_no = @p_application_no
																	,@p_status = 'APPROVE'
					
			end
			
			update	dbo.application_information
			set		approval_code		= null
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	application_no		= @p_application_no ;
			
			exec dbo.xsp_application_main_proceed @p_application_no		= @p_application_no
												  ,@p_last_return		= 'GO LIVE'
												  ,@p_approval_comment	= ''
												  ,@p_mod_date			= @p_mod_date
												  ,@p_mod_by			= @p_mod_by
												  ,@p_mod_ip_address	= @p_mod_ip_address
							
			---- Louis Rabu, 09 Juli 2025 14.38.07 -- DICOMMENT, KARENA TBO DARI MASTER CONTRACT, BUKAN DARI APPLICATION
			----insert ke tbo document					  
			--if exists
			--(
			--	select	1
			--	from	dbo.application_doc
			--	where	application_no	= @p_application_no
			--			and is_required = '1'
			--			and received_date is null
			--)
			--begin
			--	declare @p_id bigint ;
				
			--	exec dbo.xsp_tbo_document_insert @p_id						= @p_id output -- bigint
			--									 ,@p_branch_code			= @branch_code			
			--									 ,@p_branch_name			= @branch_name			
			--									 ,@p_status					= 'HOLD'					
			--									 ,@p_application_no			= @p_application_no			
			--									 ,@p_agreement_no			= NULL
			--									 ,@p_agreement_external_no	= NULL
			--									 ,@p_cre_date				= @p_mod_date
			--									 ,@p_cre_by					= @p_mod_by
			--									 ,@p_cre_ip_address			= @p_mod_ip_address
			--									 ,@p_mod_date				= @p_mod_date
			--									 ,@p_mod_by					= @p_mod_by
			--									 ,@p_mod_ip_address			= @p_mod_ip_address
				
			--end ;
			---- Louis Rabu, 09 Juli 2025 14.38.07 -- 

			set @remarks = 'APPROVED from ' + @level_status + ', ' + @p_approval_remark ;
			
			exec dbo.xsp_application_approval_comment_insert @p_id				= @id output 
															 ,@p_application_no = @p_application_no
															 ,@p_last_status	= 'APPROVE'
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





