CREATE PROCEDURE dbo.xsp_generate_custom_report
(
	@p_custom_report_code	nvarchar(50)
)
as
begin
	declare @query					nvarchar(4000)
				,@condition				nvarchar(4000) = ''
				,@view_name				nvarchar(250)
				,@column_name			nvarchar(250)
				,@all_column_name		nvarchar(4000) = ''
				,@ctr					int = 0
				,@header_name			nvarchar(250)
				,@logical_operator		nvarchar(20)
				,@comparison_operator	nvarchar(20)
				,@start_value			nvarchar(4000)
				,@end_value				nvarchar(4000)
				,@asset_type			nvarchar(25)
				,@transaction_type		nvarchar(25)
	
	select	@asset_type = asset_type
				,@transaction_type = mcr.transaction_type
		--@view_name = mmv.view_name
		from	dbo.master_custom_report mcr
				left join dbo.master_mapping_value mmv on mmv.transaction_type = mcr.transaction_type
		where	mcr.code = @p_custom_report_code ;
	
	if (@transaction_type = 'ASST')
		begin
		if (@asset_type = 'ELCT') -- ELECTRONIC
		begin
			set @view_name = 'VASSETELECTRONIC';
		end
		else if (@asset_type = 'FNTR') -- FURNITURE
		begin
			set @view_name = 'VASSETFURNITURE';
		end
		else if (@asset_type = 'MCHN') -- MACHINE
		begin
			set @view_name = 'VASSETMACHINE';
		end
		else if (@asset_type = 'PRTY') -- PROPERTY
		begin
			set @view_name = 'VASSETPROPERTY';
		end
		else if (@asset_type = 'VHCL') -- VEHICLE
		begin
			set @view_name = 'VASSETVEHICLE';
		end
		else if (@asset_type = 'OTHR') -- OTHERS
		begin
			set @view_name = 'VASSETOTHERS';
		end
		else if (@asset_type = 'ALL') -- ALL
		begin
			set @view_name = 'VASSETALL';
		end
	end
		else
		begin
			select	@view_name = mmv.view_name
			from	dbo.master_custom_report mcr
					left join dbo.master_mapping_value mmv on mmv.transaction_type = mcr.transaction_type
			where	mcr.code= @p_custom_report_code;
		end

	declare c_custom_field cursor fast_forward read_only for
		select	column_name, header_name
		from	dbo.master_custom_report_column
		where	custom_report_code = @p_custom_report_code
		order by order_key
							
	open c_custom_field
	fetch next from c_custom_field
		into @column_name, @header_name
						
	while @@fetch_status = 0
		begin
		
			set @ctr += 1	
		
			if @ctr <> 1
				set @all_column_name += ',' + char(10)
									
			set @all_column_name += @column_name + ' as ' + '''' + @header_name + ''''
		
			fetch next from c_custom_field
			into @column_name, @header_name
								
		end
				
	close c_custom_field
	deallocate c_custom_field
	
	declare c_custom_condition cursor fast_forward read_only for
		select	logical_operator, replace(comparison_operator,'_',''), column_name, start_value, end_value
		from	dbo.master_custom_report_condition
		where	custom_report_code = @p_custom_report_code
		order by order_key
							
	open c_custom_condition
	fetch next from c_custom_condition
		into @logical_operator, @comparison_operator, @column_name, @start_value, @end_value
							
	while @@fetch_status = 0
		begin
		
			set @condition += @logical_operator + ' '
			set @condition += @column_name + ' '
			set @condition += @comparison_operator + ' '
			set @condition += isnull(@start_value,'') + ' '
			set @condition += isnull(@end_value,'') + char(10)
									
			fetch next from c_custom_condition
			into @logical_operator, @comparison_operator, @column_name, @start_value, @end_value
								
		end
						
	close c_custom_condition
	deallocate c_custom_condition
	
	set @query = 'select	' + char(10) + @all_column_name + char(10)
	set @query += 'from	' + @view_name + char(10)
	set @query += @condition
	
	exec (@query)
end
