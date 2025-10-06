
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_job_interface_in_ifinams_generate_depre]
as
declare @msg								nvarchar(max)
		,@row_to_process					int
		,@last_id_from_job					bigint
		,@code_sys_job						nvarchar(50)
		,@is_active							nvarchar(1)
		,@mod_date							datetime		= getdate()
		,@mod_by							nvarchar(15) = 'job'
		,@mod_ip_address					nvarchar(15) = '127.0.0.1'
		,@current_mod_date					datetime
		--
		,@asset_code						nvarchar(50)
		,@is_valid							int
        ,@unit_from							nvarchar(15)
		,@company_code						nvarchar(50)
		,@category_code						nvarchar(50)
		,@purchase_price					decimal(18,2)
		,@depre_date_comm					datetime
		,@depre_date_fiscal					datetime
        ,@original_price					decimal(18,2)
		,@depre_cat_comm_code				nvarchar(50)
		,@depre_cat_fiscal_code				nvarchar(50)
		,@rate								decimal(9,6)
		,@final_date						datetime

select	@code_sys_job = code
		,@row_to_process = row_to_process
		,@last_id_from_job = last_id
		,@is_active = is_active
from	dbo.sys_job_tasklist
where	sp_name = 'xsp_job_interface_in_ifinams_generate_depre' ; -- sesuai dengan nama sp ini

/*
	CR Priority sepria 09092025: job ini untuk otomatis generate depre asset jika dari procurement sudah final post + semua invoice dari item sudah terbayar (coa asset sudah ada)
*/
if (@is_active = '1')
begin
	--get approval request
	declare curr_asset cursor for
	select		ast.code
				,ast.asset_from
				,iast.original_price
				,iast.purchase_price
	from		dbo.asset  ast
				inner join ifinproc.dbo.eproc_interface_asset iast on ast.code = iast.code
	where		isnull(is_final_all,'0') = '1' and isnull(ast.is_final_grn,'0') = '0'
	and			ast.code not in (select asset_code from dbo.asset_depreciation_schedule_commercial)
	order by	ast.code asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_asset ;

	fetch next from curr_asset
	into	@asset_code
			,@unit_from
			,@original_price
			,@purchase_price

	while @@fetch_status = 0
	begin
		begin try
			begin transaction ;

			-- Jika asset yang tidak RENT yang ter depre
			if(@unit_from = 'BUY')
			begin

				set @final_date = dbo.fn_get_system_date()

				select	@company_code			= dor.company_code
						,@category_code			= dor.category_code
				from	ifinams.dbo.asset dor
				where	dor.code = @asset_code ;

				select	@depre_cat_comm_code			= mc.depre_cat_commercial_code
						,@depre_cat_fiscal_code			= mc.depre_cat_fiscal_code
						,@rate							= 100 - (mdcc.usefull * mdcc.rate)
				from	ifinams.dbo.master_category mc
						inner join ifinams.dbo.master_depre_category_commercial mdcc on mc.depre_cat_commercial_code = mdcc.code
				where	mc.code = @category_code


				update	ifinams.dbo.asset
				set		original_price		= @original_price
						,purchase_price		= @purchase_price
						,residual_value		= cast(@rate / 100 * @purchase_price as bigint)
						,is_final_grn		= '1'
						,final_date			= @final_date
						,mod_by				= @mod_by
						,mod_date			= @mod_date
						,mod_ip_address		= @mod_ip_address
				where	code = @asset_code ;

				-- Arga 19-Oct-2022 ket : additional control for WOM (+)
				select @is_valid = dbo.xfn_depre_threshold_validation(@company_code, @category_code, @purchase_price)

				if @is_valid = 1
				begin
					exec dbo.xsp_asset_depreciation_schedule_commercial_generate @p_code				= @asset_code
																					,@p_mod_date		 = @mod_date	  
																					,@p_mod_by			 = @mod_by		  
																					,@p_mod_ip_address	 = @mod_ip_address

					exec dbo.xsp_asset_depreciation_schedule_fiscal_generate @p_code				= @asset_code
																				,@p_mod_date		 = @mod_date	  
																				,@p_mod_by			 = @mod_by		
																				,@p_mod_ip_address	 = @mod_ip_address

					select @depre_date_comm =  min(depreciation_date) 
					from dbo.asset_depreciation_schedule_commercial
					where asset_code = @asset_code

					select @depre_date_fiscal =  min(depreciation_date) 
					from dbo.asset_depreciation_schedule_fiscal
					where asset_code = @asset_code

					if(@depre_date_comm <> @depre_date_fiscal)
					begin
						set @msg = 'The start date of depreciation between Commercial and Fiscal must be the same';
						raiserror(@msg ,16,-1);	
					end
				end
			end

			commit transaction ;

		end try
		begin catch
			rollback transaction ;
		end catch ;

		fetch next from curr_asset
		into	@asset_code
				,@unit_from
				,@original_price
				,@purchase_price
	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_asset') >= -1
		begin
			if cursor_status('global', 'curr_asset') > -1
			begin
				close curr_asset ;
			end ;

			deallocate curr_asset ;
		end ;
	end ;
end ;
