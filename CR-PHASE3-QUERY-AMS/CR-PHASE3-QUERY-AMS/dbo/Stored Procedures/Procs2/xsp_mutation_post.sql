CREATE PROCEDURE dbo.xsp_mutation_post
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@company_code			nvarchar(50)
			,@status				nvarchar(20)
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid				int 
			,@max_day				int
			,@mutation_date			datetime

	begin try
		select	@status				= dor.status
				,@company_code		= dor.company_code
				,@mutation_date		= dor.mutation_date
		from	dbo.mutation dor
		where	dor.code = @p_code ;

		-- Asqal 12-Oct-2022 ket : for WOM to control back date based on setting (+) ====
		set @is_valid = dbo.xfn_date_validation(@mutation_date)
		select @max_day = cast(value as int) from dbo.sys_global_param where code = 'MDT'

		--if @is_valid = 0
		--begin
		--	set @msg = 'Transaki input back date maksimal tanggal ' + cast(@max_day as char(2)) + ' pada tiap bulan';
		--	raiserror(@msg ,16,-1);	    
		--end
		
		---- Arga 06-Nov-2022 ket : request wom back date only for register aset (+)
		--if datediff(month,@mutation_date,dbo.xfn_get_system_date()) > 0
		--begin
		--	set @msg = 'Transaksi back date tidak diperbolehkan untuk transaksi ini';
		--	raiserror(@msg ,16,-1);	 
		--end
		-- End of additional control ===================================================

		if (@status = 'ON PROGRESS')
		begin 
			    

			UPDATE	dbo.mutation
			set		status			= 'POST'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;

			update dbo.mutation_detail
			set		status_received = 'SENT'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	mutation_code	= @p_code
					and (status_received <> 'UNPOSTED' or status_received <> 'RECEIVED')

			
			-- send mail attachment based on setting ================================================
			--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'PSRQTR'
			--												,@p_doc_code		= @p_code
			--												,@p_attachment_flag = 0
			--												,@p_attachment_file = ''
			--												,@p_attachment_path = ''
			--												,@p_company_code	= @company_code
			--												,@p_trx_no			= @p_code
			--												,@p_trx_type		= 'MUTATION'
			-- End of send mail attachment based on setting ================================================
			
			
			-- send mail attachment based on setting ================================================
			exec dbo.xsp_master_email_notification_broadcast @p_code			= 'MUTATN'
															,@p_doc_code		= @p_code
															,@p_attachment_flag = 0
															,@p_attachment_file = ''
															,@p_attachment_path = ''
															,@p_company_code	= @company_code
															,@p_trx_no			= @p_code
															,@p_trx_type		= 'MUTATION'
			-- End of send mail attachment based on setting ================================================

		end
		else
		begin
			set @msg = 'Data Already Proceed.';
			raiserror(@msg ,16,-1);
		end
		
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
