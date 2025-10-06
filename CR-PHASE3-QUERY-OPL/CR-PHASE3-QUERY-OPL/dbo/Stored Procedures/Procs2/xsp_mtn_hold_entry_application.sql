CREATE PROCEDURE dbo.xsp_mtn_hold_entry_application
(
   @p_application_no	 nvarchar(50) --= replace('0001152/4/08/09/2023', '/', '.') -- NO APPLICATION
   --				 
   ,@p_mtn_remark	 nvarchar(4000)
   ,@p_mtn_cre_by	 nvarchar(250)
)
as
begin
	declare @msg			 nvarchar(max)
			,@application_no nvarchar(50) = replace(@p_application_no, '/', '.')
			,@mod_date		 datetime	  = getdate() ;

	begin transaction 
	begin try 

		 SELECT 'BEFORE',APPLICATION_STATUS,LEVEL_STATUS,* FROM dbo.APPLICATION_MAIN where APPLICATION_NO = @application_no

		--validasi
		begin
			if (isnull(@p_mtn_remark, '') = '')
			begin
				set @msg = 'Harap diisi MTN Remark';
				raiserror(@msg, 16, 1) ;
				return
			end

			if (isnull(@p_mtn_cre_by, '') = '')
			begin
				set @msg = 'Harap diisi MTN Cre By';
				raiserror(@msg, 16, 1) ;
				return
			end
			
			if exists
			(
				select	1
				from	dbo.APPLICATION_MAIN
				where	application_no		   = @application_no
						and APPLICATION_STATUS <> 'GO LIVE'
			)
			begin
				set @msg = 'Application Not Go Live, Please do Cancel application via IFIN system' ;
				raiserror(@msg, 16, 1) ;
				return
			end ;

			if exists
			(
				select	1
				from	dbo.REALIZATION
				where	APPLICATION_NO = @application_no
						and STATUS	   <> 'CANCEL'
			)
			begin
				set @msg = 'Application in Realization Process' ;
				raiserror(@msg, 16, 1) ;
				return
			end ;

			if exists
			(
			select	1
			from	dbo.PURCHASE_REQUEST
			where	ASSET_NO in
					(
						select	ASSET_NO
						from	dbo.APPLICATION_ASSET
						where	application_no = @application_no
					) and REQUEST_STATUS <> 'CANCEL'
			)
			begin
				set @msg = 'Application already in Purchase Request Process, Cancel Purchase Request First if Purchase Status is ON PROCESS' ;
				raiserror(@msg, 16, 1) ;
				return
			end ;
			
			if exists
			(
				select	1
				from	dbo.opl_interface_handover_asset
				where	asset_no in
						(
							select	asset_no
							from	dbo.application_asset
							where	application_no = @application_no
						)
			)
			begin
				set @msg = 'Application already in Handover Process' ;
				raiserror(@msg, 16, 1) ;
				return
			end ;

		end ;

		--cancel application
		begin
			
			update	dbo.application_main 
			set		application_status  = 'HOLD'
					,level_status		= 'ENTRY'
					,mod_date			= getdate()
					,mod_by				= N'MTN_DATA'
					,mod_ip_address		= N'MTN_DATA'
			where	application_no		= @application_no

			--exec dbo.xsp_application_main_cancel @p_application_no	= @application_no
			--									 ,@p_mod_date		= @mod_date
			--									 ,@p_mod_by			= N'MTN_DATA'
			--									 ,@p_mod_ip_address = N'MTN_DATA' 
		end ;
		 SELECT 'AFTER',APPLICATION_STATUS,LEVEL_STATUS,* FROM dbo.APPLICATION_MAIN where APPLICATION_NO = @application_no
		--insert mtn log data
		begin
			INSERT INTO dbo.MTN_DATA_DSF_LOG
			(
				MAINTENANCE_NAME
				,REMARK
				,TABEL_UTAMA
				,REFF_1
				,REFF_2
				,REFF_3
				,CRE_DATE
				,CRE_BY
			)
			values
			(
				'MTN APPLICATION BACK TO ENTRY'
				,@p_mtn_remark
				,'APPLICATION_MAIN'
				,@application_no
				,null -- REFF_2 - nvarchar(50)
				,null -- REFF_3 - nvarchar(50)
				,getdate()
				,@p_mtn_cre_by
			)
		end

		if @@error = 0
		begin
			select 'SUCCESS'
			commit transaction ;
		end ;
		else
		begin
			select 'GAGAL'
			rollback transaction ;
		end ;
	end try
	begin catch 
		
		rollback transaction ;

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
