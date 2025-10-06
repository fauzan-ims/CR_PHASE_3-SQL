CREATE procedure [dbo].[xsp_application_golive_back_to_entry]
(
	@p_application_no	nvarchar(50)
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
			,@is_simulation	nvarchar(50)

	begin try
	 
		if exists
		(
			select	1
			from	dbo.application_main
			where	application_no		   = @p_application_no
					and application_status = 'GO LIVE' and level_status = 'ALLOCATION'
		)
		begin  
			if exists
			(
				select	1
				from	dbo.realization
				where	application_no = @p_application_no
						and status	   <> 'CANCEL'
			)
			begin
				set @msg = 'Application in Realization Process, Please Cancel Realization Process' ;
				raiserror(@msg, 16, 1) ;
				return
			end ;

			if exists
			(
				select	1
				from	dbo.purchase_request
				where	asset_no in
						(
							select	asset_no
							from	dbo.application_asset
							where	application_no = @p_application_no
						)
						and request_status <> 'CANCEL'
			)
			begin
				select	top 1
						@msg = N'Application already in Purchase Request Process, Cancel Purchase ' + case unit_from
																										  when 'RENT' then 'GTS '
																										  else ''
																									  end + N'Request First if Purchase Status is ON PROCESS'
				from	dbo.purchase_request
				where	asset_no in
						(
							select	asset_no
							from	dbo.application_asset
							where	application_no = @p_application_no
						)
						and request_status <> 'CANCEL' 
						order by cre_date desc

				--set @msg = 'Application already in Purchase Request Process, Cancel Purchase Request First if Purchase Status is ON PROCESS' ;
				raiserror(@msg, 16, 1) ;

				return ;
			end ;

			if exists
			(
				select	1
				from	dbo.application_asset
				where	application_no	   = @p_application_no
						and is_request_gts = '1'
			)
			begin
				select	@msg = N'Please Cancel request GTS first for asset : ' + asset_no
				from	dbo.application_asset
				where	application_no	   = @p_application_no
						and is_request_gts = '1' ;

				raiserror(@msg, 16, 1) ;

				return ;
			end ;

			
			if exists
			(
				select	1
				from	dbo.opl_interface_handover_asset
				where	asset_no in
						(
							select	asset_no
							from	dbo.application_asset
							where	application_no = @p_application_no
						)
			)
			begin
				set @msg = 'Application already in Handover Process' ;
				raiserror(@msg, 16, 1) ;
				return
			end ; 
			 
			begin
				set @remarks = 'BACK TO ENTRY from  Asset Allocation, ' + @p_approval_remark ;
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

			update	dbo.application_asset
			set		purchase_status			= 'NONE'
					,purchase_gts_status	= 'NONE'
			where	application_no			= @p_application_no ;
				

			-- Louis Senin, 07 Juli 2025 18.02.05 -- update application asset status
			begin
				exec dbo.xsp_application_asset_update_asset_status @p_application_no = @p_application_no
																	,@p_status = 'HOLD'
					
			end
		end ; 
		else
		begin
			set @msg = 'Data already Process';
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

