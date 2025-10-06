CREATE PROCEDURE dbo.xsp_rec_upload_textfile_insert
(
	@p_text						nvarchar(4000)
	,@p_status					nvarchar(50)	= ''
	,@p_file_name				nvarchar(250)	= ''
    --  
    ,@p_cre_date				datetime
    ,@p_cre_by					nvarchar(15)
    ,@p_cre_ip_address			nvarchar(15)
    ,@p_mod_date				datetime
    ,@p_mod_by					nvarchar(15)
    ,@p_mod_ip_address			nvarchar(15)
)
as
begin

	declare @msg nvarchar(max) 
			,@transaction_code nvarchar(50);

	begin try 
		set @transaction_code = substring(@p_text, charindex(',', @p_text) + 5, 10)

		if (@p_status = 'DOMESTIC REMITTANCE OUTGOING' and @p_text like '%:61:%')
		begin
			begin
				if exists (select 1 from dbo.payment_transaction where code = @transaction_code and payment_status = 'ON PROCESS')
				begin 
					exec dbo.xsp_payment_transaction_paid @p_code			 = @transaction_code
														  ,@p_cre_date		 = @p_cre_date			
														  ,@p_cre_by		 = @p_cre_by				
														  ,@p_cre_ip_address = @p_cre_ip_address		
														  ,@p_mod_date		 = @p_mod_date			
														  ,@p_mod_by		 = @p_mod_by				
														  ,@p_mod_ip_address = @p_mod_ip_address	 
				end
			end
		end
		else if (@p_status = 'DOMESTIC REMITTANCE INCOMING' and @p_text like '%:61:%')
		begin
			begin
				if exists (select 1 from dbo.payment_transaction where code = @transaction_code and payment_status = 'ON PROCESS')
				begin    
					exec dbo.xsp_payment_transaction_cancel @p_code				= @transaction_code
															,@p_cre_date		= @p_cre_date		
															,@p_cre_by			= @p_cre_by		
															,@p_cre_ip_address	= @p_cre_ip_address
															,@p_mod_date		= @p_mod_date		
															,@p_mod_by			= @p_mod_by		
															,@p_mod_ip_address	= @p_mod_ip_address 	

						update	dbo.payment_transaction
						set		payment_remarks = 'RETUR from MUFG - ' + payment_remarks
						where	code = @transaction_code ;
				end 
				else if exists (select 1 from dbo.payment_transaction where code = @transaction_code and payment_status = 'PAID')
				begin
						update	dbo.payment_transaction
						set		payment_remarks = 'RETUR from MUFG - ' + payment_remarks
						where	code = @transaction_code ;
				end
			end
		end

		-- insert to log
		begin
			--if not exists
			--(
			--	select 1
			--	from dbo.mufg_file_log
			--	where file_name = @p_file_name
			--)
			begin
				insert into dbo.mufg_file_log
				(
					log_date
					,file_name
					,status
					,text_line
					,transaction_code
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				values
				(
					@p_cre_date
					,@p_file_name
					,@p_status
					,@p_text
					,@transaction_code 
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
				) ;
			end;
		end;
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
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
