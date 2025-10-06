CREATE PROCEDURE dbo.xsp_repossession_letter_request
(
	@p_code							nvarchar(50)
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	
	declare @msg					nvarchar(max)
			,@log_remarks			nvarchar(4000)
			,@agreement_no			nvarchar(50)
			,@letter_type			nvarchar(3)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@letter_date			datetime
            ,@letter_status			nvarchar(20)
			,@asset_no				nvarchar(50)
			,@letter_no				nvarchar(50)

	begin try
		
			select	@agreement_no	= rl.agreement_no 
					,@branch_code	= branch_code
					,@branch_name	= branch_name
					,@letter_date	= letter_date
					,@letter_no		= rl.letter_no
			from	dbo.repossession_letter rl
			where	code			= @p_code

			--validasi data repossession harus lengkap
			if exists
			(
				select * from dbo.repossession_letter
				where	code = @p_code
				and		(
							isnull(letter_eff_date, '') = ''
							or isnull(letter_exp_date, '') = ''
							or isnull(letter_collector_code, '') = ''
							or isnull(letter_signer_collector_code, '') = ''
						)
			)
			begin
				set	@msg = 'Please Completed Data SKT'
				raiserror(@msg, 16, -1)
			end

			--if not exists(select 1 from agreement_asset where agreement_no = @agreement_no and asset_status = 'AVAILABLE')
			--begin
			--	set @msg = 'The Agreement has no avilable Collateral';
			--	raiserror(@msg ,16,-1)
			--end
        
			if exists(select 1 from dbo.repossession_letter where code = @p_code and letter_status <> 'HOLD')
			begin				
				set @msg = dbo.xfn_get_msg_err_data_already_proceed();
				raiserror(@msg ,16,-1)
			end
			else
			begin
            
			declare c_skt cursor local fast_forward for
		
			select	ac.asset_no
			from	dbo.repossession_letter rlm
					inner join dbo.agreement_asset ac on ac.agreement_no = rlm.agreement_no
			where	rlm.code	 = @p_code

			open	c_skt
			fetch	c_skt
			into	@asset_no

			while @@fetch_status = 0
			begin
					
					if not exists (select asset_no from dbo.repossession_letter_collateral where asset_no = @asset_no and is_success_repo = '1')
					begin
						exec dbo.xsp_repossession_letter_collateral_insert  @p_id					= 0
																			,@p_letter_code			= @p_code
																			,@p_asset_no			= @asset_no
																			,@p_is_success_repo		= ''
																			,@p_cre_date			= @p_cre_date           
																			,@p_cre_by				= @p_cre_by           
																			,@p_cre_ip_address		= @p_cre_ip_address     
																			,@p_mod_date			= @p_mod_date           
																			,@p_mod_by				= @p_mod_by             
																			,@p_mod_ip_address		= @p_mod_ip_address  
					end
				 
				fetch	c_skt
				into	@asset_no

			end
			close c_skt
			deallocate c_skt

			--update data di tabel reposession letter set status nya menjadi POST
			update	dbo.repossession_letter
			set		letter_status		= 'POST'
					--
					,mod_date			= @p_mod_date		
					,mod_by				= @p_mod_by			
					,mod_ip_address		= @p_mod_ip_address	
			where	code				= @p_code

			--input data ke agreement log
			set		@log_remarks = 'Repossession Letter Request ' + @p_code
			exec dbo.xsp_agreement_log_insert @p_id					= 0
											  ,@p_agreement_no		= @agreement_no
											  ,@p_log_date			= @p_cre_date
											  ,@p_log_source_no		= @p_code
											  ,@p_asset_no			= @asset_no
											  ,@p_log_remarks		= @log_remarks
											  --
											  ,@p_cre_date			= @p_cre_date		
											  ,@p_cre_by			= @p_cre_by			
											  ,@p_cre_ip_address	= @p_cre_ip_address	
											  ,@p_mod_date			= @p_mod_date		
											  ,@p_mod_by			= @p_mod_by			
											  ,@p_mod_ip_address	= @p_mod_ip_address

			--update agreement information set skt status nya menjadi SKT
			update	dbo.agreement_information
			set		skt_status			= 'SKT'
					--
					,mod_date			= @p_mod_date		
					,mod_by				= @p_mod_by			
					,mod_ip_address		= @p_mod_ip_address
			where	agreement_no		= @agreement_no
			 
		end			

	end try
	begin catch
			declare @error int ;
	
			set @error = @@error ;
	
			if (@error = 2627) -- jika insert / update
			begin
				set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
			end ;
			else if (@error = 547) -- untuk delete saja
			begin
				set @msg = dbo.xfn_get_msg_err_code_already_used() ;
			end ;
	
			if (len(@msg) <> 0)
			begin
				set @msg = 'V' + ';' + @msg ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
	
			raiserror(@msg, 16, -1) ;
	
			return ;
		end catch ;

end
