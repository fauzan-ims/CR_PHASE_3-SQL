CREATE PROCEDURE [dbo].[xsp_claim_main_proceed]
(		
	@p_code					nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@system_date				datetime      = dbo.xfn_get_system_date()
			,@claim_date				datetime
			,@claim_progress_code		nvarchar(20)
			,@claim_remark				nvarchar(400)
			,@is_policy_terminate       nvarchar(1)
			,@is_ex_gratia				nvarchar(1)
			,@claim_status				nvarchar(10)
			,@policy_code				nvarchar(50)
			,@policy_no					nvarchar(50)

	if @is_policy_terminate = 'T'
		set @is_policy_terminate = '1' ;
	else
		set @is_policy_terminate = '0' ;


	if @is_ex_gratia = 'T'
		set @is_ex_gratia = '1' ;
	else
		set @is_ex_gratia = '0' ;

	begin try
		select @is_policy_terminate = is_policy_terminate
			   ,@is_ex_gratia       = is_ex_gratia
		from  dbo.claim_main
		where code = @p_code

		if not exists (select 1 from dbo.claim_detail_asset where claim_code = @p_code)
		begin
		    set @msg = 'Please add asset first.';
    		raiserror(@msg, 16, -1) ;
		end

		if exists (select 1 from dbo.claim_doc where claim_code = @p_code and file_name is null and paths is null)
		begin
		    set @msg = 'Please complate document.';
    		raiserror(@msg, 16, -1) ;
		end

		if not exists (select 1 from dbo.claim_doc where claim_code = @p_code)
		begin
		    set @msg = 'Please add document.';
    		raiserror(@msg, 16, -1) ;
		end

		if exists (select 1 from dbo.claim_main where code = @p_code and claim_status <> 'HOLD')
		begin
			set @msg = 'Data already proceed.';
    		raiserror(@msg, 16, -1) ;
		end	
		else
		begin
				select	@claim_date				= customer_report_date
						,@claim_progress_code	= claim_status
						,@claim_remark			= claim_remarks
				from	dbo.claim_main
				where	code			= @p_code

				if(cast(@claim_date as date) > cast(dbo.xfn_get_system_date() as date))
				begin
					set @msg = 'Claim date can not be bigger than system date';
    				raiserror(@msg, 16, -1) ;
				end
				update	dbo.claim_main
				set		claim_status = 'ON PROCESS'
						--
						,mod_date		= @p_mod_date		
						,mod_by			= @p_mod_by			
						,mod_ip_address	= @p_mod_ip_address
				where	code			= @p_code

				exec dbo.xsp_claim_progress_insert @p_id						= 0        
				                                   ,@p_claim_code				= @p_code                 
				                                   ,@p_claim_progress_code		= 'ON PROCESS'                
				                                   ,@p_claim_progress_date		= @system_date
				                                   ,@p_claim_progress_remarks	= @claim_remark                 
				                                   ,@p_cre_date					= @p_cre_date		
				                                   ,@p_cre_by					= @p_cre_by			
				                                   ,@p_cre_ip_address			= @p_cre_ip_address
				                                   ,@p_mod_date					= @p_mod_date		
				                                   ,@p_mod_by					= @p_mod_by			
				                                   ,@p_mod_ip_address			= @p_mod_ip_address
   
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



