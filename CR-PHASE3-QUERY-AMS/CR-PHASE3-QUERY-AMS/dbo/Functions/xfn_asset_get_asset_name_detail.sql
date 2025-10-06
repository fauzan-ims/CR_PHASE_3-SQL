CREATE FUNCTION dbo.xfn_asset_get_asset_name_detail 
(
	@p_asset_code nvarchar(50)
)
returns nvarchar(4000)
as
-- untuk mendapatkan informasi asset dan detail assetnya
begin
	declare  @asset_name			nvarchar(4000)
			 ,@asset_type			nvarchar(50)

	select	@asset_type = type_code
	from	dbo.asset
	where	code = @p_asset_code

	if(@asset_type = 'VHCL')
	begin
		select  @asset_name = item_name  + ' ' + '( Plat No : ' + isnull(av.PLAT_NO,'-') + ',  '  
				+ 'Chasis : ' + isnull(av.chassis_no,'-') + ', ' + ' Type : ' + isnull(av.type_item_name,'-')  + ', ' + ' Engine No : ' + isnull(av.engine_no,'-') +  ' )'
		from	dbo.asset ass
		inner join asset_vehicle av on (av.asset_code = ass.code)
		where	ass.code = @p_asset_code
	end
	if (@asset_type = 'HE')
	begin
		select	@asset_name = ass.item_name + ' ' + '( Serial No : ' + isnull(ah.serial_no, '-') + ', '
				+ 'Chasis : ' + isnull(ah.chassis_no, '-') + ', ' + ' Type : ' + isnull(ah.type_item_name, '-') + ', ' + 'Engine No : ' + isnull(ah.engine_no, '-') + ' )'
		from	dbo.asset ass
				inner join dbo.asset_he ah on (ah.asset_code = ass.code)
		where	ass.code = @p_asset_code
	end
	if (@asset_type = 'MCHN')
	begin
		select	@asset_name = ass.item_name + ' ' + '( Invoice No : ' + isnull(mh.invoice_no, '-') + ', '
				+ 'Chasis : ' + isnull(mh.chassis_no, '-') + ', ' + ' Type : ' + isnull(mh.type_item_name, '-') + ', ' + 'Engine No : ' + isnull(mh.engine_no, '-') + ' )'
		from	dbo.asset ass
				inner join dbo.asset_machine mh on (mh.asset_code = ass.code)
		where	ass.code = @p_asset_code
	end
	if (@asset_type = 'ELCT')
	begin
		select	@asset_name = ass.item_name + ' ' + '( Serial No : ' + isnull(ae.serial_no, '-') + ', '
				+ 'Processor : ' + isnull(ae.processor, '-') + ', ' + ' Type : ' + isnull(ae.type_item_name, '-') + ', ' + 'IMEI : ' + isnull(ae.imei, '-') + ' )'
		from	dbo.asset ass
				inner join dbo.asset_electronic ae on (ae.asset_code = ass.code)
		where	ass.code = @p_asset_code
	end


	--if(@asset_type = 'VHCL')
	--begin
	--	select	 @plat_no	= plat_no
	--			,@chasis_no	= chassis_no
	--			,@merk		= merk_name
	--	from	dbo.asset_vehicle
	--	where	asset_code = @p_asset_code
		
	--end
	return @asset_name

end ;

