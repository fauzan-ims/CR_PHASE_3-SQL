CREATE PROCEDURE dbo.xsp_realization_post_with_note
(
	@p_code				NVARCHAR(50)
	,@p_result			NVARCHAR(4000) = NULL
	,@p_exp_date		DATETIME = NULL
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@application_no		nvarchar(50)
			,@agreement_no			nvarchar(50) 
			,@agreement_external_no	nvarchar(50)
			,@asset_no				nvarchar(50)
			,@branch_code		    nvarchar(50)
			,@branch_name		    nvarchar(50)
			,@status			    nvarchar(15)
			,@transaction_no	    NVARCHAR(50)
			,@transaction_name	    nvarchar(50)
			,@transaction_date	    DATETIME
            ,@realization_code		NVARCHAR(50)   
			,@document_code		    nvarchar(50)
			,@remarks			    nvarchar(4000)
			,@is_received		    nvarchar(1)
			,@is_valid			    nvarchar(1)
			,@is_required		    nvarchar(1)
			,@promise_date			datetime

	BEGIN TRY
		if (@p_exp_date is not null)
		begin
			update dbo.realization set exp_date = @p_exp_date where code = @p_code
		end

		if (cast(@p_exp_date as date) < cast(dbo.xfn_get_system_date() as date))
		begin
			set @msg = N'Exp Date Must be Greater Than System Date.' ;

			raiserror(@msg, 16, -1) ;
		end
		if exists (select 1 from dbo.realization where isnull(file_memo, '') = '' and code = @p_code)
		begin
			set @msg = N'Please Input Upload Memo And Exp Date' ;

			RAISERROR(@msg, 16, -1) ;
		end 
		else if exists (select 1 from dbo.realization where exp_date is null and code = @p_code)
		begin
			set @msg = N'Please Input Upload Memo And Exp Date' ;

			raiserror(@msg, 16, -1) ;
		end 
			

		--kebutuhan data maintenance
		begin
			exec dbo.xsp_mtn_realization_contract @p_realization_no		= @p_code
													,@p_mod_date	    = @p_mod_date
													,@p_mod_by			= @p_mod_by
													,@p_mod_ip_address	= @p_mod_ip_address
			
		end 

		select	@agreement_no				= agreement_no
				,@application_no			= application_no
				,@agreement_external_no		= agreement_external_no
		from	dbo.realization
		where	code = @p_code ;
			
		--validasi jika tbo blm di validated
		if exists
		(
			select	1
			from	dbo.realization_doc
			where	realization_code	= @p_code
					and is_required		= '1' 
					and promise_date is null 
					and isnull(is_valid,'') <> 1
		)
		begin
			set @msg = N'Please Input Promise Date : ' + 
			(
			    select stuff((
			        select ', ' + sgd.document_name
			        from dbo.realization_doc ad
			        inner join dbo.sys_general_document sgd on sgd.code = ad.document_code
			        where ad.REALIZATION_CODE = @p_code
			          and is_required = '1'
			          and promise_date is NULL
			          and isnull(is_valid,'') <> 1
			        for xml path(''), type
			    ).value('.', 'nvarchar(max)'), 1, 2, '')   -- buang koma pertama
			);


			raiserror(@msg, 16, -1) ;
		end ;



		if exists
		(
			select	1
			from	dbo.realization
			where	code									  = @p_code
					and
					(
						isnull(AGREEMENT_NO, '')			  = ''
						or	isnull(AGREEMENT_EXTERNAL_NO, '') = ''
					)
		)
		begin
			set @msg = N'Please Contact IT Support, Invalid Agreement No.' ;

			raiserror(@msg, 16, -1) ;
		end ;
	
		if not exists
		(
			select	1
			from	dbo.application_extention
			where	application_no = @application_no
		)
		begin
			set @msg = N'Please Complete Master Contract' ;

			RAISERROR(@msg, 16, -1) ;
		END ;

		if exists
		(
			select	1
			from	dbo.application_extention
			where	application_no			  = @application_no
					and isnull(is_valid, '0') = '0'
		)
		begin
			set @msg = N'Please Validate Master Contract' ;

			RAISERROR(@msg, 16, -1) ;
		END ;
		
		--kebutuhan data maintenance
		if not exists
		(
			select	1
			from	dbo.mtn_realization_contract
			where	realization_no = @p_code
		)
		begin
			if exists
			(
				select	1
				from	dbo.application_extention
				where	application_no							= @application_no
						and isnull(main_contract_file_name, '') = ''
						and main_contract_status				<> 'EXISTING'
			)
			begin
				set @msg = N'Please Complete Master Contract' ;

				RAISERROR(@msg, 16, -1) ;
			END ;
		END ;

		if exists
		(
			select	1
			from	dbo.realization
			where	code			  = @p_code
					and (
							delivery_vendor_name is null
							or	delivery_vendor_pic_name is null
						)
					and delivery_from = 'SUPPLIER'
		)
		begin
			set @msg = 'Please Compleate Realization Information' ;

			RAISERROR(@msg, 16, 1) ;
		END ;

		IF (ISNULL(@p_result, '') = '')
		BEGIN
			set	@msg = 'Please Input Result Realization Information'
			raiserror(@msg, 16, 1)
		END

		if exists
		(
			select	1
			from	dbo.realization
			where	code		= @p_code
					and status	= 'VERIFICATION'
		)
		begin 			 
			-- update realization
			update	realization
			set		status					= 'POST WITH NOTE'
					,result					= @p_result
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code					= @p_code ;
		
			-- Louis Selasa, 08 Juli 2025 10.32.39 -- 
			-- insert application log
			begin
		
				declare @remark_log nvarchar(4000)
						,@id bigint  
                    
				set @remark_log = 'Realization Post With Note : ' + @p_code + ' for Agreement : ' + @agreement_external_no;

				exec dbo.xsp_application_log_insert @p_id				= @id output 
													,@p_application_no	= @application_no
													,@p_log_date		= @p_mod_date
													,@p_log_description	= @remark_log
													,@p_cre_date		= @p_mod_date	  
													,@p_cre_by			= @p_mod_by		  
													,@p_cre_ip_address	= @p_mod_ip_address
													,@p_mod_date		= @p_mod_date	  
													,@p_mod_by			= @p_mod_by		  
													,@p_mod_ip_address	= @p_mod_ip_address
			end
			-- Louis Selasa, 08 Juli 2025 10.32.39 -- 

			if exists --raffy 2025/08/14 cr fase 3
			(
				select	1 
				from	dbo.realization ae
						inner join dbo.realization_doc ad on ad.realization_code = ae.code
				where	ae.code = @p_code
						and	isnull(ad.is_received,'')='0'
						and isnull(ad.is_required,'') = '1'
						and ae.code not in 
							(
								select isnull(transaction_no,'') 
								from dbo.tbo_document							
							)
			)
			begin		
				select	@branch_code		= am.branch_code
						,@branch_name		= am.branch_name
						,@application_no	= am.application_external_no
						,@transaction_date	= ae.cre_date
						,@transaction_no	= ae.code
				from	dbo.realization ae
				inner join dbo.realization_doc ad on ad.realization_code = ae.code
				inner join dbo.application_main am on am.application_no = ae.application_no
				where	ae.code							= @p_code
						and ad.is_required				='1'
						and isnull(ad.is_received, '')	<>'1'
				
				declare @p_id_tbo bigint;
				PRINT 'a'
				exec dbo.xsp_tbo_document_insert @p_id					  = @p_id_tbo output, 
				                                 @p_branch_code			  = @branch_code,     
				                                 @p_branch_name			  = @branch_name,     
				                                 @p_status				  = 'HOLD',          
				                                 @p_application_no		  = @application_no,  
				                                 @p_agreement_no		  = @agreement_no,              
				                                 @p_agreement_external_no = @agreement_external_no,            
				                                 @p_transaction_no		  = @transaction_no,
				                                 @p_transaction_name	  = 'REALIZATION', 
				                                 @p_transaction_date	  = @transaction_date,
				                                 @p_cre_date			  = @p_mod_date,      
				                                 @p_cre_by				  = @p_mod_by,        
				                                 @p_cre_ip_address		  = @p_mod_ip_address,
				                                 @p_mod_date			  = @p_mod_date,      
				                                 @p_mod_by				  = @p_mod_by,        
				                                 @p_mod_ip_address		  = @p_mod_ip_address 

				declare curr_tbodocdetail cursor fast_forward read_only for
				select	realization_code
						,remarks
						,is_required
						,is_received
						,is_valid
						,document_code
						,promise_date
				from	dbo.realization_doc
				where	realization_code = @p_code

				open curr_tbodocdetail;

				fetch next from curr_tbodocdetail
				into	@realization_code
						,@remarks
						,@is_required
						,@is_received
						,@is_valid
						,@document_code
						,@promise_date

				while @@fetch_status = 0
				BEGIN
					DECLARE @p_id_detail BIGINT;
					EXEC dbo.xsp_tbo_document_detail_insert @p_id					= @p_id_detail OUTPUT, 
					                                        @p_reff_code			= @realization_code,   
					                                        @p_document_code		= @document_code,      
					                                        @p_promise_date			= @promise_date, 
					                                        @p_is_required			= @is_required,        
					                                        @p_is_valid				= @is_valid,           
					                                        @p_is_receveid			= @is_received,        
					                                        @p_remarks				= @remarks,            
					                                        @p_application_no		= @application_no,     
					                                        @p_tbo_document_id		= @p_id_tbo,           
					                                        @p_cre_date				= @p_mod_date,			
					                                        @p_cre_by				= @p_mod_by,           
					                                        @p_cre_ip_address		= @p_mod_ip_address,   
					                                        @p_mod_date				= @p_mod_date,			
					                                        @p_mod_by				= @p_mod_by,           
					                                        @p_mod_ip_address		= @p_mod_ip_address    
					
				
				FETCH next from curr_tbodocdetail
					into @realization_code
						,@remarks
						,@is_required
						,@is_received
						,@is_valid
						,@document_code
						,@promise_date
				end ;

				close curr_tbodocdetail ;
				deallocate curr_tbodocdetail 

			end


			declare currrealizationdetail cursor fast_forward read_only for
			select	rd.asset_no
			from	dbo.realization_detail rd
					inner join dbo.application_asset aa on (aa.asset_no = rd.asset_no)
			where	rd.realization_code = @p_code
					and (
							aa.fa_code is not null
							or	aa.replacement_fa_code is not null
						) ;

			open currrealizationdetail ;

			fetch next from currrealizationdetail
			into @asset_no ;

			while @@fetch_status = 0
			begin
				if not exists
				(
					select	1
					from	dbo.opl_interface_handover_asset
					where	asset_no = @asset_no
							and status <> 'CANCEL'
				)
				begin 
					if exists(select 1 from dbo.application_asset where asset_no = @asset_no and isnull(is_request_gts, '0') = '1' and isnull(replacement_fa_code,'') <> '')
					begin
						exec dbo.xsp_application_asset_allocation_proceed	@p_asset_no					= @asset_no
																			,@p_agreement_no			= @agreement_no
																			,@p_agreement_external_no	= @agreement_external_no
																			--				 
																			,@p_mod_date				= @p_mod_date
																			,@p_mod_by					= @p_mod_by
																			,@p_mod_ip_address			= @p_mod_ip_address ;
					end
					else if exists (select 1 from dbo.application_asset where asset_no = @asset_no and isnull(is_request_gts, '0') = '0' and isnull(fa_code,'') <> '')
					begin
						exec dbo.xsp_application_asset_allocation_proceed	@p_asset_no					= @asset_no
																			,@p_agreement_no			= @agreement_no
																			,@p_agreement_external_no	= @agreement_external_no
																			--				 
																			,@p_mod_date				= @p_mod_date
																			,@p_mod_by					= @p_mod_by
																			,@p_mod_ip_address			= @p_mod_ip_address ;
					end
				end

				fetch next from currrealizationdetail
				into @asset_no ;
			end ;

			close currrealizationdetail ;
			deallocate currrealizationdetail ;
			
		end ;
		else
		begin
			set @msg = 'Data already proceed';
			raiserror(@msg, 16, 1) ;
		end ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message();
		end ;

		raiserror(@msg, 16, -1) ;

		return ; 
	end catch ;
end ;