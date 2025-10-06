CREATE PROCEDURE [dbo].[xsp_master_contract_approve]
(
	@p_main_contract_no	nvarchar(50)
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
			,@document_code	nvarchar(50)
			,@expired_date	datetime
			,@promise_date	datetime
			,@code			nvarchar(50)

	begin try
		if exists
		(
			select	1
			from	dbo.master_contract
			where	main_contract_no	= @p_main_contract_no
					and status			= 'ON PROCESS'
		)
		begin
			update	dbo.master_contract
			set		status				= 'APPROVE'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	main_contract_no	= @p_main_contract_no ;
			

			exec dbo.xsp_document_tbo_insert @p_code				= @code output
											 ,@p_main_contract_no	= @p_main_contract_no
											 ,@p_status				= 'HOLD'
											 ,@p_cre_date			= @p_mod_date
											 ,@p_cre_by				= @p_mod_by
											 ,@p_cre_ip_address		= @p_mod_ip_address
											 ,@p_mod_date			= @p_mod_date
											 ,@p_mod_by				= @p_mod_by
											 ,@p_mod_ip_address		= @p_mod_ip_address
			
			declare curr_doc cursor fast_forward read_only for
			select document_code
				  ,remarks
				  ,expired_date
				  ,promise_date
			from dbo.master_contract_document
			where isnull(promise_date,'') <> ''
			and main_contract_no = @p_main_contract_no
			
			open curr_doc
			
			fetch next from curr_doc 
			into @document_code
				,@remarks
				,@expired_date
				,@promise_date
			
			while @@fetch_status = 0
			begin			    
			    exec dbo.xsp_document_tbo_document_tbo_insert @p_id						= 0
			    											  ,@p_document_tbo_code		= @code
			    											  ,@p_document_code			= @document_code
			    											  ,@p_remarks				= @remarks
			    											  ,@p_filename				= ''
			    											  ,@p_paths					= ''
			    											  ,@p_expired_date			= null
			    											  ,@p_promise_date			= @promise_date
			    											  ,@p_is_required			= ''
			    											  ,@p_is_valid				= ''
			    											  ,@p_cre_date				= @p_mod_date
			    											  ,@p_cre_by				= @p_mod_by
			    											  ,@p_cre_ip_address		= @p_mod_ip_address
			    											  ,@p_mod_date				= @p_mod_date
			    											  ,@p_mod_by				= @p_mod_by
			    											  ,@p_mod_ip_address		= @p_mod_ip_address
			    
			
			    fetch next from curr_doc 
				into @document_code
					,@remarks
					,@expired_date
					,@promise_date
			end
			
			close curr_doc
			deallocate curr_doc
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





