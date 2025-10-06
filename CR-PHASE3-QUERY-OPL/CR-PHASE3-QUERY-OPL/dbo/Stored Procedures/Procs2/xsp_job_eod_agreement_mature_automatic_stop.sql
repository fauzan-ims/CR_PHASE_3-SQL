CREATE PROCEDURE dbo.xsp_job_eod_agreement_mature_automatic_stop
as
begin
	declare @msg							 nvarchar(max)
			,@system_date					 datetime	  = dbo.xfn_get_system_date()
			,@mod_date						 datetime	  = getdate()
			,@mod_by						 nvarchar(15) = 'EOD'
			,@mod_ip_address				 nvarchar(15) = 'SYSTEM'
			,@agreement_no					 nvarchar(50)
			,@maturity_code					 nvarchar(50)
			,@branch_code					 nvarchar(50)
			,@branch_name					 nvarchar(50)
			,@max_maturity_confirmation_days nvarchar(5)
			,@maturity_detail_date			 datetime 
			,@billing_type					 nvarchar(50)

	BEGIN TRY

		--select value maximum additional periode dari global param
		SELECT	@max_maturity_confirmation_days = value
		FROM	dbo.sys_global_param
		WHERE	code = 'MAXCONMADAY'

		--mencari data dangan cara loop dengan kondisi result = stop, status = on process, dan maturity dan date nya = system date 
		DECLARE currAgreementAsset CURSOR FOR
		SELECT	am.agreement_no
				,am.branch_code
				,am.branch_name
				,am.billing_type
		FROM	agreement_main am 
				OUTER APPLY
		(
			SELECT	DATEDIFF(DAY, dbo.xfn_get_system_date(), MATURITY_DATE) 'maturity_days'
			FROM	dbo.AGREEMENT_INFORMATION 
			WHERE	agreement_no = am.agreement_no
		) aaa
					
				WHERE		am.agreement_status = 'GO LIVE'
				AND		aaa.maturity_days < @max_maturity_confirmation_days 
				and			am.agreement_no not in (
							select agreement_no 
							from dbo.maturity
							where ((result = 'CONTINUE' and status in ('HOLD','ON PROCESS')) or (RESULT = 'STOP')))
				AND		am.AGREEMENT_NO NOT IN (SELECT AGREEMENT_NO FROM dbo.AGREEMENT_ASSET_AMORTIZATION WHERE ISNULL(INVOICE_NO,'')='')
				and		am.agreement_no in (select agreement_no from dbo.agreement_asset where asset_status = 'RENTED')--;

		open currAgreementAsset ;

		fetch currAgreementAsset
		into	@agreement_no
				,@branch_code
				,@branch_name
				,@billing_type

		while @@fetch_status = 0
		begin
				exec dbo.xsp_agreement_main_maturity_request_proceed @p_code			= @maturity_code output
																	 ,@p_agreement_no	= @agreement_no
																	 ,@p_branch_code	= @branch_code
																	 ,@p_branch_name	= @branch_name
																	 -- 
																	 ,@p_mod_date		= @mod_date		
																	 ,@p_mod_by			= @mod_by		
																	 ,@p_mod_ip_address = @mod_ip_address
 
				 
				select	@maturity_detail_date = dateadd(day, 1, aaa.maturity_date)
				from	dbo.maturity_detail md
						inner join dbo.agreement_asset aa on (aa.asset_no = md.asset_no)
						outer apply
							(
								select	datediff(day, getdate(), MATURITY_DATE) 'maturity_days'
										,MATURITY_DATE
								from	dbo.AGREEMENT_INFORMATION
								where	agreement_no = aa.agreement_no
										--and  = aa.asset_no
							) aaa
				where	md.maturity_code = @maturity_code ;

				 exec dbo.xsp_maturity_update @p_code				= @maturity_code
				 							 ,@p_remark				= N'Automatic Stop Contract'
				 							 ,@p_date				= @system_date
				 							 ,@p_additional_periode = 0
				 							 ,@p_pickup_date		= @maturity_detail_date
											 ,@p_new_billing_type	= @billing_type
											 -- 
											 ,@p_mod_date			= @mod_date		
											 ,@p_mod_by				= @mod_by		
											 ,@p_mod_ip_address		= @mod_ip_address

				exec dbo.xsp_maturity_proceed @p_code			 = @maturity_code
											  -- 				 
											  ,@p_mod_date		 = @mod_date		
											  ,@p_mod_by		 = @mod_by		
											  ,@p_mod_ip_address = @mod_ip_address
				

				 set @maturity_code = '';

				 set @maturity_detail_date = null;

			fetch currAgreementAsset
			into	@agreement_no
					,@branch_code
					,@branch_name
					,@billing_type 
		end ;

		close currAgreementAsset ;
		deallocate currAgreementAsset ;
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
