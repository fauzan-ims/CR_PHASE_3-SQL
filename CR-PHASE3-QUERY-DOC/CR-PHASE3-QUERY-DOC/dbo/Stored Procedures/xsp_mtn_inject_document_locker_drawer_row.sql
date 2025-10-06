CREATE PROCEDURE dbo.xsp_mtn_inject_document_locker_drawer_row
(
   @p_branch_code	 nvarchar(50)	--= N'2025'
   ,@p_branch_name	 nvarchar(4000) --= N'Banjarmasin'
   ,@p_jmlh_lemari	 bigint			--= 0
   ,@p_jmlh_laci	 bigint			--= 0
   ,@p_jmlh_sekat	 bigint			--= 0
   --				 
   ,@p_mtn_remark	 nvarchar(4000)
   ,@p_mtn_cre_by	 nvarchar(250)
)
as
begin
	declare @msg			 nvarchar(max)
			,@no			 int			= 1
			,@drawer_no		 int			= 1
			,@row_no		 int			= 1
			,@locker_code	 nvarchar(50)
			,@locker_name	 nvarchar(4000) 
			,@is_active		 nvarchar(1)	= N'T'
			,@drawer_code	 nvarchar(50)
			,@drawer_name	 nvarchar(4000)
			,@row_code		 nvarchar(50)
			,@row_name		 nvarchar(4000)
			,@cre_date		 datetime		= getdate()
			,@cre_by		 nvarchar(15)	= N'INJECT'
			,@cre_ip_address nvarchar(15)	= N'INJECT'
			,@mod_date		 datetime		= getdate()
			,@mod_by		 nvarchar(15)	= N'INJECT'
			,@mod_ip_address nvarchar(15)	= N'INJECT' ; 

	begin transaction 
	begin try 
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
				from	dbo.master_locker
				where	branch_code		= @p_branch_code
						and branch_name = @p_branch_name
			)
			begin
				set @msg = N'Branch : ' + @p_branch_code + N' - ' + @p_branch_name + N' already exists' ;

				raiserror(@msg, 16, 1) ;

				return ;
			end ;
		end ;

		--inject locker drawer and row
		begin
			while (@no <= @p_jmlh_lemari)
			begin
					set @locker_code = upper(@p_branch_name + N'-LEMARI-' + cast(@no as nvarchar(3))) ;
					set @locker_name = upper(cast(right(@p_branch_code, 2) as nvarchar(3)) + '-LEMARI-' + cast(@no as nvarchar(3))) ;

					exec dbo.xsp_master_locker_insert @p_code				= @locker_code		  
													  ,@p_locker_name		= @locker_name 
													  ,@p_branch_code		= @p_branch_code 
													  ,@p_branch_name		= @p_branch_name 
													  ,@p_is_active			= @is_active	  
													  ,@p_cre_date			= @cre_date		 
													  ,@p_cre_by			= @cre_by		 
													  ,@p_cre_ip_address	= @cre_ip_address 
													  ,@p_mod_date			= @mod_date		 
													  ,@p_mod_by			= @mod_by		 
													  ,@p_mod_ip_address	= @mod_ip_address 

				while (@drawer_no <= @p_jmlh_laci)
				begin
					set @drawer_code = upper(cast(right(@p_branch_code, 2) as nvarchar(3)) + N'-LEMARI ' + cast(@no as nvarchar(3)) + N'-LACI-' + cast(@drawer_no as nvarchar(3))) ;
					set @drawer_name = upper(cast(right(@p_branch_code, 2) as nvarchar(3)) + N'-LACI-' + cast(@drawer_no as nvarchar(3)));

					exec dbo.xsp_master_drawer_insert @p_code				= @drawer_code
													  ,@p_drawer_name		= @drawer_name
													  ,@p_locker_code		= @locker_code
													  ,@p_is_active			= @is_active
													  ,@p_cre_date			= @cre_date		 
													  ,@p_cre_by			= @cre_by		 
													  ,@p_cre_ip_address	= @cre_ip_address 
													  ,@p_mod_date			= @mod_date		 
													  ,@p_mod_by			= @mod_by		 
													  ,@p_mod_ip_address	= @mod_ip_address 
										  
						while (@row_no <= @p_jmlh_sekat)
						begin

							if (@drawer_code like '%-LEMARI 1%')
							begin
								set @row_code = upper(cast(right(@p_branch_code, 2) as nvarchar(3))+ N'-LACI ' + cast(@drawer_no as nvarchar(3)) + '-SEKAT-' + cast(@row_no as nvarchar(3))) ;
							end ;
							else
							begin
								set @row_code = upper(cast(right(@p_branch_code, 2) as nvarchar(3)) + N'-LMR ' + cast(@no as nvarchar(3)) + N'-LACI ' + cast(@drawer_no as nvarchar(3)) + '-SEKAT-' + cast(@row_no as nvarchar(3))) ;
							end ;

							set @row_name = upper(cast(right(@p_branch_code, 2) as nvarchar(3)) + N'-SEKAT-' + cast(@row_no as nvarchar(3))) ;

							exec dbo.xsp_master_row_insert @p_code				= @row_code
														   ,@p_row_name			= @row_name
														   ,@p_drawer_code		= @drawer_code
														   ,@p_is_active		= @is_active
														   ,@p_cre_date			= @cre_date		 
														   ,@p_cre_by			= @cre_by		 
														   ,@p_cre_ip_address	= @cre_ip_address 
														   ,@p_mod_date			= @mod_date		 
														   ,@p_mod_by			= @mod_by		 
														   ,@p_mod_ip_address	= @mod_ip_address 

							set @row_no += 1
						end

					set @row_no = 1 ;
					set @drawer_no += 1
				end
				set @drawer_no = 1 ;
				set @no += 1 ;
			end ;
		end ;

		SELECT * FROM dbo.MASTER_LOCKER where CRE_BY = 'INJECT'
		SELECT * FROM dbo.MASTER_DRAWER where CRE_BY = 'INJECT'
		SELECT * FROM dbo.MASTER_ROW where CRE_BY = 'INJECT'

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
				'MTN DOC LOCKER'
				,@p_mtn_remark
				,'MASTER_LOCKER'
				,@p_branch_code
				,@p_branch_name
				,null
				,getdate()
				,@p_mtn_cre_by
			)
		end

		if @@error = 0
		begin
			select 'SUCCESS'
			commit transaction ;
			--rollback transaction ;
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
