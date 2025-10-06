CREATE PROCEDURE [dbo].[xsp_agreement_obligation_payment_by_interface_job_insert]
(
	@p_id bigint
)
as
begin
	declare @msg				   nvarchar(max)
			,@agreement_no		   nvarchar(50)
			,@installment_no	   int
			,@payment_date		   datetime
			,@value_date		   datetime
			,@currency_code		   nvarchar(3)
 			,@branch_code		   nvarchar(50)
 			,@branch_name		   nvarchar(50)
			,@payment_source_type  nvarchar(50)
			,@payment_source_no	   nvarchar(50)
			,@obligation_code	   nvarchar(50)
			,@temp_payment_amount  decimal(18, 2)
			,@payment_amount	   decimal(18, 2)
			,@temps_payment_amount decimal(18, 2) = 0
			,@installment_amount   decimal(18, 2)
			,@is_waive			   nvarchar(1)
			,@deposit_code		   nvarchar(50)
			,@asset_no			   nvarchar(50)
			,@invoice_no		   nvarchar(50)
			--
			,@cre_date			   datetime
			,@cre_by			   nvarchar(15)
			,@cre_ip_address	   nvarchar(15)
			,@mod_date			   datetime
			,@mod_by			   nvarchar(15)
			,@mod_ip_address	   nvarchar(15)
			--cursor
			,@id_interface		   bigint 
			,@id_ovd				bigint
            ,@sum_payment_amount	decimal(18,2)

	begin try
	
		select	@agreement_no					 = ip.agreement_no
				,@payment_date					 = ip.payment_date
				,@value_date					 = ip.value_date
				,@payment_source_type			 = ip.payment_source_type
				,@payment_source_no				 = ip.payment_source_no
				,@payment_amount				 = ip.payment_amount
				,@is_waive						 = ip.is_waive
				,@branch_code					 = am.branch_code
 			    ,@branch_name					 = am.branch_name
 			    ,@currency_code					 = am.currency_code
				,@installment_no				 = ip.installment_no -- (+) Ari 2023-10-11 ket : get installment no yg dibayarkan
				--
				,@cre_date						 = ip.cre_date
				,@cre_by						 = ip.cre_by
				,@cre_ip_address				 = ip.cre_ip_address
				,@mod_date						 = ip.mod_date
				,@mod_by						 = ip.mod_by
				,@mod_ip_address				 = ip.mod_ip_address
		from	dbo.opl_interface_agreement_obligation_payment ip
				inner join dbo.agreement_main am on (am.agreement_no = ip.agreement_no)  
		where	ip.id = @p_id ;
		
		set @temp_payment_amount = @payment_amount ;
		
		-- jika @temp_payment_amount bernilai positive = pembayaran
		if(@temp_payment_amount > 0)
		begin
			while (@temp_payment_amount > 0)
			begin

				if exists (select	1
 									from	dbo.agreement_obligation aa
 											outer apply		(	
 																select	isnull(sum(isnull(payment_amount, 0)), 0) 'payment_amount'
 																from	dbo.agreement_obligation_payment aap
 																where	aap.obligation_code = aa.code
 															) parsial
 									where	aa.agreement_no = @agreement_no 
 											and aa.obligation_amount > isnull(parsial.payment_amount,0))
 				begin
 			    
 					--select	top 1 
 					--		@installment_amount	= aa.obligation_amount - parsial.payment_amount 
						--	,@asset_no = aa.asset_no
						--	,@invoice_no = aa.invoice_no
						--	,@obligation_code = aa.code
						--	,@installment_no = aa.installment_no
 					--from	dbo.agreement_obligation aa
 					--		outer apply		(	
 					--							select	isnull(sum(aap.payment_amount),0) 'payment_amount'
 					--							from	dbo.agreement_obligation_payment aap
 					--							where	aap.obligation_code = aa.code
 					--						) parsial
 					--where	aa.agreement_no = @agreement_no 
 					--and		aa.obligation_amount > isnull(parsial.payment_amount,0)
 					--and		aa.installment_no > 0
 					--order by aa.installment_no asc
					
					-- Louis Kamis, 21 Maret 2024 16.17.22 -- get obligation type untuk late return asset penalty
					if exists
					(
						select	1
						from	dbo.opl_interface_agreement_obligation_payment
						where	id					= @p_id
								and obligation_type = 'LRAP'
					)
					begin 
						select	top 1
								@installment_amount = aa.obligation_amount - parsial.payment_amount
								,@asset_no = aa.asset_no
								,@invoice_no = aa.invoice_no
								,@obligation_code = aa.code
						from	dbo.agreement_obligation aa
								outer apply
						(
							select	isnull(sum(aap.payment_amount), 0) 'payment_amount'
							from	dbo.agreement_obligation_payment aap
							where	aap.obligation_code = aa.code
						) parsial
						where	aa.agreement_no			 = @agreement_no
								and aa.obligation_amount > isnull(parsial.payment_amount, 0)
								and aa.obligation_type	 = 'LRAP' ;
					end ;
					else
					begin
						-- (+) Ari 2023-10-11 ket : get pembayaran berdasarkan ovd installment no yg dibayarkan
						select	top 1
								@installment_amount = aa.obligation_amount - parsial.payment_amount
								,@asset_no = aa.asset_no
								,@invoice_no = aa.invoice_no
								,@obligation_code = aa.code
						from	dbo.agreement_obligation aa
								outer apply
						(
							select	isnull(sum(aap.payment_amount), 0) 'payment_amount'
							from	dbo.agreement_obligation_payment aap
							where	aap.obligation_code = aa.code
						) parsial
						where	aa.agreement_no			 = @agreement_no
								and aa.obligation_amount > isnull(parsial.payment_amount, 0)
								and aa.installment_no	 > 0
								and aa.installment_no	 = @installment_no ; -- (+) Ari 2023-10-11 ket : kondisi berdasarkan ovd installment no yg dibayarkan
					-- (+) Ari 2023-10-11
					end ;
               
 					if (@temp_payment_amount > @installment_amount)
 					begin
 						set @payment_amount = @installment_amount ;
 						set @temp_payment_amount = @temp_payment_amount - @installment_amount
 					end
 					else
 					begin
 						set @payment_amount = @temp_payment_amount ;
 						set @temp_payment_amount = 0
 					end
				 
					exec dbo.xsp_agreement_obligation_payment_insert @p_id						= @id_ovd output
																	 ,@p_obligation_code		= @obligation_code
																	 ,@p_agreement_no			= @agreement_no
																	 ,@p_asset_no				= @asset_no
																	 ,@p_invoice_no				= @invoice_no
																	 ,@p_installment_no			= @installment_no
																	 ,@p_payment_date			= @payment_date
																	 ,@p_value_date				= @value_date
																	 ,@p_payment_source_type	= @payment_source_type
																	 ,@p_payment_source_no		= @payment_source_no
																	 ,@p_payment_amount			= @payment_amount
																	 ,@p_is_waive				= @is_waive
																	 ,@p_cre_date			    = @cre_date
																	 ,@p_cre_by				    = @cre_by
																	 ,@p_cre_ip_address		    = @cre_ip_address
																	 ,@p_mod_date			    = @mod_date
																	 ,@p_mod_by				    = @mod_by
																	 ,@p_mod_ip_address		    = @mod_ip_address
 			
 				end
 				else 
 				begin
					if exists
					(
						select	1
						from	dbo.agreement_deposit_main
						where	agreement_no = @agreement_no
					)
					begin
						update	dbo.agreement_deposit_main
						set		deposit_amount = deposit_amount + @temp_payment_amount
						where	agreement_no = @agreement_no ;
					end ;
 					else
 					begin 
 						exec dbo.xsp_agreement_deposit_main_insert @p_code						= @deposit_code output
 																   ,@p_branch_code				= @branch_code
 																   ,@p_branch_name				= @branch_name
 																   ,@p_agreement_no				= @agreement_no
 																   ,@p_deposit_type				= N'INSTALLMENT'
 																   ,@p_deposit_currency_code	= @currency_code
 																   ,@p_deposit_amount			= @temp_payment_amount
 																   ,@p_cre_date					= @cre_date		
 																   ,@p_cre_by					= @cre_by		
 																   ,@p_cre_ip_address			= @cre_ip_address
 																   ,@p_mod_date					= @mod_date		
 																   ,@p_mod_by					= @mod_by		
 																   ,@p_mod_ip_address			= @mod_ip_address
 					
 					end
 					set @temp_payment_amount = 0;
 				end
			end 
		end
		else if (@temp_payment_amount < 0) -- jika negatif = reversal
        begin
				-- Louis Kamis, 21 Maret 2024 16.17.22 -- get obligation type untuk late return asset penalty
				if exists
				(
					select	1
					from	dbo.opl_interface_agreement_obligation_payment
					where	id					= @p_id
							and obligation_type <> 'LRAP'
				)
				begin 
					insert into dbo.agreement_obligation_payment
					(
						obligation_code
						,agreement_no
						,asset_no
						,invoice_no
						,installment_no
						,payment_date
						,value_date
						,payment_source_type
						,payment_source_no
						,payment_amount
						,is_waive
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
					)
					select	obligation_code
							,agreement_no
							,asset_no
							,invoice_no
							,installment_no
							,@payment_date
							,@value_date
							,@payment_source_type
							,payment_source_no
							,payment_amount * -1
							,is_waive
							,@cre_date
							,@cre_by
							,@cre_ip_address
							,@mod_date
							,@mod_by
							,@mod_ip_address
					from	dbo.agreement_obligation_payment a
					where	payment_source_no  = @payment_source_no
							and payment_amount > 0
							and installment_no = @installment_no ;

					select	@sum_payment_amount = sum(payment_amount)
					from	dbo.agreement_obligation_payment
					where	payment_source_no = @payment_source_no
					and		payment_source_type = @payment_source_type
					and		payment_amount < 0
					and		installment_no = @installment_no
				end
				else if exists
				(
					select	1
					from	dbo.opl_interface_agreement_obligation_payment
					where	id					= @p_id
							and obligation_type = 'LRAP'
				)
				begin
					insert into dbo.agreement_obligation_payment
					(
						obligation_code
						,agreement_no
						,asset_no
						,invoice_no
						,installment_no
						,payment_date
						,value_date
						,payment_source_type
						,payment_source_no
						,payment_amount
						,is_waive
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
					)
					select	obligation_code
							,agreement_no
							,asset_no
							,invoice_no
							,installment_no
							,@payment_date
							,@value_date
							,@payment_source_type
							,payment_source_no
							,payment_amount * -1
							,is_waive
							,@cre_date
							,@cre_by
							,@cre_ip_address
							,@mod_date
							,@mod_by
							,@mod_ip_address
					from	dbo.agreement_obligation_payment a
					where	payment_source_no  = @payment_source_no
							and payment_amount > 0 

					select	@sum_payment_amount = sum(payment_amount)
					from	dbo.agreement_obligation_payment
					where	payment_source_no = @payment_source_no
					and		payment_source_type = @payment_source_type
					and		payment_amount < 0 
				end

				if(@payment_amount <> @sum_payment_amount)
				begin
					set @temp_payment_amount = @payment_amount - @sum_payment_amount

						if exists
						(
							select	1
							from	dbo.agreement_deposit_main
							where	agreement_no = @agreement_no
						)
						begin
							update	dbo.agreement_deposit_main
							set		deposit_amount = deposit_amount + @temp_payment_amount
							where	agreement_no = @agreement_no ;
						end ;
 						else
 						begin 
 							exec dbo.xsp_agreement_deposit_main_insert @p_code						= @deposit_code output
 																	   ,@p_branch_code				= @branch_code
 																	   ,@p_branch_name				= @branch_name
 																	   ,@p_agreement_no				= @agreement_no
 																	   ,@p_deposit_type				='INSTALLMENT'
 																	   ,@p_deposit_currency_code	= @currency_code
 																	   ,@p_deposit_amount			= @temp_payment_amount
 																	   ,@p_cre_date					= @cre_date		
 																	   ,@p_cre_by					= @cre_by		
 																	   ,@p_cre_ip_address			= @cre_ip_address
 																	   ,@p_mod_date					= @mod_date		
 																	   ,@p_mod_by					= @mod_by		
 																	   ,@p_mod_ip_address			= @mod_ip_address
 					
 						end
 					end
 			
			set @temp_payment_amount = 0;
				
        end

		-- Louis Senin, 05 Februari 2024 11.21.04 -- penambahan fungsing untuk hitung ulang agreement information
		begin
			exec dbo.xsp_agreement_information_update @p_agreement_no		= @agreement_no
														,@p_mod_date		= @mod_date
														,@p_mod_by			= @mod_by
														,@p_mod_ip_address	= @mod_ip_address ;
		end
		-- terminate agreement
		--exec dbo.xsp_agreement_for_terminate @p_agreement_no		= @agreement_no
		--                                     ,@p_termination_date	= @payment_date
		--                                     ,@p_termination_status	= @payment_source_type
		--                                     ,@p_mod_date			= @mod_date		
		--                                     ,@p_mod_by				= @mod_by			
		--                                     ,@p_mod_ip_address		= @mod_ip_address
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

