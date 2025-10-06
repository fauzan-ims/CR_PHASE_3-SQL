/*
exec xsp_job_interface_in_ifinopl_handover_asset
*/
CREATE PROCEDURE [dbo].[xsp_job_interface_in_ifinopl_handover_asset]
as

	declare @msg					   nvarchar(max)
			,@row_to_process		   int
			,@last_id_from_job		   bigint
			,@id_interface			   bigint
			,@application_no		   nvarchar(50)
			,@code_sys_job			   nvarchar(50)
			,@is_active				   nvarchar(1)
			,@last_id				   bigint		 = 0
			,@number_rows			   int			 = 0
			,@reff_code				   nvarchar(50)
			,@code_interface		   nvarchar(50) 
			,@mod_date				   datetime		 = getdate()
			,@mod_by				   nvarchar(15)	 = 'job'
			,@mod_ip_address		   nvarchar(15)	 = '127.0.0.1'
			,@from_id				   bigint		 = 0
			,@handover_code			   nvarchar(50)
			,@handover_bast_date	   datetime
			,@handover_status		   nvarchar(10)
			,@handover_remark		   nvarchar(4000)
			,@current_mod_date		   datetime 
			,@first_payment_type	   nvarchar(3)
			,@agreement_no			   nvarchar(50)
			,@realization_code		   nvarchar(50)
			,@type					   nvarchar(50)
			,@asset_no				   nvarchar(50);

	select	@code_sys_job		= code
			,@row_to_process	= row_to_process
			,@last_id_from_job	= last_id
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_in_ifinopl_handover_asset' -- sesuai dengan nama sp ini

	if (@is_active = '1')
	begin
		--get cashier received request
		declare curr_interface_handover_asset cursor for
		select		id 
					,reff_no
					,code
					,handover_code		
					,handover_bast_date	
					,handover_status	
					,handover_remark	
					,type
					,fa_code
		from		dbo.opl_interface_handover_asset
		where		settle_date is null
					and status in ('POST')
					and job_status in ('HOLD','FAILED')
		order by	id asc offset 0 rows fetch next @row_to_process rows only ;

		open curr_interface_handover_asset
		fetch next from curr_interface_handover_asset 
		into @id_interface 
			 ,@reff_code
			 ,@code_interface
			 ,@handover_code		
			 ,@handover_bast_date
			 ,@handover_status	
			 ,@handover_remark	
			 ,@type
			 ,@asset_no
		
		while @@fetch_status = 0
		begin
			begin try
				begin transaction

					if (@number_rows = 0)
					begin
						set @from_id = @id_interface
					end 
					if(@type = 'DELIVERY')
					begin
						update	dbo.application_asset
						set		purchase_status			= 'AGREEMENT'
								,purchase_gts_status	= 'AGREEMENT'
								,asset_status			= 'RENTED' -- Louis Selasa, 08 Juli 2025 11.42.54 -- 
								,handover_code			= @handover_code
								,bast_date				= @handover_bast_date
								,handover_bast_date		= @handover_bast_date
								,handover_status		= @handover_status
								,handover_remark		= @handover_remark
								--
								,mod_date				= @mod_date	   
								,mod_by					= @mod_by		   
								,mod_ip_address			= @mod_ip_address 
						where	asset_no				= @reff_code ; 

						-- recalculate due date
						exec dbo.xsp_application_amortization_recalculate_due_date @p_asset_no			= @reff_code
																				   ,@p_due_date			= @handover_bast_date
																				   --
																				   ,@p_mod_date			= @mod_date	   
																				   ,@p_mod_by			= @mod_by		   
																				   ,@p_mod_ip_address	= @mod_ip_address 

						select	@application_no = application_no
								,@realization_code = realization_code
						from	application_asset
						where	asset_no = @reff_code ;

						select	@agreement_no = agreement_no
						from	dbo.realization
						where	code = @realization_code ;
		
						-- Louis Kamis, 03 Juli 2025 10.51.53 -- 
						--if not exists
						--(
						--	select	1
						--	from	dbo.application_asset
						--	where	realization_code = @realization_code
						--			and bast_date is null
						--)
						--begin  
				 
						--	select	@agreement_no = agreement_no
						--	from	dbo.realization
						--	where	code = @realization_code ;

						--	--insert to agreement
						--	exec dbo.xsp_realization_to_agreement_insert @p_code			= @realization_code
						--												 ,@p_agreement_no	= @agreement_no
						--												 ,@p_application_no	= @application_no
						--												 --
						--												 ,@p_cre_date		= @mod_date
						--												 ,@p_cre_by			= @mod_by
						--												 ,@p_cre_ip_address = @mod_ip_address
						--												 ,@p_mod_date		= @mod_date
						--												 ,@p_mod_by			= @mod_by
						--												 ,@p_mod_ip_address = @mod_ip_address
						--end
					
						if not exists (	select	1 from dbo.agreement_main am
										where am.agreement_no = @agreement_no)
						begin

								--insert to agreement
								exec dbo.xsp_realization_to_agreement_insert @p_code			= @realization_code
																			 ,@p_agreement_no	= @agreement_no
																			 ,@p_application_no	= @application_no
																			 --
																			 ,@p_cre_date		= @mod_date
																			 ,@p_cre_by			= @mod_by
																			 ,@p_cre_ip_address = @mod_ip_address
																			 ,@p_mod_date		= @mod_date
																			 ,@p_mod_by			= @mod_by
																			 ,@p_mod_ip_address = @mod_ip_address
																			
								update	dbo.agreement_asset
								set		asset_status		= 'IN PROCESS'
										--
										,mod_date		    = @mod_date
										,mod_by			    = @mod_by
										,mod_ip_address	    = @mod_ip_address
								where	agreement_no = @agreement_no
										and handover_bast_date is null ;
						end
						else
						begin
								--select	@agreement_no = aa.agreement_no 
								--from	dbo.agreement_asset aa
								--inner join dbo.agreement_main am on (am.agreement_no = aa.agreement_no)
								--where	asset_no = @reff_code ;

								delete dbo.agreement_asset_amortization
								where	asset_no = @reff_code ;

								update	dbo.agreement_asset
								set		asset_status = 'RENTED'
										,handover_code		 = @handover_code
										,handover_bast_date	 = @handover_bast_date
										,handover_status	 = @handover_status
										,handover_remark	 = @handover_remark
										,maturity_date		 = dateadd(month, periode, @handover_bast_date)
										--
										,mod_date			 = @mod_date
										,mod_by				 = @mod_by
										,mod_ip_address		 = @mod_ip_address
								where	asset_no			 = @reff_code ;
								
								--re-insert agreement_asset_amortization
								insert into dbo.agreement_asset_amortization
								(
									agreement_no
									,billing_no
									,asset_no
									,due_date
									,billing_date
									,billing_amount
									,description
									,invoice_no
									,generate_code
									,hold_billing_status
									,hold_date 
									--
									,cre_date
									,cre_by
									,cre_ip_address
									,mod_date
									,mod_by
									,mod_ip_address
								)
								select	@agreement_no
										,aa.installment_no
										,aa.asset_no
										,aa.due_date
										,aa.billing_date
										,aa.billing_amount
										,aa.description
										,null
										,null
										,''
										,null
										--
										,@mod_date
										,@mod_by
										,@mod_ip_address
										,@mod_date
										,@mod_by
										,@mod_ip_address
								from	dbo.application_amortization aa
								where	aa.asset_no = @reff_code ;
						end

						-- Louis Kamis, 03 Juli 2025 10.51.56 -- 
					end
					else if (@type = 'PICK UP')
					begin 
					

						update	dbo.agreement_asset
						set		return_date		= @handover_bast_date
								--
								,mod_date		= @mod_date
								,mod_by			= @mod_by
								,mod_ip_address = @mod_ip_address
						where	asset_no		= @reff_code ;

						-- Louis Senin, 05 Februari 2024 11.21.04 -- penambahan fungsing untuk hitung ulang agreement information
						begin
							select	@agreement_no = agreement_no
							from	dbo.agreement_asset
							where	asset_no		= @reff_code ;
						
							exec dbo.xsp_job_update_late_return_charges @p_agreement_no = @agreement_no

							exec dbo.xsp_agreement_information_update @p_agreement_no		= @agreement_no
																	  ,@p_mod_date			= @mod_date
																	  ,@p_mod_by			= @mod_by
																	  ,@p_mod_ip_address	= @mod_ip_address ;
				
						end

						update	dbo.agreement_asset
						set		asset_status	= 'RETURN' 
								--
								,mod_date		= @mod_date
								,mod_by			= @mod_by
								,mod_ip_address = @mod_ip_address
						where	asset_no		= @reff_code ;

						if exists-- raffy 2025/08/07 cr fase 3
						(
							select	1 
							from	dbo.agreement_asset 
							where	asset_no = @reff_code
							and		maturity_date < return_date
						)
                        begin
							exec dbo.xsp_handover_to_monitoring_late_return @p_asset_no			= @reff_code,     
							                                                @p_cre_date			= @mod_date, 
							                                                @p_cre_by			= @mod_by,        
							                                                @p_cre_ip_address	= @mod_ip_address,
							                                                @p_mod_date			= @mod_date, 
							                                                @p_mod_by			= @mod_by,        
							                                                @p_mod_ip_address	= @mod_ip_address 
							

						end


						
					end
					else
					begin
						--update data handover date di tabel asset replacement detil
						exec dbo.xsp_asset_replacement_detail_update_handover_date	@p_code				= @reff_code
																				   ,@p_asset_no			= @asset_no
																				   ,@p_handover_date	= @handover_bast_date
																				   ,@p_type				= @type
																				   ,@p_mod_date			= @mod_date
																				   ,@p_mod_by			= @mod_by
																				   ,@p_mod_ip_address	= @mod_ip_address
					end

					set @number_rows =+ 1 ;
						set @last_id = @id_interface ;
				
					update	dbo.opl_interface_handover_asset
					set		settle_date		= getdate()
							,job_status		= 'POST'
							--
							,mod_date		= @mod_date
							,mod_by			= @mod_by
							,mod_ip_address	= @mod_ip_address
					where	code			= @code_interface

				commit transaction
			end try
			begin catch

				rollback transaction 
				set @msg = error_message();
			
				--cek poin
				update	dbo.opl_interface_handover_asset 
				set		job_status = 'FAILED'
						,failed_remarks = @msg
				where	id = @id_interface 
				
				/*insert into dbo.sys_job_tasklist_log*/
				set @current_mod_date = getdate();
				exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code		= @code_sys_job
															,@p_status				= N'Error'
															,@p_start_date			= @mod_date
															,@p_end_date			= @current_mod_date
															,@p_log_description		= @msg
															,@p_run_by				= @mod_by
															,@p_from_id				= @from_id  
															,@p_to_id				= @id_interface 
															,@p_number_of_rows		= @number_rows 
															,@p_cre_date			= @current_mod_date
															,@p_cre_by				= @mod_by		
															,@p_cre_ip_address		= @mod_ip_address
															,@p_mod_date			= @current_mod_date
															,@p_mod_by				= @mod_by		
															,@p_mod_ip_address		= @mod_ip_address  ;

				-- clear cursor when error
				close curr_interface_handover_asset ;
				deallocate curr_interface_handover_asset ;
			
				-- stop looping
				break

			end catch   
	
			fetch next from curr_interface_handover_asset
			into @id_interface 
				 ,@reff_code
				 ,@code_interface 
				 ,@handover_code		
				 ,@handover_bast_date
				 ,@handover_status	
				 ,@handover_remark	
				 ,@type
				 ,@asset_no

		end ;
		
		begin -- close cursor
			if cursor_status('global', 'curr_interface_handover_asset') >= -1
			begin
				if cursor_status('global', 'curr_interface_handover_asset') > -1
				begin
					close curr_interface_handover_asset ;
				end ;

				deallocate curr_interface_handover_asset ;
			end ;
		end ;
		
		--cek poin
		if (@last_id > 0)
		begin
			update dbo.sys_job_tasklist 
			set last_id = @last_id 
			where code = @code_sys_job
		
			/*insert into dbo.sys_job_tasklist_log*/
			set @current_mod_date = getdate();
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
													,@p_status				= 'Success'
													,@p_start_date			= @mod_date
													,@p_end_date			= @current_mod_date 
													,@p_log_description		= ''
													,@p_run_by				= @mod_by
													,@p_from_id				= @from_id 
													,@p_to_id				= @last_id 
													,@p_number_of_rows		= @number_rows 
													,@p_cre_date			= @mod_date		
													,@p_cre_by				= @mod_by		
													,@p_cre_ip_address		= @mod_ip_address
													,@p_mod_date			= @mod_date		
													,@p_mod_by				= @mod_by		
													,@p_mod_ip_address		= @mod_ip_address
					    
		end
	end
