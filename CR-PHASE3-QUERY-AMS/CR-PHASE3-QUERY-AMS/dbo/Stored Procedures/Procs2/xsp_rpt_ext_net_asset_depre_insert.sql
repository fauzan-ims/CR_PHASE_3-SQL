CREATE PROCEDURE dbo.xsp_rpt_ext_net_asset_depre_insert
as
begin
	declare @code			   nvarchar(50)
			,@year			   nvarchar(4)
			,@month			   nvarchar(2)
			,@msg			   nvarchar(max)
			--,@p_cre_date			datetime =  '2023-12-31'
			,@p_cre_date	   datetime		= DATEADD(DAY, -2, dbo.xfn_get_system_date())
			,@p_cre_by		   nvarchar(15) = N'JOB'
			,@p_cre_ip_address nvarchar(15) = N'JOB'
			,@periode		   nvarchar(6) ;

	if (@p_cre_date < eomonth(@p_cre_date)) -- (+) Ari 2024-02-05 ket : get last eom
	begin
		set @p_cre_date = dateadd(month, -1, @p_cre_date) ;
		set @p_cre_date = eomonth(@p_cre_date) ;
	end ;

	begin try
		set @year = year(@p_cre_date) ;
		set @month = month(@p_cre_date) ;
		set @periode = cast(@year as nvarchar(4)) + cast(@month as nvarchar(2)) ;

		delete	dbo.rpt_ext_net_asset_depre ;

		insert into rpt_ext_net_asset_depre
		(
			eom
			,assetno
			,amt
			,assetconditionid
			,assettypeid
			,assetbrandid
			,assetbrandtypeid
			,assetbrandtypename
			,assetmodelid
			-- raffy (+) 2025/08/06 imon 2508000017
			,fa_code
			,registration_class_type
			,asset_name
			--						
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	eomonth(@p_cre_date)
				,ast.code
				,ast.TOTAL_DEPRE_COMM--xschedule.total_depre
				,ast.condition
				,case ast.TYPE_CODE
					 when 'VHCL' then '1'
					 when 'HE' then '2'
					 else 'NA'
				 end	-- 1 vehicle, 2 he , else NA
				,av.MERK_CODE--ast.merk_code
				,av.TYPE_ITEM_CODE--ast.type_code_asset
				,av.TYPE_ITEM_NAME--ast.type_name_asset
				,right(av.type_item_code, len(av.type_item_code) - 1 - len(av.model_code))
						--
						--,@p_cre_date
				
				,ast.code
				,mi.registration_class_type
				,ast.item_name
				,dbo.xfn_get_system_date()
				,@p_cre_by
				,@p_cre_ip_address
						--,@p_cre_date
				,dbo.xfn_get_system_date()
				,@p_cre_by
				,@p_cre_ip_address
		from	dbo.XXX_ASSET_20250831AFTEREOM						 ast
				inner join dbo.asset_vehicle av on av.asset_code = ast.code
				outer apply
				(
					select	top 1 mi.registration_class_type 
					from	ifinbam.dbo.master_item mi 
					where	mi.code = av.type_item_code or mi.type_code = av.type_item_code
				)mi
				outer apply
		(
			select	sum(adc.depreciation_amount) total_depre
			from	dbo.asset_depreciation_schedule_commercial adc
			where	adc.asset_code			  = ast.code
					and adc.DEPRECIATION_DATE <= @p_cre_date
		)									 xschedule
		where	ASSET_FROM								 = 'BUY'
				and isnull(IS_PERMIT_TO_SELL, '0')		 = '0'
				and STATUS in
		(
			'STOCK', 'REPLACEMENT'
		)
				and convert(char(6), PURCHASE_DATE, 112) <= convert(char(6), @p_cre_date, 112) 
				AND convert(char(6), ast.CRE_DATE, 112) <= convert(char(6), @p_cre_date, 112)
		
		--ast.PURCHASE_DATE						   <= @p_cre_date
		--		and
		--		(
		--			ast.SALE_DATE is null
		--			or	ast.SALE_DATE					   > @p_cre_date
		--		)
		--		and
		--		(
		--			ast.DISPOSAL_DATE is null
		--			or	ast.DISPOSAL_DATE				   > @p_cre_date
		--		)
		--		and ast.STATUS not in
		--(
		--	'CANCEL', 'hold'
		--)
		--		and
		--		(
		--			ast.PERMIT_SELL_DATE is null
		--			or	cast(ast.PERMIT_SELL_DATE as date) > @p_cre_date
		--		)
		----		and ast.CODE not in
		----(
		----	'2008.AST.2401.00029', '2008.AST.2401.00032', '2008.AST.2401.00033'
		----) ;
	

	-- (+) Ari 2024-02-05 ket : add log
	BEGIN
    
		DELETE dbo.rpt_ext_net_asset_depre_log WHERE eom = @p_cre_date
        
		insert into dbo.rpt_ext_net_asset_depre_log
		(
			eom
			,assetno
			,amt
			,assetconditionid
			,assettypeid
			,assetbrandid
			,assetbrandtypeid
			,assetbrandtypename
			,assetmodelid
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	eom
			   ,assetno
			   ,amt
			   ,assetconditionid
			   ,assettypeid
			   ,assetbrandid
			   ,assetbrandtypeid
			   ,assetbrandtypename
			   ,assetmodelid
			   ,cre_date
			   ,cre_by
			   ,cre_ip_address
			   ,mod_date
			   ,mod_by
			   ,mod_ip_address 
		from	rpt_ext_net_asset_depre
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
			set @msg = N'v' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%v;%'
				   or	error_message() like '%e;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'e;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_rpt_ext_net_asset_depre_insert] TO [ims-raffyanda]
    AS [dbo];

