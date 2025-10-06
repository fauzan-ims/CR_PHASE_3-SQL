-- Louis Senin, 13 Februari 2023 20.09.07 -- 
CREATE PROCEDURE [dbo].[xsp_ams_interface_payment_request_paid] 
(
	@p_code					nvarchar(50) 
	,@p_process_reff_no		nvarchar(50) 
	,@p_process_date		datetime
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
	declare @msg					nvarchar(max)
			,@payment_source		nvarchar(250)
			,@payment_source_no		nvarchar(50)
			,@code_payment_trans	nvarchar(50)
			
	begin try
			declare curr_payment_ams cursor fast_forward read_only for
			select pr.payment_source_no
					,pr.payment_source
			from dbo.efam_interface_payment_request eipr
			inner join dbo.payment_transaction pt on (pt.code = eipr.payment_source_no)
			inner join dbo.payment_transaction_detail ptd on (ptd.payment_transaction_code = pt.code)
			inner join dbo.payment_request pr on (pr.code = ptd.payment_request_code)
			where eipr.code = @p_code
			
			open curr_payment_ams
			
			fetch next from curr_payment_ams 
			into @payment_source_no
				,@payment_source
			
			while @@fetch_status = 0
			begin
			    if(@payment_source = 'DP ORDER PUBLIC SERVICE')
				begin
					exec dbo.xsp_order_main_paid @p_code				= @payment_source_no
													,@p_voucher			= @p_process_reff_no
													,@p_date			= @p_process_date
													,@p_mod_date		= @p_mod_date
													,@p_mod_by			= @p_mod_by
													,@p_mod_ip_address	= @p_mod_ip_address
				end		
				else if(@payment_source = 'REALIZATION FOR PUBLIC SERVICE')
				begin
					exec dbo.xsp_register_main_realization_public_service_paid @p_code									= @payment_source_no
																			   ,@p_public_service_settlement_date		= @p_process_date
																			   ,@p_public_service_settlement_voucher	= @p_process_reff_no
																			   ,@p_mod_date								= @p_mod_date
																			   ,@p_mod_by								= @p_mod_by
																			   ,@p_mod_ip_address						= @p_mod_ip_address
					
				end
				else if (@payment_source = 'POLICY')
				begin
					exec dbo.xsp_insurance_policy_main_paid @p_code				= @payment_source_no
															,@p_cre_date		= @p_cre_date		
															,@p_cre_by			= @p_cre_by			
															,@p_cre_ip_address	= @p_cre_ip_address	
															,@p_mod_date		= @p_mod_date		
															,@p_mod_by			= @p_mod_by			
															,@p_mod_ip_address	= @p_mod_ip_address	
									
				end
				else if (@payment_source = 'ENDORSE')
				begin 
					exec dbo.xsp_endorsement_main_paid @p_code				= @payment_source_no
														,@p_mod_date		= @p_mod_date		
														,@p_mod_by			= @p_mod_by			
														,@p_mod_ip_address	= @p_mod_ip_address ;      
					
				end
				else if (@payment_source  = 'WORK ORDER')
				begin
					exec dbo.xsp_work_order_paid @p_code			= @payment_source_no
												 ,@p_mod_date		= @p_mod_date
												 ,@p_mod_by			= @p_mod_by
												 ,@p_mod_ip_address = @p_mod_ip_address
					
				end

				if (@payment_source = 'INSURANCE RENEWAL')
				begin 
					update	dbo.insurance_payment_schedule_renewal
					set		payment_renual_status	= 'PAID'
							,@p_mod_date			= @p_mod_date
							,@p_mod_by				= @p_mod_by
							,@p_mod_ip_address		= @p_mod_ip_address
					where	code					= @payment_source_no ;
					
				end
			
			    fetch next from curr_payment_ams 
				into @payment_source_no
				,@payment_source
			end
			
			close curr_payment_ams
			deallocate curr_payment_ams

			select @code_payment_trans	= payment_source_no
			from	dbo.efam_interface_payment_request
			where	code			= @p_code

			update	dbo.payment_transaction
			set		payment_status			= 'PAID'
					,@p_mod_date			= @p_mod_date
					,@p_mod_by				= @p_mod_by
					,@p_mod_ip_address		= @p_mod_ip_address
			where	code		= @code_payment_trans ;
            	
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




