-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_adjustment_post]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@branch_code				nvarchar(50)
			,@company_code				nvarchar(50)
			,@status					nvarchar(20)
			,@asset_code				nvarchar(50)
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid					int 
			,@max_day					int
			,@date						datetime
			,@category_code				nvarchar(50)
			,@purchase_price			decimal(18,2)
			,@new_net_book_value_comn	decimal(18,2)
			,@new_net_book_value_fiscal	decimal(18,2)
			,@adjust_type				nvarchar(50)
			,@adjust_amount				decimal(18,2)
			,@process_code				nvarchar(50)
			,@total_adjust_hist			decimal(18,2)
			,@last_adjust_date			datetime
			,@total_depre_hist			decimal(18,2)
			,@amount_reval				decimal(18,2)
			,@new_purchase_date			datetime
			,@old_purchase_date			datetime
			,@total_depre				decimal(18,2)
			,@nbv						decimal(18,2)
			,@journal_code				nvarchar(50)
			,@depre_period				nvarchar(6)
			,@total_depre_fiscal		decimal(18,2)
			,@nbv_fiscal				decimal(18,2)
			,@system_date				datetime = dbo.xfn_get_system_date()
			,@last_depre				datetime
            ,@rate						decimal(9,6)
			,@depre_cat_comm_code		nvarchar(50)
			,@is_final_grn				nvarchar(1)
			,@adjustment_item			nvarchar(4000)
			,@is_from_proc				nvarchar(1)

	BEGIN TRY -- 
		select	@status						= dor.status
				,@asset_code				= dor.asset_code
				,@company_code				= dor.company_code
				,@date						= dor.date
				,@purchase_price			= ast.purchase_price
				,@new_net_book_value_comn	= dor.new_netbook_value_comm
				,@new_net_book_value_fiscal = dor.new_netbook_value_fiscal
				,@adjust_type				= dor.adjustment_type
				,@category_code				= ast.category_code
				,@adjust_amount				= dor.total_adjustment
				,@new_purchase_date			= dor.new_purchase_date
				,@old_purchase_date			= ast.purchase_date
				,@depre_period				= ast.depre_period_comm
				,@depre_cat_comm_code		= ast.depre_category_comm_code
				,@is_final_grn				= ast.is_final_grn
				,@is_from_proc				= dor.is_from_proc
		from	dbo.adjustment dor
		inner join dbo.asset ast on dor.asset_code = ast.code
		where	dor.code = @p_code ;

		-- Asqal 12-Oct-2022 ket : for WOM to control back date based on setting (+) ====
		set @is_valid = dbo.xfn_date_validation(@date)
		select @max_day = cast(value as int) from dbo.sys_global_param where code = 'MDT'

		if @is_valid = 0 and isnull(@is_from_proc,0) = 0
		begin
			set @msg = 'The maximum back date input transaction is ' + cast(@max_day as char(2)) + ' in each month';
			RAISERROR(@msg ,16,-1);	    
		END

		-- Arga 06-Nov-2022 ket : request wom back date only for register aset (+)
		if datediff(month,@date,dbo.xfn_get_system_date()) > 0  and isnull(@is_from_proc,0) = 0
		begin
			set @msg = 'Back date transactions are not allowed for this transaction';
			RAISERROR(@msg ,16,-1);	 
		END
		-- End of additional control ===================================================

		select	@adjustment_item = adjustment_description
		from	dbo.adjustment_detail
		where	adjustment_code = @p_code


		IF (@status = 'ON PROCESS')
		BEGIN
			if (@adjustment_item <> 'GPS') --RAFFY 2025/07/21 TEMPORARY SOLUTION, KALO ADA GPS MASUK, GAUSAH ADJUST NILAI ASSET DAN DEPRENYA
				begin

			    IF @adjust_type = 'REVAL'
				BEGIN
					IF @adjust_amount > 0
						set @process_code = 'ADJPNM'
					ELSE IF @adjust_amount < 0
					BEGIN

						declare @get_amount_value table
						(amount		numeric(18,2))

						-- Arga 10-Nov-2022 ket : use new condition according to discuss with zaka wom (+)
						delete @get_amount_value
						insert into @get_amount_value (amount)
						exec dbo.xsp_asset_get_adjustment_surplus_amount @company_code, @p_code, @asset_code

						select	@amount_reval = amount
						from	@get_amount_value

						--if @amount_reval > 0
						--	set @process_code = 'ADJPNM' -- gain
						--else
						--	set @process_code = 'ADJMD' -- loss

						SET @process_code = 'ADJPNM' -- gain

						/* -- Arga 10-Nov-2022 ket : use new condition according to discuss with zaka wom (-)
						insert into @get_amount_value (amount)
						exec dbo.xsp_asset_get_adjustment_amount_reval @company_code, @p_code, @asset_code

						select	@amount_reval = amount
						from	@get_amount_value
						set @amount_reval = abs(@amount_reval)

						delete @get_amount_value
						insert into @get_amount_value (amount)
						exec dbo.xsp_asset_get_adjustment_amount_reval_with_hist @company_code, @p_code, @asset_code
						--exec dbo.xsp_asset_get_adjustment_amount_reval @company_code, @p_code, @asset_code

						select	@total_adjust_hist = amount
						from	@get_amount_value

						if @amount_reval >= @total_adjust_hist
							set @process_code = 'ADJMD'
						else
							set @process_code = 'ADJM'
						*/

					end

					--exec dbo.xsp_efam_journal_adjusment_register @p_adjusment_code		= @p_code
			  --  												 ,@p_process_code		= @process_code
			  --  												 ,@p_company_code		= @company_code
			  --  												 ,@p_reff_source_no		= ''
			  --  												 ,@p_reff_source_name	= ''
			  --  												 ,@p_mod_date			= @p_mod_date
			  --  												 ,@p_mod_by				= @p_mod_by
			  --  												 ,@p_mod_ip_address		= @p_mod_ip_address
				end

				--insert rv commercial
				select @rate = 100 - (usefull * rate)
				from dbo.master_depre_category_commercial
				where code = @depre_cat_comm_code

				-- Arga 19-Oct-2022 ket : additional control for WOM (+)
				select @is_valid = dbo.xfn_depre_threshold_validation(@company_code, @category_code, @purchase_price)

				-- SELECT @is_valid, @is_final_grn 
				-- if @is_valid = 1 AND @is_final_grn = '1'
								if @is_valid = 1
				begin
					exec dbo.xsp_asset_depreciation_schedule_commercial_generate_from_adjustment @p_code			 = @p_code
																								,@p_asset_code		 = @asset_code
																								 ,@p_mod_date		 = @p_mod_date
																								 ,@p_mod_by			 = @p_mod_by
																								 ,@p_mod_ip_address	 = @p_mod_ip_address

					exec dbo.xsp_asset_depreciation_schedule_fiscal_generate_from_adjustment @p_code			 = @p_code
																							 ,@p_mod_date		 = @p_mod_date
																							 ,@p_mod_by			 = @p_mod_by
																							 ,@p_mod_ip_address	 = @p_mod_ip_address
				end

				--update nilai asset
				update	dbo.asset
				set		net_book_value_comm		= @new_net_book_value_comn
						,net_book_value_fiscal	= @new_net_book_value_fiscal
						,purchase_price			= @purchase_price + @adjust_amount
						,residual_value			= cast(@rate / 100 *  (@purchase_price + @adjust_amount )as bigint)--@new_net_book_value_comn AS bigint)
						--
						,mod_date				= @p_mod_date
						,mod_by					= @p_mod_by
						,mod_ip_address			= @p_mod_ip_address
				where	code = @asset_code

			    if @adjust_type <> 'REVAL'
				begin

					if @new_purchase_date <> @old_purchase_date
						set @process_code = 'ADJNR'
					else
						set @process_code = 'ADJST'

					--exec dbo.xsp_efam_journal_adjusment_register @p_adjusment_code		= @p_code
			  --  												 ,@p_process_code		= @process_code
			  --  												 ,@p_company_code		= @company_code
			  --  												 ,@p_reff_source_no		= ''
			  --  												 ,@p_reff_source_name	= ''
			  --  												 ,@p_mod_date			= @p_mod_date
			  --  												 ,@p_mod_by				= @p_mod_by
			  --  												 ,@p_mod_ip_address		= @p_mod_ip_address
				END



			    if @adjust_type <> 'REVAL'
				begin
					update	dbo.asset
					set		purchase_date = @new_purchase_date
					where	code = @asset_code

					if isnull(@depre_period,'') <> '' and @is_valid = 1
					begin
						-- check terakhir depre kapan
						select	@last_depre = max(depreciation_date)
						from	dbo.asset_depreciation
						where	asset_code = @asset_code
						and		status = 'POST'
						set @last_depre = isnull(@last_depre,@system_date)

						-- Arga 06-Nov-2022 ket : update depre to the current schedule (+)
						select	@journal_code = isnull(code, '')
						from	dbo.efam_interface_journal_gl_link_transaction
						where	transaction_code = @p_code

						update	dbo.asset_depreciation_schedule_commercial
						set		transaction_code = @journal_code
						where	asset_code = @asset_code
						and		convert(char(6),depreciation_date,112) <= convert(char(6),@last_depre,112) --@depre_period
						and		transaction_code = @p_code

						-- Arga 06-Nov-2022 ket : back to last data with current depre (+)
						select	top 1
								@nbv			= net_book_value
								,@total_depre	= accum_depre_amount
						from	dbo.asset_depreciation_schedule_commercial
						where	asset_code = @asset_code
						and		convert(char(6),depreciation_date,112) <= convert(char(6),@last_depre,112) --= @depre_period
						and		cre_by = @p_mod_by
						order by depreciation_date desc

						select	top 1
								@nbv_fiscal				= net_book_value
								,@total_depre_fiscal	= accum_depre_amount
						from	dbo.asset_depreciation_schedule_fiscal
						where	asset_code = @asset_code
						and		convert(char(6),depreciation_date,112) <= convert(char(6),@last_depre,112) --= @depre_period
						and		cre_by = @p_mod_by
						order by depreciation_date desc

						update	dbo.asset
						set		total_depre_comm				= isnull(@total_depre,@purchase_price)
								,total_depre_fiscal				= isnull(@total_depre_fiscal,@purchase_price)
								,net_book_value_comm			= isnull(@nbv,0)
								,net_book_value_fiscal			= isnull(@nbv_fiscal,0)
						where	code = @asset_code

						update	dbo.adjustment
						set		new_netbook_value_comm		= @nbv
								,new_netbook_value_fiscal	= @nbv_fiscal
								--
								,mod_date		= @p_mod_date
								,mod_by			= @p_mod_by
								,mod_ip_address = @p_mod_ip_address
						where	code			= @p_code ;	

					end
					end
				end

				update	dbo.adjustment
				set		status			= 'POST'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @p_code ;	

		end
		-- else if (@status <> 'ON PROCESS')
		else
		begin
			set @msg = 'Data already proceed';
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
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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
