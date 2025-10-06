CREATE PROCEDURE dbo.xsp_monitoring_maintenance_proceed
(
	@p_code			   NVARCHAR(50)
	--
	,@p_mod_date			DATETIME
	,@p_mod_by				NVARCHAR(15)
	,@p_mod_ip_address		NVARCHAR(15)
)
AS
BEGIN
	declare @msg							nvarchar(max) 
			,@insurance_code				nvarchar(50)
			,@fa_code						nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@register_date					datetime
			,@register_code					nvarchar(50)
			,@currency_code					nvarchar(3) = ''
			,@buildyear						nvarchar(4)
			,@collateral_type				nvarchar(50)
			,@insurate_name					nvarchar(250)						
			,@insurate_code					nvarchar(50)
			,@insurate_type					nvarchar(4)
			,@depreciation_code				nvarchar(50)
			,@collateral_category_code		nvarchar(250)	
			,@occupation_code				nvarchar(50)		
			,@region_code					nvarchar(50)
			,@from_date						datetime
			,@insuredqq						nvarchar(4)
			,@code							nvarchar(50)
			,@maintenance_date				datetime
			,@service_code					nvarchar(50)
			,@service_name					nvarchar(250)
			,@id							bigint
			,@service_type					nvarchar(50)
			,@date							datetime		= dbo.xfn_get_system_date()
			,@plat_no						nvarchar(50)
begin try

		select	@branch_code		= ass.branch_code
				,@branch_name		= ass.branch_name
				,@maintenance_date	= ams.maintenance_date
		from dbo.asset ass
		left join dbo.asset_maintenance_schedule ams on (ams.asset_code = ass.code)
		where ass.code = @p_code


		select @plat_no = plat_no 
		from dbo.asset_vehicle
		where asset_code = @p_code

		--new 03/07/2025
		if exists
		(
			select	1
			from	dbo.sale				   a
					inner join dbo.sale_detail b on b.sale_code = a.code
			where	a.status not in
		(
			'CANCEL', 'REJECT'
		)
		AND b.ASSET_CODE = @p_code
		)
		begin
			set @msg = N'Asset Is In Sales Request Process, For Plat No: ' + @plat_no  ;

			raiserror(@msg, 16, -1) ;
		end ;

		
		exec dbo.xsp_maintenance_insert @p_code							= @code output
										,@p_company_code				= 'DSF'
										,@p_asset_code					= @p_code
										,@p_transaction_date			= @p_mod_date
										,@p_transaction_amount			= 0
										,@p_branch_code					= @branch_code
										,@p_branch_name					= @branch_name
										,@p_requestor_code				= ''
										,@p_requestor_name				= ''
										,@p_division_code				= ''
										,@p_division_name				= ''
										,@p_department_code				= ''
										,@p_department_name				= ''
										,@p_status						= 'HOLD'
										,@p_maintenance_by				= 'INT'
										,@p_vendor_code					= ''
										,@p_vendor_name					= ''
										,@p_remark						= ''
										,@p_actual_km					= 0
										,@p_work_date					= @date
										,@p_service_type				= 'ROUTINE'
										,@p_hour_meter					= 0
										,@p_vendor_city_name			= ''
										,@p_vendor_province_name		= ''
										,@p_vendor_address				= ''
										,@p_vendor_phone				= ''
										,@p_vendor_bank_name			= ''
										,@p_vendor_bank_account_no		= ''
										,@p_vendor_bank_account_name	= ''
										,@p_free_service				= '0'
										,@p_is_request_replacement		= '0'
										,@p_cre_date					= @p_mod_date		
										,@p_cre_by						= @p_mod_by			
										,@p_cre_ip_address				= @p_mod_ip_address
										,@p_mod_date					= @p_mod_date		
										,@p_mod_by						= @p_mod_by			
										,@p_mod_ip_address				= @p_mod_ip_address


		--begin
		--	declare curr_maintenance cursor fast_forward read_only for

		--	select	distinct
		--			service_code
		--			,service_name
		--			,id
		--			,service_type
		--	from	dbo.asset_maintenance_schedule
		--	where	id in
		--			(
		--				select		max(id)
		--				from		dbo.asset_maintenance_schedule
		--				where		asset_code						= @p_code
		--							and isnull(reff_trx_no,'')		= ''
		--							and maintenance_status			= 'SCHEDULE PENDING'
		--							and
		--							(
		--								maintenance_date   <= @p_mod_date
		--								--or	miles		   <= @p_actual_km
		--								--or	hour		   <= @p_hour_meter
		--							)
		--				group by	service_code,service_name
		--			) ;
			
		--	open curr_maintenance
			
		--	fetch next from curr_maintenance 
		--	into @service_code
		--		,@service_name
		--		,@id
		--		,@service_type
			
		--	while @@fetch_status = 0
		--	begin
		--	    exec dbo.xsp_maintenance_detail_insert @p_id								= 0
		--												,@p_maintenance_code				= @code
		--												,@p_service_code					= @service_code
		--												,@p_service_name					= @service_name
		--												,@p_file_name						= null
		--												,@p_path							= null
		--												,@p_quantity						= 0
		--												,@p_pph_amount						= 0
		--												,@p_ppn_amount						= 0
		--												,@p_service_amount					= 0
		--												,@p_service_type					= @service_type
		--												,@p_asset_maintenance_schedule_id	= @id
		--												,@p_cre_date						= @p_mod_date		
		--												,@p_cre_by							= @p_mod_by			
		--												,@p_cre_ip_address					= @p_mod_ip_address	
		--												,@p_mod_date						= @p_mod_date
		--												,@p_mod_by							= @p_mod_by
		--												,@p_mod_ip_address					= @p_mod_ip_address
			
		--	    fetch next from curr_maintenance 
		--		into @service_code
		--			,@service_name
		--			,@id
		--			,@service_type
		--	end
			
		--	close curr_maintenance
		--	deallocate curr_maintenance
		--end

		
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
