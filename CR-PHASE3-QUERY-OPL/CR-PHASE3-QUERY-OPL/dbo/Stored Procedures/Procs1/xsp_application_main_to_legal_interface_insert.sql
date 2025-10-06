CREATE PROCEDURE dbo.xsp_application_main_to_legal_interface_insert
(
	@p_application_no  nvarchar(50)
	,@p_fee_code	   nvarchar(50)
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
	declare @msg										nvarchar(max) 
			,@branch_code								nvarchar(50)
			,@branch_name								nvarchar(250)
			,@request_status							nvarchar(10)  = 'HOLD'
			,@request_date								datetime
			,@custody_branch_code						nvarchar(50)
			,@custody_branch_name						nvarchar(250)
			,@application_no							nvarchar(50)
			,@collateral_no								nvarchar(50)
			,@service_code								nvarchar(50)
			,@request_payment_amount					decimal(18, 2)
			,@request_payment_date						datetime
			,@request_payment_voucher					nvarchar(50)
			,@legal_type								nvarchar(20)
			,@slik_status_agunan_code					nvarchar(50)
			,@slik_status_agunan_ojk_code				nvarchar(50)
			,@slik_status_agunan_name					nvarchar(250)
			,@slik_jns_agunan_code						nvarchar(50)
			,@slik_jns_agunan_ojk_code					nvarchar(50)
			,@slik_jns_agunan_name						nvarchar(250)
			,@slik_sts_paripasu_code					nvarchar(50)
			,@slik_prsnts_paripasu						nvarchar(10)
			,@slik_sts_asuransi_code					nvarchar(50)
			,@slik_sts_asuransi_ojk_code				nvarchar(50)
			,@slik_sts_asuransi_name					nvarchar(250)
			,@slik_prngkt_agunan_code					nvarchar(50)
			,@slik_lmbg_pmrngkt_code					nvarchar(50)
			,@slik_lmbg_pmrngkt_ojk_code				nvarchar(50)
			,@slik_lmbg_pmrngkt_name					nvarchar(250)
			,@slik_jns_pngktn_code						nvarchar(50)
			,@slik_jns_pngktn_ojk_code					nvarchar(50)
			,@slik_jns_pngktn_name						nvarchar(250)
			,@slik_tgl_pngktn							datetime
			,@slik_nilai_anggunan_penilaian_independent decimal(18, 2)
			,@slik_nama_penilaian_independent			nvarchar(250)
			,@slik_tanggal_penilaian_independent		datetime 
			,@agreement_no								nvarchar(50)
			,@agreement_external_no						nvarchar(50)
			,@installment_amount						decimal(18, 2)	
			,@client_name								nvarchar(250)						
			--cursor pdc
			,@application_code							nvarchar(50)
			,@pdc_no									nvarchar(50)
			,@pdc_date									datetime
			,@pdc_bank_code								nvarchar(50)
			,@pdc_bank_name								nvarchar(250)
			,@pdc_allocation_type						nvarchar(50)
			,@pdc_currency_code							nvarchar(3)
			,@pdc_value_amount							decimal(18, 2)
			,@pdc_inkaso_fee_amount						decimal(18, 2)
			,@pdc_clearing_fee_amount					decimal(18, 2)
			,@pdc_amount								decimal(18, 2)
			,@pdc_remarks								nvarchar(4000)
			,@eff_rate									decimal(9, 6)
			,@currency_code								nvarchar(3)
			,@collateral_name							nvarchar(250)
			,@client_no								    nvarchar(50)
			,@request_type								nvarchar(50)
			,@legal_amount								decimal(18, 2) ;

	begin try
		-- interface legal request
		begin
			select	@branch_code				= apm.branch_code
					,@branch_name				= apm.branch_name
					,@request_date				= @p_cre_date
					,@custody_branch_code		= apm.branch_code
					,@custody_branch_name		= apm.branch_name
					,@agreement_no				= apm.agreement_no
					,@agreement_external_no		= apm.agreement_external_no
					,@client_no					= cm.client_no
					,@client_name				= cm.client_name 
					,@currency_code				= apm.currency_code
			from	dbo.application_main apm
					inner join application_amortization amrt on (amrt.application_no = apm.application_no)
					inner join dbo.client_main cm on (cm.code = apm.client_code)
			where	apm.application_no			= @p_application_no ;

			declare legalRequest cursor fast_forward read_only for
			select	am.agreement_no
					,null
					,null
					,pn.notary_service_code
					,pn.total_notary_amount
					,'NTRY'
					,'AGREEMENT'
					,0--am.financing_amount
			from	dbo.application_main am
					inner join dbo.application_notary pn on (pn.application_no = am.application_no)
			where	am.application_no = @p_application_no 
					and @p_fee_code   = 'NTRY' 

			open legalRequest ;

			fetch next from legalRequest
			into @application_no
				 ,@collateral_no
				 ,@collateral_name
				 ,@service_code
				 ,@request_payment_amount
				 ,@legal_type 
				 ,@request_type 
				 ,@legal_amount ;

			while @@fetch_status = 0
			begin
				select	@request_payment_date					= process_date
						,@request_payment_voucher				= process_reff_no
				from	los_interface_cashier_received_request
				where	doc_reff_code							= @p_application_no
						and doc_reff_name						= 'APPLICATION FEE'
						and doc_reff_fee_code					= @legal_type
						and request_status						= 'PAID' ;
						 
				exec dbo.xsp_los_interface_legal_request_insert @p_code						= N''
																,@p_branch_code				= @branch_code
																,@p_branch_name				= @branch_name
																,@p_request_status			= @request_status
																,@p_request_date			= @request_date
																,@p_request_type			= @request_type
																,@p_custody_branch_code		= @custody_branch_code
																,@p_custody_branch_name		= @custody_branch_name
																,@p_currency_code			= @currency_code
																,@p_plafond_code			= null
																,@p_agreement_no			= @application_no
																,@p_collateral_no			= @collateral_no
																,@p_collateral_name			= @collateral_name
																,@p_plafond_no				= null
																,@p_plafond_colalteral_no	= null
																,@p_plafond_colalteral_name = null
																,@p_client_no				= @client_no
																,@p_client_name				= @client_name
																,@p_legal_amount			= @legal_amount
																,@p_service_code			= @service_code
																,@p_handover_code			= null
																,@p_request_source			= 'IFINOPL'
																,@p_request_payment_date	= @request_payment_date
																,@p_request_payment_amount	= @request_payment_amount
																,@p_request_payment_voucher = @request_payment_voucher 
																,@p_manual_upload_status	= null
																,@p_manual_upload_remarks	= null
																,@p_cre_date				= @p_cre_date
																,@p_cre_by					= @p_cre_by
																,@p_cre_ip_address			= @p_cre_ip_address
																,@p_mod_date				= @p_mod_date
																,@p_mod_by					= @p_mod_by
																,@p_mod_ip_address			= @p_mod_ip_address ;
				
				
				fetch next from legalRequest
				into @application_no
					 ,@collateral_no
					 ,@collateral_name
					 ,@service_code
					 ,@request_payment_amount
					 ,@legal_type
					 ,@request_type  
					 ,@legal_amount ;
			end ;

			close legalRequest ;
			deallocate legalRequest ;
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




