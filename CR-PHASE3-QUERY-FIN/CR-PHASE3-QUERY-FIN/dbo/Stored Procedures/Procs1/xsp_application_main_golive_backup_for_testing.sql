create PROCEDURE [dbo].[xsp_application_main_golive_backup_for_testing]
(
	@p_application_no  nvarchar(50)  
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			   nvarchar(max)
			,@client_code	   nvarchar(50)
			,@agreement_no	   nvarchar(50)
			,@fee_name		   nvarchar(250)
			,@id			   bigint
			,@watchlist_status nvarchar(10)
			,@is_red_flag	   nvarchar(1)
			,@branch_code	   nvarchar(50)
			,@asset_no		   nvarchar(50)

	begin try

		select	@is_red_flag			= cm.is_red_flag
				,@watchlist_status		= cm.watchlist_status 
		from	dbo.application_main am
				inner join dbo.client_main cm on (cm.code = am.client_code)
		where	am.application_no		= @p_application_no ;

		-- validation
		begin
            if (@watchlist_status = 'NEGATIVE') -- jika warning masih bisa lanjut
			begin
			    set @msg = 'Client is in NEGATIVE list';
				raiserror(@msg, 16,1)
			end

            if (@is_red_flag = '1')
			begin
			    set @msg = 'Client is in Red Flag list';
				raiserror(@msg, 16,1)
			end

			if exists
			(
				select	1
				from	dbo.application_doc
				where	application_no					= @p_application_no
						and is_required					= '1'
						and isnull(paths, '')			= ''
						and isnull(waive_status, '')	<> 'WAIVED'
			)
			begin
				set @msg = 'Application Document is not complete, please upload mandatory Document' ;

				raiserror(@msg, 16, 1) ;
			end ;
 
			if exists
			(
				select	1
				from	dbo.application_scoring_request
				where	application_no	   = @p_application_no
						and scoring_status = 'REQUEST'
			)
			begin
				set @msg = 'Application Scoring Request is not completed' ;

				raiserror(@msg, 16, 1) ;
			end ;  

			if exists
			(
				select	1
				from	dbo.application_survey_request
				where	application_no	  = @p_application_no
						and survey_status = 'REQUEST'
			)
			begin
				set @msg = 'Application Survey Request is not completed' ;

				raiserror(@msg, 16, 1) ;
			end ; 

			if exists
			(
				select	1
				from	dbo.application_fee
				where	application_no		= @p_application_no
						and is_fee_paid		= '0'
						and fee_amount > 0
			)
			begin
				select top 1
						@fee_name = mf.description
				from	dbo.application_fee pf
						inner join dbo.master_fee mf on (mf.code = pf.fee_code)
				where	application_no	= @p_application_no
						and is_fee_paid	= '0'
						and fee_amount	> 0 ;

				set @msg = 'Fee ' + @fee_name + ' has not been paid' ;

				raiserror(@msg, 16, 1) ;
			end ;
		end

		-- update application main status
		begin
			
			select	@client_code	= am.client_code
					,@branch_code	= am.branch_code
			from	dbo.application_main am
			where	application_no	= @p_application_no

			-- get agreement no
			exec dbo.xsp_sys_client_running_agreement_no_generate  @p_client_code		= @client_code
																  ,@p_branch_code		= @branch_code
																  ,@p_application_type	= 'APPLICATION'
																  ,@p_agreement_no		= @agreement_no output 
																  ,@p_mod_date			= @p_mod_date		
																  ,@p_mod_by			= @p_mod_by			
																  ,@p_mod_ip_address	= @p_mod_ip_address
			
			if (@agreement_no is null)
			begin
				set @msg = 'Failed generate Agreement No';
				raiserror(@msg, 16, 1) ;
			end ;

			update	application_main
			set		application_status	= 'GO LIVE' 
					,level_status		= 'ALLOCATION'
					,golive_date		= dbo.xfn_get_system_date()
					,main_agreement_no	= @agreement_no
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
 			where	application_no		= @p_application_no;
		end

		-- Louis Senin, 07 Juli 2025 18.02.05 -- update application asset status
		begin
			exec dbo.xsp_application_asset_update_asset_status @p_application_no = @p_application_no
																,@p_status = 'ALLOCATION'
					
		end
		  
		-- insert interface aplication main sama document pending
		--exec dbo.xsp_application_main_to_interface_insert @p_application_no		= @p_application_no
		--												  ,@p_cre_date			= @p_mod_date
		--												  ,@p_cre_by			= @p_mod_by
		--												  ,@p_cre_ip_address	= @p_mod_ip_address
		--												  ,@p_mod_date			= @p_mod_date
		--												  ,@p_mod_by			= @p_mod_by
		--												  ,@p_mod_ip_address	= @p_mod_ip_address ;

		--insert notification
		--exec dbo.xsp_application_main_golive_notification @p_application_no		= @p_application_no
		--												  ,@p_cre_date			= @p_cre_date	  
		--												  ,@p_cre_by			= @p_cre_by		  
		--												  ,@p_cre_ip_address	= @p_cre_ip_address
		--												  ,@p_mod_date			= @p_mod_date	  
		--												  ,@p_mod_by			= @p_mod_by		  
		--												  ,@p_mod_ip_address	= @p_mod_ip_address
		
		-- Louis Selasa, 08 Juli 2025 13.25.08 -- 
		-- auto purchase ketika unit source = 'Purchase'
		begin
			declare currApplicationAsset cursor fast_forward read_only for
			select	asset_no
			from	dbo.application_asset
			where	application_no	= @p_application_no
					and unit_source = 'Purchase' ;

			open currApplicationAsset ;

			fetch next from currApplicationAsset
			into @asset_no ;

			while @@fetch_status = 0
			begin
			exec dbo.xsp_application_asset_purchase_request @p_asset_no			= @asset_no
															,@p_mod_date		= @p_mod_date	  
															,@p_mod_by			= @p_mod_by		  
															,@p_mod_ip_address	= @p_mod_ip_address
		
				fetch next from currApplicationAsset
				into @asset_no ;
			end ;

			close currApplicationAsset ;
			deallocate currApplicationAsset ;
		end
		-- Louis Selasa, 08 Juli 2025 13.25.16 -- 

		-- insert application log
		begin
			exec dbo.xsp_application_log_insert @p_id				= @id output 
												,@p_application_no	= @p_application_no
												,@p_log_date		= @p_mod_date
												,@p_log_description	= 'GO LIVE'
												,@p_cre_date		= @p_cre_date	  
												,@p_cre_by			= @p_cre_by		  
												,@p_cre_ip_address	= @p_cre_ip_address
												,@p_mod_date		= @p_mod_date	  
												,@p_mod_by			= @p_mod_by		  
												,@p_mod_ip_address	= @p_mod_ip_address
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

