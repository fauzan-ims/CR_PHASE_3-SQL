CREATE PROCEDURE dbo.xsp_sell_settlement_proceed
(
	@p_id				bigint
	--
	,@p_mod_date	    datetime
	,@p_mod_by		    nvarchar(15)
	,@p_mod_ip_address  nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max)
			,@status							nvarchar(20)
			,@asset_code						nvarchar(50)
			,@reason_type						nvarchar(50)
			,@is_valid							int 
			,@max_day							int
			,@disposal_date						datetime
			,@company_code						nvarchar(50)
			,@interface_remarks					nvarchar(4000)
			,@req_date							datetime
			,@item_name							nvarchar(250)
			,@reff_approval_category_code		nvarchar(50)
			,@request_code						nvarchar(50)
			,@net_book_value					decimal(18,2)
			,@branch_code						nvarchar(50)
			,@branch_name						nvarchar(250)
			,@approval_code						nvarchar(50)
			,@reff_dimension_code				nvarchar(50)
			,@reff_dimension_name				nvarchar(250)
			,@dimension_code					nvarchar(50)
			,@table_name						nvarchar(50)
			,@primary_column					nvarchar(50)
			,@dim_value							nvarchar(50)
			,@sell_amount						decimal(18,2)
			,@sell_code							nvarchar(50)
			,@sell_req_date						datetime
			,@url_path							nvarchar(250)
			,@approval_path						nvarchar(4000)
			,@nbv_sale							decimal(18,2)
			,@nbv_asset							decimal(18,2)
			,@is_sold							nvarchar(1)
			,@faktur_no							nvarchar(50)
			,@total_ppn							decimal(18, 2) 
			,@faktur_date						DATETIME
			,@ppn_amount						decimal(18,2);

	begin try -- 
	if exists(select 1 from dbo.sale_detail where id = @p_id and sale_detail_status = 'HOLD')
	begin
			

			select	@branch_code = sl.branch_code
					,@branch_name = sl.branch_name
					,@req_date = sd.sale_date
					,@sell_amount = sd.sold_amount
					,@sell_code = sl.code
					,@sell_req_date = sl.sale_date
					,@asset_code = sd.asset_code
					,@item_name = ass.item_name
					,@nbv_sale = sd.net_book_value
					,@nbv_asset = ass.net_book_value_comm
					,@is_sold = sd.is_sold
					,@faktur_no = sd.faktur_no
					,@total_ppn = sd.total_ppn_amount
					,@faktur_date	= sd.faktur_date
					,@ppn_amount	= slf.ppn_amount
			from	dbo.sale_detail sd
					left join dbo.sale sl on (sl.code		  = sd.sale_code)
					left join dbo.sale_detail_fee slf on (slf.sale_detail_id = sd.id)
					left join dbo.asset ass on (sd.asset_code = ass.code)
			where	sd.id = @p_id ;

			if @nbv_asset <> @nbv_sale
			begin
				set @msg = 'Please save first.';
				raiserror(@msg ,16,-1);
			end

			--push ke approval
			--set @interface_remarks = 'Approval Sell For ' + @asset_code + ' - ' + @item_name ;
			--set @req_date = dbo.xfn_get_system_date() ;

			--select	@reff_approval_category_code = reff_approval_category_code
			--from	dbo.master_approval
			--where	code						 = 'SELL' ;

			--exec dbo.xsp_ams_interface_approval_request_insert @p_code						= @request_code output
			--												   ,@p_branch_code				= @branch_code
			--													,@p_branch_name				= @branch_name
			--													,@p_request_status			= N'HOLD'
			--													,@p_request_date			= @sell_req_date
			--													,@p_request_amount			= @sell_amount
			--													,@p_request_remarks			= @interface_remarks
			--													,@p_reff_module_code		= N'IFINAMS'
			--													,@p_reff_no					= @sell_code
			--													,@p_reff_name				= N'SELL APPROVAL'
			--													,@p_paths					= N'https://www.ims-tec.com'
			--													,@p_approval_category_code	= @reff_approval_category_code
			--													,@p_approval_status			= N'HOLD'
			--													,@p_expired_date			= @req_date
			--													,@p_cre_date				= @p_mod_date
			--													,@p_cre_by					= @p_mod_by
			--													,@p_cre_ip_address			= @p_mod_ip_address
			--													,@p_mod_date				= @p_mod_date
			--													,@p_mod_by					= @p_mod_by
			--													,@p_mod_ip_address			= @p_mod_ip_address


			--declare curr_appv cursor fast_forward read_only for
			--select 	approval_code
			--		,reff_dimension_code
			--		,reff_dimension_name
			--		,dimension_code
			--from	dbo.master_approval_dimension
			--where	approval_code = 'SELL'
			
			--open curr_appv
			
			--fetch next from curr_appv 
			--into @approval_code
			--	,@reff_dimension_code
			--	,@reff_dimension_name
			--	,@dimension_code
			
			--while @@fetch_status = 0
			--begin
			--	select	@table_name					 = table_name
			--			,@primary_column			 = primary_column
			--	from	dbo.sys_dimension
			--	where	code						 = @dimension_code

			--	exec dbo.xsp_get_table_value_by_dimension @p_dim_code		= @dimension_code
			--												,@p_reff_code	= @sell_code
			--												,@p_reff_table	= 'SALE'
			--												,@p_output		= @dim_value output ;
				
			--	exec dbo.xsp_ams_interface_approval_request_dimension_insert @p_id					= 0
			--																 ,@p_request_code		= @request_code
			--																 ,@p_dimension_code		= @reff_dimension_code
			--																 ,@p_dimension_value	= @dim_value
			--																 ,@p_cre_date			= @p_mod_date
			--																 ,@p_cre_by				= @p_mod_by
			--																 ,@p_cre_ip_address		= @p_mod_ip_address
			--																 ,@p_mod_date			= @p_mod_date
			--																 ,@p_mod_by				= @p_mod_by
			--																 ,@p_mod_ip_address		= @p_mod_ip_address ;
				
			
			--    fetch next from curr_appv 
			--	into @approval_code
			--		,@reff_dimension_code
			--		,@reff_dimension_name
			--		,@dimension_code
			--end
			
			--close curr_appv
			--deallocate curr_appv

			--Raffy 17/12/2023 Validasi jika ppn amount lebih dari 0 maka faktur no harus diisi
			if (@ppn_amount > 0) AND (@is_sold = '1') AND isnull(@faktur_no,'') = ''
			begin
				set @msg = 'Please Input Faktur No!' ;
				raiserror(@msg, 16, -1) ;
			end

			if  isnull(@faktur_no,'') <> '' AND (len(@faktur_no) != 16)
			begin
				set	@msg = 'Faktur Number Must be 16 Digits.'
				raiserror(@msg, 16, -1) ;
			end

			if (@ppn_amount > 0) AND (@is_sold = '1') AND ISNULL(@faktur_date, '') = ''
			begin
				set @msg = 'Please Input Faktur Date!' ;
				raiserror(@msg, 16, -1) ;
			END

			update	dbo.sale_detail
			set		sale_detail_status	= 'ON PROCESS'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	id					= @p_id ;
	end
	else
	begin
		set @msg = 'Data already proceed.';
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
