/*
exec xsp_job_interface_in_ifinopl_purchase_request
*/
CREATE PROCEDURE [dbo].[xsp_job_interface_in_ifinopl_purchase_request]
as
	declare @msg					   nvarchar(max)
			,@row_to_process		   int
			,@last_id_from_job		   bigint
			,@id_interface			   bigint
			,@code_sys_job			   nvarchar(50)
			,@is_active				   nvarchar(1)
			,@last_id				   bigint		= 0
			,@number_rows			   int			= 0
			,@code_interface		   nvarchar(50)
			,@result_fa_code		   nvarchar(50)
			,@result_fa_name		   nvarchar(250)
			,@result_date			   datetime
			,@request_status		   nvarchar(10)
			,@mod_date				   datetime		= getdate()
			,@mod_by				   nvarchar(15) = N'job'
			,@mod_ip_address		   nvarchar(15) = N'127.0.0.1'
			,@from_id				   bigint		= 0
			,@current_mod_date		   datetime
			,@asset_no				   nvarchar(50)
			,@fa_reff_no_1			   nvarchar(250)
			,@fa_reff_no_2			   nvarchar(250)
			,@fa_reff_no_3			   nvarchar(250)
			,@unit_from				   nvarchar(10)
			,@agreement_no			   nvarchar(50)
			,@agreement_external_no	   nvarchar(50) 
			,@category_type			   nvarchar(20)

	select	@code_sys_job		= code
			,@row_to_process	= row_to_process
			,@last_id_from_job	= last_id
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_in_ifinopl_purchase_request' -- sesuai dengan nama sp ini

	IF (@is_active = '1')
	BEGIN
		--get cashier received request
		DECLARE curr_interface_purchase_request CURSOR for
		
			SELECT		id
						,result_fa_code
						,result_fa_name  
						,fa_reff_no_01
						,fa_reff_no_02
						,fa_reff_no_03
						,result_date
						,request_status
						,code
						,unit_from
						,asset_no
						,category_type
			FROM		dbo.opl_interface_purchase_request
			WHERE		settle_date IS NULL
						AND request_status IN ('POST', 'CANCEL')
						AND job_status IN ('HOLD','FAILED')
			ORDER BY	id ASC OFFSET 0 ROWS FETCH NEXT @row_to_process ROWS ONLY ;

		open curr_interface_purchase_request
		fetch next from curr_interface_purchase_request 
		into @id_interface
			 ,@result_fa_code
			 ,@result_fa_name 
			 ,@fa_reff_no_1
			 ,@fa_reff_no_2
			 ,@fa_reff_no_3
			 ,@result_date
			 ,@request_status
			 ,@code_interface
			 ,@unit_from
			 ,@asset_no
			 ,@category_type
		
		while @@fetch_status = 0
		begin
			begin try
				begin transaction

					if (@number_rows = 0)
					begin
						set @from_id = @id_interface
					end

					if	(@request_status <> 'CANCEL')
					begin
						if (@unit_from = 'BUY')
						begin

							if exists
							(
								select	1
								from	dbo.application_asset_detail
								where	purchase_code = @code_interface
							)
							begin
								update	dbo.application_asset_detail
								set		purchase_status		= 'DONE'
										--
										,mod_date			= @mod_date
										,mod_by				= @mod_by
										,mod_ip_address		= @mod_ip_address
								where	purchase_code		= @code_interface
							end

							if exists
							(
								select	1
								from	dbo.application_asset_budget
								where	purchase_code = @code_interface
							)
							begin
								update	dbo.application_asset_budget
								set		purchase_status		= 'DONE'
										--
										,mod_date			= @mod_date
										,mod_by				= @mod_by
										,mod_ip_address		= @mod_ip_address
								where	purchase_code		= @code_interface
							end

							update	dbo.application_asset
							set		fa_code				= @result_fa_code
									,fa_name			= @result_fa_name 
									,fa_reff_no_01		= @fa_reff_no_1
									,fa_reff_no_02		= @fa_reff_no_2
									,fa_reff_no_03		= @fa_reff_no_3
									--
									,mod_date			= @mod_date
									,mod_by				= @mod_by
									,mod_ip_address		= @mod_ip_address
							where	purchase_code		= @code_interface ;
				 
							update	dbo.purchase_request
							set		result_fa_code		= @result_fa_code
									,result_fa_name		= @result_fa_name 
									,result_date		= @result_date
									,request_status		= @request_status
									--
									,mod_date			= @mod_date
									,mod_by				= @mod_by
									,mod_ip_address		= @mod_ip_address
							where	code				= @code_interface ; 
						end
						else if (@unit_from = 'RENT')
						begin 
							update	dbo.application_asset
							set		replacement_fa_code				= @result_fa_code
									,replacement_fa_name			= @result_fa_name 
									,replacement_fa_reff_no_01		= @fa_reff_no_1
									,replacement_fa_reff_no_02		= @fa_reff_no_2
									,replacement_fa_reff_no_03		= @fa_reff_no_3
									--
									,mod_date						= @mod_date
									,mod_by							= @mod_by
									,mod_ip_address					= @mod_ip_address
							where	purchase_gts_code				= @code_interface ;
				 
							update	dbo.purchase_request
							set		result_fa_code		= @result_fa_code
									,result_fa_name		= @result_fa_name 
									,result_date		= @result_date
									,request_status		= @request_status
									--
									,mod_date			= @mod_date
									,mod_by				= @mod_by
									,mod_ip_address		= @mod_ip_address
							where	code				= @code_interface ;
						end

						if (@category_type = 'ASSET')
						begin
							if exists
							(
								select	1
								from	dbo.realization_detail rd
										inner join dbo.realization rz on (rz.code			= rd.realization_code)
										inner join dbo.application_asset aa on (aa.asset_no = rd.asset_no)
								where	rd.asset_no				   = @asset_no
										and isnull(aa.replacement_fa_code, '') <> ''
										and isnull(aa.is_request_gts, '0') = '1'
										and
										(
											aa.purchase_gts_status	   not in ('DELIVERY','AGREEMENT')
										)
										and rz.status			   = 'POST'
							)
							begin
								select	@asset_no = aa.asset_no
										,@agreement_no = rz.agreement_no
										,@agreement_external_no = rz.agreement_external_no
								from	dbo.realization_detail rd
										inner join dbo.realization rz on (rz.code			= rd.realization_code)
										inner join dbo.application_asset aa on (aa.asset_no = rd.asset_no)
								where	rd.asset_no				   = @asset_no
										and isnull(aa.replacement_fa_code, '') <> ''
										and isnull(aa.is_request_gts, '0') = '1'
										and
										(
											aa.purchase_gts_status	   not in ( 'DELIVERY','AGREEMENT')
										)
										and rz.status			   = 'POST'

								exec dbo.xsp_application_asset_allocation_proceed @p_asset_no					= @asset_no
																				  ,@p_agreement_no				= @agreement_no
																				  ,@p_agreement_external_no		= @agreement_external_no
																				  --				 
																				  ,@p_mod_date					= @mod_date
																				  ,@p_mod_by					= @mod_by
																				  ,@p_mod_ip_address			= @mod_ip_address ;
							end ;
							else if exists
							(
								select	1
								from	dbo.realization_detail rd
										inner join dbo.realization rz on (rz.code			= rd.realization_code)
										inner join dbo.application_asset aa on (aa.asset_no = rd.asset_no)
								where	rd.asset_no			   = @asset_no
										and isnull(aa.fa_code, '') <> ''
										and isnull(aa.replacement_fa_code, '') = ''
										and isnull(aa.is_request_gts, '0') = '0'
										and
										(
											aa.purchase_status	  not in ( 'DELIVERY','AGREEMENT')
										)
										and rz.status		   = 'POST'
							)
							begin
								select	@asset_no = aa.asset_no
										,@agreement_no = rz.agreement_no
										,@agreement_external_no = rz.agreement_external_no
								from	dbo.realization_detail rd
										inner join dbo.realization rz on (rz.code			= rd.realization_code)
										inner join dbo.application_asset aa on (aa.asset_no = rd.asset_no)
								where	rd.asset_no			   = @asset_no
										and isnull(aa.fa_code, '') <> ''
										and isnull(aa.replacement_fa_code, '') = ''
										and isnull(aa.is_request_gts, '0') = '0'
										and
										(
											aa.purchase_status	   not in ( 'DELIVERY','AGREEMENT')
										)
										and rz.status		   = 'POST'

								exec dbo.xsp_application_asset_allocation_proceed @p_asset_no					= @asset_no
																					,@p_agreement_no			= @agreement_no
																					,@p_agreement_external_no	= @agreement_external_no
																					--				 
																					,@p_mod_date				= @mod_date
																					,@p_mod_by					= @mod_by
																					,@p_mod_ip_address			= @mod_ip_address ;
							end ;
							--if exists
							--(
							--	select	1
							--	from	dbo.realization_detail rd
							--			inner join dbo.realization rz on (rz.code = rd.realization_code)
							--			inner join dbo.application_asset aa on (aa.asset_no = rd.asset_no)
							--	where	rd.asset_no					   = @asset_no
							--			and
							--			(
							--				aa.fa_code is not null
							--				or	aa.replacement_fa_code is not null
							--			) 
							--			and
							--			(
							--				aa.purchase_status		   <> 'DELIVERY'
							--				or	aa.purchase_gts_status <> 'DELIVERY'
							--			)
							--			and rz.status = 'POST'
							--)
							--begin 
							--	select	@asset_no = aa.asset_no
							--			,@agreement_no = rz.agreement_no
							--			,@agreement_external_no = rz.agreement_external_no
							--	from	dbo.realization_detail rd
							--			inner join dbo.realization rz on (rz.code		  = rd.realization_code)
							--			inner join dbo.application_asset aa on (aa.asset_no = rd.asset_no)
							--	where	rd.asset_no					   = @asset_no
							--			and
							--			(
							--				aa.fa_code is not null
							--				or	aa.replacement_fa_code is not null
							--			)
							--			and
							--			(
							--				aa.purchase_status		   <> 'DELIVERY'
							--				or	aa.purchase_gts_status <> 'DELIVERY'
							--			)
							--			and rz.status				   = 'POST' ;

							--	exec dbo.xsp_application_asset_allocation_proceed @p_asset_no					= @asset_no
							--														,@p_agreement_no			= @agreement_no
							--														,@p_agreement_external_no	= @agreement_external_no
							--														--				 
							--														,@p_mod_date				= @mod_date
							--														,@p_mod_by					= @mod_by
							--														,@p_mod_ip_address			= @mod_ip_address ;

							--end ;
						end
					end
					else
					begin
						update	dbo.purchase_request
						set		request_status		= 'CANCEL'
								--
								,mod_date			= @mod_date
								,mod_by				= @mod_by
								,mod_ip_address		= @mod_ip_address
						where	code				= @code_interface ;

						if (@unit_from = 'BUY')
						begin

							if exists
							(
								select	1
								from	dbo.application_asset_detail
								where	purchase_code = @code_interface
							)
							begin
								update	dbo.application_asset_detail
								set		purchase_status		= 'NONE'
										,purchase_code		= null
										--
										,mod_date			= @mod_date
										,mod_by				= @mod_by
										,mod_ip_address		= @mod_ip_address
								where	purchase_code		= @code_interface
							end

							if exists
							(
								select	1
								from	dbo.application_asset_budget
								where	purchase_code = @code_interface
							)
							begin
								update	dbo.application_asset_budget
								set		purchase_status		= 'NONE'
										,purchase_code		= null
										--
										,mod_date			= @mod_date
										,mod_by				= @mod_by
										,mod_ip_address		= @mod_ip_address
								where	purchase_code		= @code_interface
							end

							update	dbo.application_asset
							set		purchase_status		= 'NONE'
									,purchase_code		= null
									,estimate_po_date	= null
									--
									,mod_date			= @mod_date
									,mod_by				= @mod_by
									,mod_ip_address		= @mod_ip_address
							where	purchase_code		= @code_interface ;
						end
						else if (@unit_from = 'RENT')
						begin
						
							if exists
							(
								select	1
								from	dbo.application_asset aa
								where	aa.asset_no	  = @asset_no
										and aa.fa_code is not null
							)
							begin
								update	dbo.application_asset
								set		purchase_gts_status	= null
										,is_request_gts		= '0'
										,purchase_gts_code  = null
										--
										,mod_date			= @mod_date
										,mod_by				= @mod_by
										,mod_ip_address		= @mod_ip_address
								where	purchase_gts_code	= @code_interface ;
								
								if exists
								(
									select	1
									from	dbo.realization_detail rd
											inner join dbo.realization on (realization.code = rd.realization_code)
									where	rd.asset_no = @asset_no
											and status	= 'POST'
								)
								begin
									if not exists
									(
										select	1
										from	dbo.opl_interface_handover_asset
										where	asset_no = @asset_no
												and status <> 'CANCEL'
									)
									begin 
										select	@agreement_no				= agreement_no 
												,@agreement_external_no		= agreement_external_no
										from	dbo.realization_detail rd
												inner join dbo.realization on (realization.code = rd.realization_code)
										where	rd.asset_no = @asset_no
												and status	= 'POST'

										if exists(select 1 from dbo.application_asset where asset_no = @asset_no and isnull(is_request_gts, '0') = '1' and isnull(replacement_fa_code,'') <> '')
										begin
											exec dbo.xsp_application_asset_allocation_proceed @p_asset_no				= @asset_no
																							  ,@p_agreement_no			= @agreement_no
																							  ,@p_agreement_external_no = @agreement_external_no
																							  --				 
																							  ,@p_mod_date				= @mod_date
																							  ,@p_mod_by				= @mod_by
																							  ,@p_mod_ip_address		= @mod_ip_address ;
										end
										else if exists (select 1 from dbo.application_asset where asset_no = @asset_no and isnull(is_request_gts, '0') = '0' and isnull(fa_code,'') <> '')
										begin
											exec dbo.xsp_application_asset_allocation_proceed	@p_asset_no					= @asset_no
																								,@p_agreement_no			= @agreement_no
																								,@p_agreement_external_no	= @agreement_external_no
																								--				 
																								,@p_mod_date				= @mod_date
																								,@p_mod_by					= @mod_by
																								,@p_mod_ip_address			= @mod_ip_address ;
										end
									end ;
								end ;
							end
							else
							begin
								update	dbo.application_asset
								set		purchase_gts_status	= 'NONE'
										,purchase_gts_code  = null
										--
										,mod_date			= @mod_date
										,mod_by				= @mod_by
										,mod_ip_address		= @mod_ip_address
								where	purchase_gts_code	= @code_interface ;
							end
						end 
					end

					set @number_rows =+ 1 ;
					set @last_id = @id_interface ;
				
					update	dbo.opl_interface_purchase_request
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
				update	dbo.opl_interface_purchase_request 
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
				close curr_interface_purchase_request ;
				deallocate curr_interface_purchase_request ;
			
				-- stop looping
				break

			end catch   
	
			fetch next from curr_interface_purchase_request
			into @id_interface
				 ,@result_fa_code
				 ,@result_fa_name 
				 ,@fa_reff_no_1
				 ,@fa_reff_no_2
				 ,@fa_reff_no_3
				 ,@result_date
				 ,@request_status
				 ,@code_interface
				 ,@unit_from
				 ,@asset_no
				 ,@category_type

		end ;
		
		begin -- close cursor
			if cursor_status('global', 'curr_interface_purchase_request') >= -1
			begin
				if cursor_status('global', 'curr_interface_purchase_request') > -1
				begin
					close curr_interface_purchase_request ;
				end ;

				deallocate curr_interface_purchase_request ;
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
