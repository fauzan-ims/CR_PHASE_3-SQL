CREATE PROCEDURE [dbo].[xsp_realization_post]
(
	@p_code				nvarchar(50)
	,@p_result			nvarchar(4000) = null
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

	begin try
			
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
					and is_required = '1'
					and isnull(is_valid,'') <> 1
		)
		begin
			set @msg = N'Please Validate the Documents ' + (select top 1 sgd.document_name
			from	dbo.realization_doc ad
					inner join dbo.sys_general_document sgd on (sgd.code = ad.document_code)
			where	realization_code	= @p_code
					and is_required = '1'
					and isnull(is_valid,'') <> 1)

			raiserror(@msg, 16, -1) ;
		end ;


		--validasi jika tbo blm di validated
		if exists
		(
			select	1
			from	dbo.realization_doc
			where	realization_code	= @p_code
					and isnull(is_received,'') <> '1'
					and isnull(is_valid,'') = 1
		)
		begin
			set @msg = N'Document cannot be validated until it is received.'

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

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.application_extention
			where	application_no			  = @application_no
					and isnull(is_valid, '0') = '0'
		)
		begin
			set @msg = N'Please Validate Master Contract' ;

			raiserror(@msg, 16, -1) ;
		end ;
		
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

				raiserror(@msg, 16, -1) ;
			end ;
		end ;

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

			raiserror(@msg, 16, 1) ;
		end ;

		if (isnull(@p_result, '') = '')
		begin
			set	@msg = 'Please Input Result Realization Information'
			raiserror(@msg, 16, 1)
		end

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
			set		status					= 'POST'
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
                    
				set @remark_log = 'Realization Post : ' + @p_code + ' for Agreement : ' + @agreement_external_no;

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

