CREATE PROCEDURE dbo.xsp_sale_post
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@status				nvarchar(20)
			,@conpany_code			nvarchar(50)
			,@asset_code_detail		nvarchar(50)
			,@buytype				nvarchar(50)
			,@asset_code			nvarchar(50)
			,@phone					nvarchar(50)
			,@buyer_phone			nvarchar(50)
			,@buyer					nvarchar(250)
			,@sale_amount			decimal(18,2)
			,@net_book_value		decimal(18,2)
			,@total_gain_loss		decimal(18,2)
			,@gain_loss				decimal(18,2)
			,@sale_bidding_code		nvarchar(50)
			,@date					datetime = getdate()
			,@is_winner				nvarchar(1)
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid				int 
			,@max_day				int
			,@sale_date				datetime
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@total_data			int
			,@code_asset			nvarchar(50)

	begin try
		
		
		select	@sale_bidding_code	= sb.code
		from	dbo.sale sl
				left join dbo.sale_bidding sb on (sb.sale_code = sl.code)
		where	sl.code = @p_code
		and		sb.is_winner = '1' ;

		-- refresh amount based on winner
		--exec dbo.xsp_sale_bidding_update_status @p_code				= @sale_bidding_code
		--                                       ,@p_mod_date			= @p_mod_date
		--                                       ,@p_mod_by			= @p_mod_by
		--                                       ,@p_mod_ip_address	= @p_mod_ip_address
		
		
		select	@status				= sl.status
				,@phone				= sb.phone_no
				,@buyer				= sb.sale_to
				,@sale_amount		= sl.sale_amount
				,@sale_bidding_code	= sb.sale_code
				,@conpany_code		= sl.company_code
				,@sale_date			= sl.sale_date
				,@is_winner			= sb.is_winner
				,@branch_code		= sl.branch_code
				,@branch_name		= sl.branch_name
				,@buytype			= sb.buy_type
		from	dbo.sale sl
				left join dbo.sale_bidding sb on (sb.sale_code = sl.code)
		where	sl.code = @p_code
		and		sb.is_winner = '1' ;

		--if not exists (select 1 from dbo.sale_bidding where is_winner = '1' and sale_code = @p_code)
		--begin
		--	set @msg = 'Silakan pilih pemenang lelang sebelum posting data';
		--	raiserror(@msg ,16,-1);	    
		--end

		--if @sale_amount <= 0
		--begin
		--	set @msg = 'Sale Amount harus lebih dari 0. Silakan cek kembali data anda';
		--	raiserror(@msg ,16,-1);	    
		--end

		-- Asqal 12-Oct-2022 ket : for WOM to control back date based on setting (+) ====
		set @is_valid = dbo.xfn_date_validation(@sale_date)
		select @max_day = cast(value as int) from dbo.sys_global_param where code = 'MDT'

		if @is_valid = 0
		begin
			set @msg = 'Maximum back date input transaction date ' + cast(@max_day as char(2)) + ' every month';
			raiserror(@msg ,16,-1);	    
		end
		
		-- Arga 06-Nov-2022 ket : request wom back date only for register aset (+)
		if datediff(month,@sale_date,dbo.xfn_get_system_date()) > 0
		begin
			set @msg = 'Back date transactions are not allowed for this transaction';
			raiserror(@msg ,16,-1);	 
		end
		-- End of additional control ===================================================
		
		select	@net_book_value = sum(net_book_value)
				,@total_data	= count(1)
		from	dbo.sale_detail 
		where	sale_code = @p_code ;

		set	@total_gain_loss	= sum(isnull(@sale_amount,0)) - sum(isnull(@net_book_value, 0)) ;
		
		declare curr_sale_post cursor fast_forward read_only for 
		select	case sb.buy_type when 'By Batch' then sd.asset_code else sbd.asset_code end
				,sb.buy_type
				,sd.asset_code
				,case sb.buy_type when 'By Batch' then sb.sale_amount else sbd.sale_amount end
		from	dbo.sale_bidding sb
				left join dbo.sale_bidding_detail sbd on (sbd.bidding_code = sb.code)
				left join dbo.sale sl on (sl.code						   = sb.sale_code)
				left join dbo.sale_detail sd on (sd.sale_code			   = sl.code)
		where	sb.sale_code = @p_code
		and		sb.is_winner = '1' ;

		open curr_sale_post
		
		fetch next from curr_sale_post 
		into @asset_code
			,@buytype
			,@asset_code_detail
			,@sale_amount

		while @@fetch_status = 0
		begin
			if (@buytype = 'By Batch')
			begin
 
				if @net_book_value <> 0
				begin
				    update	dbo.sale_detail
					set		gain_loss = (net_book_value/@net_book_value) * @total_gain_loss
					where	sale_code = @p_code
					and		asset_code = @asset_code
				end
				else
				begin
				     update	dbo.sale_detail
					 set	gain_loss = @total_gain_loss / @total_data
					 where	sale_code = @p_code
					 and	asset_code = @asset_code
				end			

				
				--update	dbo.sale_detail
				--set		sale_value = gain_loss + net_book_value
				--where	sale_code = @p_code
				--and		asset_code = @asset_code
				
				--select	@sale_amount = sale_value
				--from	dbo.sale_detail
				--where	sale_code = @p_code
				--and		asset_code = @asset_code

				update	dbo.asset
				set		status			= 'SOLD'
						,sale_date		= @sale_date --@date
						,sale_amount	= @sale_amount
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @asset_code_detail ;
			end
			else if (@buytype = 'By Unit')
			begin
				if exists ( select 1 from dbo.sale_bidding_detail where asset_code = @asset_code)
				begin
					--update	dbo.sale_detail
					--set		sale_value = @sale_amount
					--where	sale_code = @p_code
					--and		asset_code = @asset_code
					
				 --   update	dbo.sale_detail
					--set	gain_loss = sale_value - net_book_value
					--where	sale_code = @p_code
					--and	asset_code = @asset_code
				
					update	dbo.asset
					set		status			= 'SOLD'
							,sale_date		= @sale_date --@date
							,sale_amount	= @sale_amount
							--
							,mod_date		= @p_mod_date
							,mod_by			= @p_mod_by
							,mod_ip_address = @p_mod_ip_address
					where	code			= @asset_code
				end
				else
				begin
					update	dbo.asset
					set		status			= 'STOCK'
							--
							,mod_date		= @p_mod_date
							,mod_by			= @p_mod_by
							,mod_ip_address = @p_mod_ip_address
					where	code			= @asset_code
				end
			end
		
		    fetch next from curr_sale_post 
			into @asset_code
				,@buytype
				,@asset_code_detail
				,@sale_amount
		end
		
		close curr_sale_post
		deallocate curr_sale_post

		if (@status = 'ON PROGRESS')
		begin
				if @buytype = 'By Batch'
				begin
				    if exists (select 1 from dbo.adjustment where asset_code in (select asset_code from dbo.sale_detail where sale_code = @p_code) and status = 'POST' and total_adjustment > 0)
					begin
					    exec dbo.xsp_efam_journal_sale_register @p_sale_code	= @p_code
															,@p_process_code	= 'ADJPNP'
															,@p_company_code	= @conpany_code
															,@p_mod_date		= @p_mod_date
															,@p_mod_by			= @p_mod_by
															,@p_mod_ip_address	= @p_mod_ip_address
					end
					else
					begin
					    exec dbo.xsp_efam_journal_sale_register @p_sale_code	= @p_code
															,@p_process_code	= 'SELL'
															,@p_company_code	= @conpany_code
															,@p_mod_date		= @p_mod_date
															,@p_mod_by			= @p_mod_by
															,@p_mod_ip_address	= @p_mod_ip_address

						exec dbo.xsp_efam_journal_sale_register @p_sale_code		= @p_code
																,@p_process_code	= 'SELLR'
																,@p_company_code	= @conpany_code
																,@p_mod_date		= @p_mod_date
																,@p_mod_by			= @p_mod_by
																,@p_mod_ip_address	= @p_mod_ip_address
					end
				end
				else
				begin
					if exists (select 1 from dbo.adjustment where asset_code in (select asset_code from dbo.sale_bidding_detail sbd inner join dbo.sale_bidding sb on sb.code = sbd.bidding_code where sale_code = @p_code and is_winner = '1') and status = 'POST' and total_adjustment > 0)
					begin
						exec dbo.xsp_efam_journal_sale_register @p_sale_code	= @p_code
															,@p_process_code	= 'ADJPNP'
															,@p_company_code	= @conpany_code
															,@p_mod_date		= @p_mod_date
															,@p_mod_by			= @p_mod_by
															,@p_mod_ip_address	= @p_mod_ip_address
					end
					else
					begin
					    exec dbo.xsp_efam_journal_sale_register @p_sale_code	= @p_code
															,@p_process_code	= 'SELL'
															,@p_company_code	= @conpany_code
															,@p_mod_date		= @p_mod_date
															,@p_mod_by			= @p_mod_by
															,@p_mod_ip_address	= @p_mod_ip_address

						exec dbo.xsp_efam_journal_sale_register @p_sale_code		= @p_code
																,@p_process_code	= 'SELLR'
																,@p_company_code	= @conpany_code
																,@p_mod_date		= @p_mod_date
																,@p_mod_by			= @p_mod_by
																,@p_mod_ip_address	= @p_mod_ip_address
					end
				end
				
				update	dbo.sale
				set		status			= 'POST'
						--,buyer			= @buyer
						--,buyer_phone_no	= @phone
						--,sale_amount	= @sale_amount
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @p_code ;

				
				DECLARE curr_sale CURSOR FAST_FORWARD READ_ONLY for
                
				select	case sb.buy_type when 'By Batch' then sd.asset_code else sbd.asset_code end
				from	dbo.sale_bidding sb
						left join dbo.sale_bidding_detail sbd on (sbd.bidding_code = sb.code)
						left join dbo.sale sl on (sl.code						   = sb.sale_code)
						left join dbo.sale_detail sd on (sd.sale_code			   = sl.code)
				where	sb.sale_code = @p_code
				and		sb.is_winner = '1' ;
				
				OPEN curr_sale
				
				FETCH NEXT FROM curr_sale 
				into @code_asset
				
				WHILE @@FETCH_STATUS = 0
				BEGIN
				    if not exists (select 1 from dbo.asset_mutation_history where asset_code = @code_asset and document_refference_no = @p_code )
					begin
					exec dbo.xsp_asset_mutation_history_insert @p_id							 = 0
															   ,@p_asset_code					 = @code_asset
															   ,@p_date							 = @sale_date --@date
															   ,@p_document_refference_no		 = @p_code
															   ,@p_document_refference_type		 = 'SLL'
															   ,@p_usage_duration				 = 0
															   ,@p_from_branch_code				 = @branch_code
															   ,@p_from_branch_name				 = @branch_name
															   ,@p_to_branch_code				 = ''
															   ,@p_to_branch_name				 = ''
															   ,@p_from_location_code			 = ''
															   ,@p_to_location_code				 = ''
															   ,@p_from_pic_code				 = ''
															   ,@p_to_pic_code					 = ''
															   ,@p_from_division_code			 = ''
															   ,@p_from_division_name			 = ''
															   ,@p_to_division_code				 = ''
															   ,@p_to_division_name				 = ''
															   ,@p_from_department_code			 = ''
															   ,@p_from_department_name			 = ''
															   ,@p_to_department_code			 = ''
															   ,@p_to_department_name			 = ''
															   ,@p_from_sub_department_code		 = ''
															   ,@p_from_sub_department_name		 = ''
															   ,@p_to_sub_department_code		 = ''
															   ,@p_to_sub_department_name		 = ''
															   ,@p_from_unit_code				 = ''
															   ,@p_from_unit_name				 = ''
															   ,@p_to_unit_code					 = ''
															   ,@p_to_unit_name					 = ''
															   ,@p_cre_date						 = @p_mod_date	  
															   ,@p_cre_by						 = @p_mod_by		  
															   ,@p_cre_ip_address				 = @p_mod_ip_address
															   ,@p_mod_date						 = @p_mod_date	  
															   ,@p_mod_by						 = @p_mod_by		  
															   ,@p_mod_ip_address				 = @p_mod_ip_address
					end
				
				    FETCH NEXT FROM curr_sale 
					into @code_asset
				END
				
				CLOSE curr_sale
				DEALLOCATE curr_sale


			-- send mail attachment based on setting ================================================
			--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'PSRQTR'
			--												,@p_doc_code		= @p_code
			--												,@p_attachment_flag = 0
			--												,@p_attachment_file = ''
			--												,@p_attachment_path = ''
			--												,@p_company_code	= @conpany_code
			--												,@p_trx_no			= @p_code
			--												,@p_trx_type		= 'SELL'
			-- End of send mail attachment based on setting ================================================
				
		end
		else
		begin
			set @msg = 'Data already post.';
			raiserror(@msg ,16,-1);
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
