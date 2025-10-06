CREATE PROCEDURE dbo.xsp_manual_upload_validation	
(
	@p_primary_key_value		nvarchar(50)
	,@p_table_name				nvarchar(50)
	,@p_asset_type				nvarchar(10)
	 --
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)

)
as
begin
	
	declare  @column_name			nvarchar(50)
			,@order_key				nvarchar(10)
			,@primary_key_column	nvarchar(50)
			--,@tabel_name			nvarchar(250)
			,@sp_name				nvarchar(250)
			,@max_length			int
            ,@data_type				nvarchar(10)
			,@date_check			int
			----
			,@select_value			nvarchar(4000)
			,@sqlcommand			nvarchar(4000)
			,@error_msg				nvarchar(4000)
			,@query					nvarchar(max)

	--select	@tabel_name = tabel_name
	--from	dbo.master_upload_table
	--where	code = @p_upload_table_code ;
	
	--select top 1
	--		@primary_key_column = column_name
	--from	information_schema.key_column_usage
	--where	table_name = upper(@tabel_name)
	--		and constraint_name like 'PK%' ;

	 -- saat upload cleanup error lognya dulu
	--exec ('delete dbo.UPLOAD_ERROR_LOG
	--where TABEL_NAME	= '''+ @tabel_name +'''
	--and CRE_BY			= ''' +@p_cre_by+'''
	--and primary_column_name = ''' + @p_primary_key_value + '''')


	--delete	dbo.upload_error_log
	--where	upload_no = @p_primary_key_value	
	
	-- loop semua kolom yang memiliki kontrol validasi

	set dateformat dmy;

	declare curr_upload_validation cursor fast_forward read_only FOR
    
	select	mutc.column_name 
			,muv.sp_name
			--,mutc.order_key
			,mutc.max_length
			,mutc.data_type
	from	dbo.master_upload_table_column mutc
			left join dbo.master_upload_table_validation mutv		on (mutv.upload_table_column_code = mutc.code)
			left join dbo.master_upload_validation muv				on (muv.code = mutv.upload_validation_code)
			left join dbo.master_upload_table mut					on (mut.code = mutc.upload_table_code)
	where	mut.table_name = @p_table_name
	
	open curr_upload_validation

	fetch next from curr_upload_validation into 
		 @column_name
		,@sp_name
		--,@order_key
		,@max_length
		,@data_type
	
	WHILE @@FETCH_STATUS = 0
	begin

		-- ambil value yang di upload, sesuai kolom yang sedang di check
		exec	dbo.xsp_get_sqlcommand_by_asset 
				@p_sqlcommand			= @sqlCommand output	
				,@p_column_name			= @column_name					
				,@p_primary_key_value	= @p_primary_key_value
				,@p_asset_type			= @p_asset_type

		--SET @sqlCommand = 'select @data = ' + @column_name + '
		--					from	dbo.asset_machine_upload amu
		--					left join dbo.asset_upload au on (au.upload_no = amu.upload_no) 
		--					where au.upload_no = ''' + @p_primary_key_value + ''''
		
		EXEC	sp_executesql @sqlCommand
				, N'@data NVARCHAR(100) OUTPUT'
				--,@tabel_name = @p_table_name
				--,@pk = @p_primary_key_value
				,@data = @select_value output
			

			if(len(@select_value) > @max_length AND @max_length <> 0)
			begin

				set @error_msg = @column_name + ' cannot greater than max length ' + convert(nvarchar(250),@max_length)
				
				exec	dbo.xsp_upload_error_log_insert 
						@p_primary_key_value
						,@column_name
						,@error_msg
						--
						,@p_cre_date					
						,@p_cre_by						
						,@p_cre_ip_address				
						,@p_mod_date					
						,@p_mod_by						
						,@p_mod_ip_address

			end
			else
			BEGIN
				set @error_msg = ''
		
				IF (@data_type = 'decimal')-- jika decimal
				begin
				
					--(+) Rinda  23/03/2021  Notes :	kondisi bbrpa excel kadang titik nya koma
					set @select_value = replace(@select_value,',','.') 
				
					set @query = 'update dbo.asset_upload_temp set ' +@order_key +' ='''+ @select_value +''' '+
									' where table_name ='''+ @p_table_name +''' and primary_key = '''+ @p_primary_key_value +''''  
							
					exec (@query)
					
					if(isnumeric(@select_value) = 0 OR charindex(',',@select_value) > 0)
					BEGIN
                    
						SET @error_msg = @column_name + ' input must be decimal, format delimiter with dot (.)'

						exec	dbo.xsp_upload_error_log_insert 
								@p_primary_key_value
								,@column_name
								,@error_msg
								--
								,@p_cre_date					
								,@p_cre_by						
								,@p_cre_ip_address				
								,@p_mod_date					
								,@p_mod_by						
								,@p_mod_ip_address

                    end

				end
                else if (@data_type = 'datetime') -- jika date
                BEGIN
				
					set @date_check = isdate(@select_value);

					IF(@date_check = 0 and @select_value <> '')
					BEGIN
				
						set @error_msg = @column_name + ' input must be date, format dd/mm/yyyy'

						exec	dbo.xsp_upload_error_log_insert 
								@p_primary_key_value
								,@column_name
								,@error_msg
								--
								,@p_cre_date					
								,@p_cre_by						
								,@p_cre_ip_address				
								,@p_mod_date					
								,@p_mod_by						
								,@p_mod_ip_address
					END

					

				end
                else if (@data_type = 'int') -- jika int
                begin

					if(isnumeric(@select_value) = 0)
					begin
						
						set @error_msg = @column_name + ' input must be integer'

						exec	dbo.xsp_upload_error_log_insert 
								@p_primary_key_value
								,@column_name
								,@error_msg
								--
								,@p_cre_date					
								,@p_cre_by						
								,@p_cre_ip_address				
								,@p_mod_date					
								,@p_mod_by						
								,@p_mod_ip_address

					end
					
                END
			
				if(isnull(@sp_name,'') <> '' and @error_msg = '')
				begin
					
					-- exec sp validation. sp ini jika error akan insert ke error log
					exec @sp_name	--@p_tabel_name			= @p_table_name
									@p_column_name			= @column_name
									,@p_value_check			= @select_value
									,@p_primary_key			= @p_primary_key_value
									--
									,@p_cre_date			= @p_cre_date
									,@p_cre_by				= @p_cre_by
									,@p_cre_ip_address		= @p_cre_ip_address
									,@p_mod_date			= @p_mod_date
									,@p_mod_by				= @p_mod_by
									,@p_mod_ip_address		= @p_mod_ip_address ;

				end
				
			END
       

		fetch next from curr_upload_validation into 
						 @column_name
						,@sp_name
						--,@order_key
						,@max_length
						,@data_type
	end
	
	close curr_upload_validation
	deallocate curr_upload_validation
end
