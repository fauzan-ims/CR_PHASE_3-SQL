CREATE PROCEDURE [dbo].[xsp_application_extention_validate]
(
	@p_id			   bigint
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					   nvarchar(max)
			,@main_contract_no		   nvarchar(50)
			,@is_standart			   nvarchar(1)
			,@is_valid				   nvarchar(1)
			,@application_no		   nvarchar(50)
			,@old_main_contrac_no	   nvarchar(50)
			,@old_main_contract_status nvarchar(50) 
			,@branch_code			   nvarchar(50)
			,@branch_name			   nvarchar(50)
			,@status				   nvarchar(15)
			,@agreement_no			   nvarchar(50)
			,@agreement_external_no	   nvarchar(50)
			,@transaction_no		   nvarchar(50)
			,@transaction_name		   nvarchar(50)
			,@transaction_date		   datetime            
			,@document_code			   nvarchar(50)
			,@remarks				   nvarchar(4000)
			,@is_received			   nvarchar(1)
			,@is_required			   nvarchar(1)
			,@promise_date				datetime

	begin try

		select	@main_contract_no = main_contract_no
				,@is_valid = is_valid
				,@application_no = application_no
		from	dbo.application_extention
		where	id = @p_id ;

		
		select	@old_main_contract_status = main_contract_status
				,@old_main_contrac_no = main_contract_no
		from	dbo.application_extention
		where	application_no = @application_no ;


		if (@is_valid = '1')
		begin
			if (
				   @old_main_contract_status = 'NEW'
				   --and	@p_main_contract_status = 'EXISTING'
			   )
			begin
				if exists
				(
					select	1
					from	dbo.application_extention
					where	main_contract_no   = @old_main_contrac_no
							and application_no <> @application_no
				)
				begin
					set @msg = N'Main Contract No : ' + @old_main_contrac_no + N' already Used' ;

					raiserror(@msg, 16, -1) ;
				end ;
			end ;
		END

		if exists
		(
			select	1 
			from	dbo.application_doc
			where	application_no = @application_no
					and	isnull(is_required,'')='1'
					and	promise_date is null
					and	isnull(is_received,'') <> '1'
		)
		begin
			select @msg = 'Please insert promise date or check receive for required documents :' + string_agg(ISNULL(sgd.document_name,''), ', ')
			from	dbo.application_doc ad
			inner join dbo.sys_general_document sgd on sgd.code = ad.document_code
			where	application_no = @application_no
					and	isnull(is_required,'')='1'
					and	promise_date is null
					and	isnull(is_received,'')  <> '1'

			raiserror(@msg, 16, -1);
		end

		if not exists
		(
			select	1
			from	dbo.main_contract_charges
			where	main_contract_no = @main_contract_no
		)
		begin
			set @msg = N'Please complete Master Charges' ;

			raiserror(@msg, 16, 1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.application_extention
			where	application_no = @application_no
					and main_contract_no = @main_contract_no
					and main_contract_status = 'NEW'
					and isnull(main_contract_file_name, '') = ''
		)
		begin
			set @msg = N'Please upload Main Contract File' ;

			raiserror(@msg, 16, 1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.application_extention
			where	application_no = @application_no
					and main_contract_no = @main_contract_no
					and is_standart	 = '0'
					and isnull(memo_file_name, '') = ''
					and main_contract_status = 'NEW'
		)
		begin
			set @msg = N'Please upload Memo because Main Contract is Non Standart' ;

			raiserror(@msg, 16, 1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.main_contract_tc
			where	main_contract_no = @main_contract_no
					and isnull(description, '')	 = '' 
		)
		begin
			set @msg = N'Please complete Main Contract Term & Condition' ;

			raiserror(@msg, 16, 1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.application_extention
			where	id			 = @p_id
					and is_valid = '1'
		)
		begin
			update	dbo.application_extention
			set		is_valid = '0'
					--
					,mod_date = @p_mod_date
					,mod_by = @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	id = @p_id ;
		end ;
		else
		begin
			update	dbo.application_extention
			set		is_valid = '1'
					--
					,mod_date = @p_mod_date
					,mod_by = @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	id = @p_id ;
		end ;

		if exists
		(
			select	1 
			from	dbo.application_extention ae
			inner join dbo.application_doc ad on ad.application_no = ae.application_no
			where	ae.id = @p_id
					and	isnull(ad.is_received,'') <> '1'
					--and isnull(ad.is_required,'') = '1'
					and	ad.promise_date is not null -- sepria 03092025: yg masuk tbo semua yang di promise, baik required atau tidak
					and ae.main_contract_no not in 
						(
							select ISNULL(transaction_no,'') from dbo.tbo_document							
						)
		)
		begin
			
			select	@branch_code		= am.branch_code
					,@branch_name		= am.branch_name
					,@application_no	= am.application_no
					,@transaction_date	= ae.cre_date
					,@transaction_no	= ae.main_contract_no
			from	dbo.application_extention ae
			inner join dbo.application_doc ad on ad.application_no = ae.application_no
			inner join dbo.application_main am on am.application_no = ae.application_no
			where	ae.id = @p_id
					--and isnull(ad.is_required,'') = '1'
					and isnull(ad.is_received, '') <>'1'
					and	ad.promise_date is not null -- sepria 03092025: yg masuk tbo semua yang di promise, baik required atau tidak
			
			declare @p_id_tbo bigint;
			exec dbo.xsp_tbo_document_insert @p_id					= @p_id_tbo OUTPUT, 
			                                 @p_branch_code			= @branch_code,     
			                                 @p_branch_name			= @branch_name,     
			                                 @p_status				= N'HOLD',          
			                                 @p_application_no		= @application_no,  
			                                 @p_agreement_no		= N'',              
			                                 @p_agreement_external_no = N'',            
			                                 @p_transaction_no		= @main_contract_no,
			                                 @p_transaction_name	= N'MASTER CONTRACT', 
			                                 @p_transaction_date	= @transaction_date,
			                                 @p_cre_date			= @p_mod_date,      
			                                 @p_cre_by				= @p_mod_by,        
			                                 @p_cre_ip_address		= @p_mod_ip_address,
			                                 @p_mod_date			= @p_mod_date,      
			                                 @p_mod_by				= @p_mod_by,        
			                                 @p_mod_ip_address		= @p_mod_ip_address 

			declare curr_tbodocdetail cursor fast_forward read_only for
			select	application_no
					,remarks
					,is_required
					,is_received
					,is_valid
					,document_code
					,promise_date
			from	dbo.application_doc
			where	application_no = @application_no
			and		promise_date is not null and isnull(is_received,'') <> '1'

			open curr_tbodocdetail;

			fetch next from curr_tbodocdetail
			into	@application_no
					,@remarks
					,@is_required
					,@is_received
					,@is_valid
					,@document_code
					,@promise_date

			while @@fetch_status = 0
			begin
				declare @p_id_detail bigint;
				exec dbo.xsp_tbo_document_detail_insert @p_id					= @p_id_detail output, 
				                                        @p_reff_code			= @main_contract_no,   
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
				
			
			fetch next from curr_tbodocdetail
				into @application_no
					,@remarks
					,@is_required
					,@is_received
					,@is_valid
					,@document_code
					,@promise_date
			end ;

			close curr_tbodocdetail ;
			deallocate curr_tbodocdetail ;
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
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
