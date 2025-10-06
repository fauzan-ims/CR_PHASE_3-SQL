create procedure dbo.xsp_get_sqlcommand_by_asset
(
	@p_sqlcommand				nvarchar(max) output	
	--
	,@p_column_name				nvarchar(50)	
	,@p_primary_key_value		nvarchar(50)	
	,@p_asset_type				nvarchar(10)
)
as
begin
   
	if (@p_asset_type = 'ELCT')
	begin
		
		set @p_sqlcommand = 'select @data = ' + @p_column_name + '
							from	dbo.asset_electronic_upload aeu
							left join dbo.asset_upload au on (au.upload_no = aeu.upload_no) 
							where au.upload_no = ''' + @p_primary_key_value + ''''
	end
	else if (@p_asset_type = 'FNTR')
	begin
		
		set @p_sqlcommand = 'select @data = ' + @p_column_name + '
							from	dbo.asset_furniture_upload afu
							left join dbo.asset_upload au on (au.upload_no = afu.upload_no) 
							where au.upload_no = ''' + @p_primary_key_value + ''''

	end
	else if (@p_asset_type = 'MCHN')
	begin
		
		set @p_sqlcommand = 'select @data = ' + @p_column_name + '
							from	dbo.asset_machine_upload amu
							left join dbo.asset_upload au on (au.upload_no = amu.upload_no) 
							where au.upload_no = ''' + @p_primary_key_value + ''''

	end
	else if (@p_asset_type = 'PRTY')
	begin
		
		set @p_sqlcommand = 'select @data = ' + @p_column_name + '
							from	dbo.asset_property_upload apu
							left join dbo.asset_upload au on (au.upload_no = apu.upload_no) 
							where au.upload_no = ''' + @p_primary_key_value + ''''

	end
	else if (@p_asset_type = 'VHCL')
	begin
		
		set @p_sqlcommand = 'select @data = ' + @p_column_name + '
							from	dbo.asset_vehicle_upload avu
							left join dbo.asset_upload au on (au.upload_no = avu.upload_no) 
							where au.upload_no = ''' + @p_primary_key_value + ''''

	end
	else if (@p_asset_type = 'OTHR')
	begin

		set @p_sqlcommand = 'select @data = ' + @p_column_name + '
							from	dbo.asset_other_upload aou
							left join dbo.asset_upload au on (au.upload_no = aou.upload_no) 
							where au.upload_no = ''' + @p_primary_key_value + ''''

	end

end
