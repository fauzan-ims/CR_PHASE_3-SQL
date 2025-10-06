--Created, ALIV at 26/12/2022
CREATE PROCEDURE dbo.xsp_order_main_proceed
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
    
	declare @msg								nvarchar(max)
			,@order_status						nvarchar(20)
			,@system_date						datetime = dbo.xfn_get_system_date()
			,@bank_acc_name						nvarchar(250)
			,@bank_name							nvarchar(250)
			,@bank_acc_no						nvarchar(250)
			,@order_amount						decimal(18,2)
			,@interface_code					nvarchar(50)
			,@remarks							nvarchar(4000)
			,@branch_code						nvarchar(50)
			,@branch_name						nvarchar(250)
			,@sp_name							nvarchar(250)
			,@gl_link_code						nvarchar(50)
			,@transaction_name					nvarchar(250)
			,@debet_or_credit					nvarchar(10)
			,@return_value						decimal(18, 2)
			,@orig_amount_db					decimal(18, 2)
			,@amount							decimal(18, 2)
			,@currency							nvarchar(3)
			,@tax_file_type						nvarchar(10)
			,@tax_file_no 						nvarchar(50)
			,@public_service_code				nvarchar(50)
			,@tax_file_name						nvarchar(250)
			,@public_service_name 				nvarchar(250)
			,@is_taxable						nvarchar(1)
			,@register_code						nvarchar(50)
			,@header_amount						decimal(18,2)
			,@detail_amount						decimal(18,2)
			,@fa_code							nvarchar(50)
			,@year								nvarchar(4) 
			,@month								nvarchar(2)
			,@code_document						nvarchar(50)
			,@code								nvarchar(50)
			,@order_date						datetime
			,@order_remarks						nvarchar(4000)
			,@order_main_remarks				nvarchar(4000)
			,@id_detail							int
			,@agreement_external_no				nvarchar(50)
			,@no_kontrak						NVARCHAR(50)

	begin try
	
		select	@order_status					= om.order_status
				,@order_amount					= om.order_amount
				,@branch_name					= om.branch_name
				,@bank_acc_name					= mpsb.bank_account_name
				,@branch_code					= om.branch_code
				,@bank_name						= mpsb.bank_name
				,@bank_acc_no					= mpsb.bank_account_no
				,@public_service_name			= mps.public_service_name
				,@currency						= currency_code
				,@public_service_code			= om.public_service_code
				,@fa_code						= rm.fa_code
				,@order_date					= om.order_date
				,@order_main_remarks			= om.order_remarks
				,@agreement_external_no			= ass.agreement_external_no
		from	dbo.order_main om
				left join dbo.order_detail od on (od.order_code = om.code)
				left join dbo.register_main rm on (rm.code = od.register_code)
				--left join dbo.register_detail rd on (rd.register_code = od.register_code)
				inner join dbo.master_public_service mps on mps.code = om.public_service_code
				left join dbo.master_public_service_bank mpsb on (mpsb.public_service_code = mps.code and mpsb.is_default = '1')
				--left join dbo.master_public_service_branch_service mpsbs on (mpsbs.service_code = rd.service_code)
				inner join dbo.asset ass on (ass.code = rm.fa_code)
		where	om.code = @p_code

		if exists(	
						select	1
						from	dbo.order_detail odt
								inner join dbo.register_detail rd on (rd.register_code = odt.register_code)
								inner join dbo.order_main om on (om.code = odt.order_code)
								inner join dbo.master_public_service_branch mps on (mps.public_service_code = om.public_service_code and mps.branch_code = om.branch_code)  
						where	order_code = @p_code
								and rd.service_code not in (select service_code from dbo.master_public_service_branch_service where public_service_branch_code = mps.code)
									
					)
		begin
			set @msg = 'Service Did Not Match With Public Service.'
			raiserror(@msg ,16,-1) 
		end
		
		
		set @remarks = 'PAYMENT DP ORDER PUBLIC SERVICE ' + @branch_name + ' to ' + @public_service_name

		if @order_status <> 'HOLD'
		begin
			set @msg = 'Data already proceed.'
			raiserror(@msg ,16,-1)
		end

		if not exists (select 1 from dbo.order_detail where order_code = @p_code)
		begin
			set @msg = 'Please input Data Detail.'
			raiserror(@msg ,16,-1)
		end

		if @order_amount > 0
		begin
			select @tax_file_type         = tax_file_type
				   ,@tax_file_no          = tax_file_no
				   ,@tax_file_name		  = tax_file_name
				   ,@public_service_name  = public_service_name
			from dbo.master_public_service
			where code = @public_service_code

			select @branch_code		= value
					,@branch_name	= description
			from dbo.sys_global_param
			where code = 'HO'

			set @order_remarks = 'Payment DP Order Public Service for : ' + @p_code + ', branch : ' + @branch_name + '. Payment to : ' + @public_service_name + ' . ' +  @order_main_remarks
			EXEC dbo.xsp_payment_request_insert @p_code							= @code         output          
												,@p_branch_code					= @branch_code            
												,@p_branch_name					= @branch_name             
												,@p_payment_branch_code			= @branch_code             
												,@p_payment_branch_name			= @branch_name           
												,@p_payment_source				= 'DP ORDER PUBLIC SERVICE'
												,@p_payment_request_date		= @order_date
												,@p_payment_source_no			= @p_code                 
												,@p_payment_status				= 'HOLD'                  
												,@p_payment_currency_code		= @currency              
												,@p_payment_amount				= @order_amount          
												,@p_payment_to					= @public_service_name                      
												,@p_payment_remarks				= @order_remarks          
												,@p_to_bank_name				= @bank_name                
												,@p_to_bank_account_name		= @bank_acc_name           
												,@p_to_bank_account_no			= @bank_acc_no             
												,@p_payment_transaction_code	= ''         
												,@p_tax_type					= @tax_file_type          
												,@p_tax_file_no					= @tax_file_no             
												,@p_tax_payer_reff_code			= @public_service_code      
												,@p_tax_file_name				= @tax_file_name          
												,@p_cre_date					= @p_cre_date     
												,@p_cre_by						= @p_cre_by          
												,@p_cre_ip_address				= @p_cre_ip_address
												,@p_mod_date					= @p_mod_date  
												,@p_mod_by						= @p_mod_by      
												,@p_mod_ip_address				= @p_mod_ip_address       
			
			declare curr_payment CURSOR FAST_FORWARD READ_ONLY for
            select	mt.sp_name
					,mtp.debet_or_credit
					,mtp.gl_link_code
					,mt.transaction_name
					,mtp.is_taxable
					,od.id
					,rm.fa_code
			from	dbo.master_transaction_parameter  mtp
					left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
					left join dbo.master_transaction  mt on (mt.code   = mtp.transaction_code)
					inner join dbo.order_detail od on (od.order_code = @p_code)
					INNER JOIN dbo.REGISTER_MAIN rm ON (od.REGISTER_CODE = rm.CODE)
			where	mtp.process_code = 'JRPBS' ;
			
			OPEN curr_payment
			
			FETCH NEXT FROM curr_payment 
			into @sp_name
				 ,@debet_or_credit
				 ,@gl_link_code
				 ,@transaction_name
				 ,@is_taxable
				 ,@id_detail
				 ,@fa_code
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
					-- nilainya exec dari MASTER_TRANSACTION.sp_name
					exec @return_value = @sp_name @id_detail ; -- sp ini mereturn value angka 
					
					if (@debet_or_credit ='DEBIT')
						begin
							set @orig_amount_db = @return_value
						end
					else
					begin
							set @orig_amount_db = @return_value * -1
					end

					set @remarks = @transaction_name + ', ' + @public_service_name + ': ' +format (@orig_amount_db, '#,###.00', 'DE-de')

					SET @no_kontrak = ISNULL(@agreement_external_no, @fa_code)
					if @return_value <> 0
					begin
						exec dbo.xsp_payment_request_detail_insert @p_id						= 0
															   ,@p_payment_request_code			= @code
															   ,@p_branch_code					= @branch_code
															   ,@p_branch_name					= @branch_name
															   ,@p_gl_link_code					= @gl_link_code
															   ,@p_agreement_no					= @no_kontrak--@agreement_external_no
															   ,@p_facility_code				= ''
															   ,@p_facility_name				= ''
															   ,@p_purpose_loan_code			= ''
															   ,@p_purpose_loan_name			= ''
															   ,@p_purpose_loan_detail_code		= ''
															   ,@p_purpose_loan_detail_name		= ''
															   ,@p_orig_currency_code			= 'IDR'
															   ,@p_exch_rate					= 0
															   ,@p_orig_amount					= @orig_amount_db
															   ,@p_division_code				= ''
															   ,@p_division_name				= ''
															   ,@p_department_code				= ''
															   ,@p_department_name				= ''
															   ,@p_remarks						= @remarks
															   ,@p_is_taxable					= '0'
															   ,@p_tax_amount					= 0
															   ,@p_tax_pct						= 0
															   ,@p_cre_date						= @p_mod_date	  
															   ,@p_cre_by						= @p_mod_by		
															   ,@p_cre_ip_address				= @p_mod_ip_address
															   ,@p_mod_date						= @p_mod_date	  
															   ,@p_mod_by						= @p_mod_by		
															   ,@p_mod_ip_address				= @p_mod_ip_address
					end

					fetch next from curr_payment 
					into @sp_name
						,@debet_or_credit
						,@gl_link_code
						,@transaction_name
						,@is_taxable
						,@id_detail
						,@fa_code

			end
			
			close curr_payment
			deallocate curr_payment	
				
				select @amount  = isnull(sum(iipr.payment_amount),0)
				from   dbo.payment_request iipr
				where code = @code

				select @orig_amount_db = isnull(sum(orig_amount),0) 
				from  dbo.payment_request_detail
				where payment_request_code = @code

				--set @amount = @amount + @orig_amount_db
				--+ validasi : total detail =  payment_amount yang di header
				if (@amount <> @orig_amount_db)
				begin
					set @msg = 'Payment Amount does not balance';
			 		raiserror(@msg, 16, -1) ;
				end										
		
				--exec dbo.xsp_efam_interface_payment_request_insert @p_id						 = 0
			--												   ,@p_code						 = @interface_code output -- nvarchar(50)
			--												   ,@p_company_code				 = 'DSF'
			--												   ,@p_branch_code				 = @branch_code
			--												   ,@p_branch_name				 = @branch_name
			--												   ,@p_payment_branch_code		 = @branch_code
			--												   ,@p_payment_branch_name		 = @branch_name
			--												   ,@p_payment_source			 = 'DP ORDER PUBLIC SERVICE'
			--												   ,@p_payment_request_date		 = @p_cre_date
			--												   ,@p_payment_source_no		 = @p_code
			--												   ,@p_payment_status			 = 'HOLD'
			--												   ,@p_payment_currency_code	 = @currency
			--												   ,@p_payment_amount			 = @order_amount
			--												   ,@p_payment_remarks			 = @remarks
			--												   ,@p_to_bank_account_name		 = @bank_acc_name
			--												   ,@p_to_bank_name				 = @bank_name
			--												   ,@p_to_bank_account_no		 = @bank_acc_no
			--												   ,@p_tax_type					 = @tax_file_type
			--												   ,@p_tax_file_no				 = @tax_file_no
			--												   ,@p_tax_payer_reff_code		 = @public_service_code
			--												   ,@p_tax_file_name			 = @tax_file_name
			--												   ,@p_process_date				 = null
			--												   ,@p_process_reff_no			 = null
			--												   ,@p_process_reff_name		 = null
			--												   ,@p_settle_date				 = null
			--												   ,@p_job_status				 = 'HOLD'
			--												   ,@p_failed_remarks			 = ''
			--												   ,@p_cre_date					 = @p_cre_date
			--												   ,@p_cre_by					 = @p_cre_by
			--												   ,@p_cre_ip_address			 = @p_cre_ip_address
			--												   ,@p_mod_date					 = @p_mod_date
			--												   ,@p_mod_by					 = @p_mod_by
			--												   ,@p_mod_ip_address			 = @p_mod_ip_address
			
			---- loop tabel dbo.master_transaction_parameter mtp  mtp.process_code ='JURams01'
			---- join ke MASTER_TRANSACTION
			--declare cur_parameter cursor local fast_forward read_only for
			--select  mt.sp_name
			--		,mtp.debet_or_credit
			--		,mtp.gl_link_code
			--		,mt.transaction_name
			--		,mtp.is_taxable
				
			--from	dbo.master_transaction_parameter mtp 
			--		left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
			--		left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
			--where	mtp.process_code = 'JRPBS'


			--		--mtp.process_code = 'JURPBS05'	---pakai kode 02 or 05?
			
			--open cur_parameter
			--fetch cur_parameter 
			--into @sp_name
			--	 ,@debet_or_credit
			--	 ,@gl_link_code
			--	 ,@transaction_name
			--	 ,@is_taxable
				

			--while @@fetch_status = 0
			--begin

			--	--select @register_code = register_code from dbo.order_detail where order_code = @p_code

			--	-- nilainya exec dari MASTER_TRANSACTION.sp_name
			--	exec @return_value = @sp_name @p_code; -- sp ini mereturn value angka 
					
			--	if (@debet_or_credit ='DEBIT')
			--	begin
			--		set @orig_amount_db = @return_value
			--	end
			--	else
			--	begin
			--		set @orig_amount_db = @return_value * -1
			--	end
					
					
			--		exec dbo.xsp_efam_interface_payment_request_detail_insert @p_id									= 0
			--																  ,@p_payment_request_code				= @interface_code
			--																  ,@p_company_code						= 'DSF'
			--																  ,@p_branch_code						= @branch_code
			--																  ,@p_branch_name						= @branch_name
			--																  ,@p_gl_link_code						= @gl_link_code
			--																  ,@p_fa_code							= @fa_code
			--																  ,@p_facility_code						= ''
			--																  ,@p_facility_name						= ''
			--																  ,@p_purpose_loan_code					= ''
			--																  ,@p_purpose_loan_name					= ''
			--																  ,@p_purpose_loan_detail_code			= ''
			--																  ,@p_purpose_loan_detail_name			= ''
			--																  ,@p_orig_currency_code				= @currency
			--																  ,@p_orig_amount						= @orig_amount_db
			--																  ,@p_division_code						= ''
			--																  ,@p_division_name						= ''
			--																  ,@p_department_code					= ''
			--																  ,@p_department_name					= ''
			--																  ,@p_remarks							= @remarks
			--																  ,@p_is_taxable						= @is_taxable
			--																  ,@p_cre_date							= @p_cre_date		 
			--																  ,@p_cre_by							= @p_cre_by	
			--																  ,@p_cre_ip_address					= @p_cre_ip_address
			--																  ,@p_mod_date							= @p_mod_date		 
			--																  ,@p_mod_by							= @p_mod_by	 
			--																  ,@p_mod_ip_address					= @p_mod_ip_address	 
					

						

			--	fetch cur_parameter 
			--	into @sp_name
			--			,@debet_or_credit
			--			,@gl_link_code
			--			,@transaction_name
			--			,@is_taxable

			--end
			--close cur_parameter
			--deallocate cur_parameter		

				update	dbo.order_main
				set		order_status	= 'ON PROCESS'
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address
				where	code = @p_code

				update	dbo.register_main
				set		order_status	= 'ON PROCESS'
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address
				where	code in (select register_code from dbo.order_detail where order_code = @p_code)
			end
		else
		begin
		    update	dbo.order_main
			set		order_status	= 'PAID'
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address	= @p_mod_ip_address
			where	code = @p_code

			update	dbo.register_main
			set		order_status					= 'PAID'
					,register_status				= 'PENDING'
					,payment_status					= 'HOLD'
					,order_code						= @p_code		
					,dp_to_public_service_date		= getdate()
					,dp_to_public_service_amount	= 0
					,dp_to_public_service_voucher	= '-'
					--,dp_to_public_service_amount	= @order_amount
					--,dp_to_public_service_date		= @system_date
					--,dp_to_public_service_voucher	= '-'
					,mod_date						= @p_mod_date
					,mod_by							= @p_mod_by
					,mod_ip_address					= @p_mod_ip_address
			where	code in (select register_code from dbo.order_detail where order_code = @p_code)
		end

		--validasi payment
		if	(isnull(@interface_code,'') <> '')
		begin
			select @header_amount = payment_amount
			from	dbo.efam_interface_payment_request
			where	code = @interface_code

			select @detail_amount = sum(orig_amount)
			from	dbo.efam_interface_payment_request_detail
			where	payment_request_code = @interface_code

			--+ validasi : total detail =  payment_amount yang di header
			if (@header_amount <> @detail_amount)			
			begin
				set @msg = 'Payment does not balance';
    			raiserror(@msg, 16, -1) ;
			end
		end

		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code_document output
													,@p_branch_code			 = @branch_code
													,@p_sys_document_code	 = ''
													,@p_custom_prefix		 = 'IDR'
													,@p_year				 = @year
													,@p_month				 = @month
													,@p_table_name			 = 'AMS_INTERFACE_DOCUMENT_REQUEST'
													,@p_run_number_length	 = 5
													,@p_delimiter			= '.'
													,@p_run_number_only		 = '0' ;

		--insert into document request
		insert into dbo.ams_interface_document_request
		(
			code
			,request_branch_code
			,request_branch_name
			,request_type
			,request_location
			,request_from
			,request_to
			,request_to_branch_code
			,request_to_branch_name
			,request_to_agreement_no
			,request_to_client_name
			,request_from_dept_code
			,request_from_dept_name
			,request_to_dept_code
			,request_to_dept_name
			,request_to_thirdparty_type
			,agreement_no
			,collateral_no
			,asset_no
			,request_by
			,request_status
			,request_date
			,remarks
			,document_code
			,process_date
			,process_reff_no
			,process_reff_name
			,job_status
			,failed_remark
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@code_document
			,@branch_code
			,@branch_name
			,'BORROW'
			,'THIRD PARTY'
			,'BRANCH'
			,LEFT(@public_service_name,50)
			,null 
			,null 
			,null 
			,null 
			,null 
			,'' 
			,null 
			,''
			,null
			,null
			,null
			,@fa_code
			,@p_mod_by
			,'HOLD'
			,@p_mod_date
			,'Document Request Form Biro Jasa'
			,null
			,null
			,null
			,null
			,'HOLD'
			,''
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)

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

end


