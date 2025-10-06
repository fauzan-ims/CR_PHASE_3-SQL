create procedure dbo.xsp_manual_upload_validation	
(
	@p_primary_key_value		nvarchar(50)
	,@p_upload_table_code		nvarchar(50)
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
			,@tabel_name			nvarchar(250)
			,@sp_name				nvarchar(250)
			----
			,@select_value			nvarchar(4000)
			,@sqlCommand			nvarchar(4000)

	select	@tabel_name = tabel_name
	from	dbo.master_upload_table
	where	code = @p_upload_table_code ;
	
	select top 1
			@primary_key_column = column_name
	from	information_schema.key_column_usage
	where	table_name = upper(@tabel_name)
			and constraint_name like 'PK%' ;

	 -- saat upload cleanup error lognya dulu
	exec ('delete dbo.UPLOAD_ERROR_LOG
	where TABEL_NAME	= '''+ @tabel_name +'''
	and CRE_BY			= ''' +@p_cre_by+'''
	and primary_column_name = ''' + @p_primary_key_value + '''')

	-- loop semua kolom yang memiliki kontrol validasi
	declare curr_validate_agreementmain cursor fast_forward read_only for 
	
		select	mutc.column_name 
				,muv.sp_name
				,mutc.order_key
		from	dbo.master_upload_tabel_column mutc
				inner join dbo.master_upload_tabel_validation mutv		on (mutv.upload_tabel_column_code = mutc.code)
				inner join dbo.master_upload_validation muv				on (muv.code = mutv.upload_validation_code)
		where	mutc.upload_tabel_code = @p_upload_table_code
	
	open curr_validate_agreementmain
	
	fetch next from curr_validate_agreementmain into 
		 @column_name
		,@sp_name
		,@order_key
	
	WHILE @@FETCH_STATUS = 0
	BEGIN

		-- ambil value yang di upload, sesuai kolom yang sedang di check
		SET @sqlCommand = 'select @data = ' + @order_key + '
							from  CORE_UPLOAD_GENERIC 
							where TABLE_NAME = @tabel_name 
							and PRIMARY_KEY = @pk'

		EXEC	sp_executesql @sqlCommand
				, N'@tabel_name NVARCHAR(250), @pk NVARCHAR(100), @data NVARCHAR(100) OUTPUT'
				,@tabel_name = @tabel_name
				,@pk = @p_primary_key_value
				,@data = @select_value output

		-- exec sp validation. sp ini jika error akan insert ke error log
		exec @sp_name @p_tabel_name = @tabel_name
					  ,@p_column_name = @column_name
					  ,@p_value_check = @select_value
					  ,@p_primary_key = @p_primary_key_value
					  --
					  ,@p_cre_date = @p_cre_date
					  ,@p_cre_by = @p_cre_by
					  ,@p_cre_ip_address = @p_cre_ip_address
					  ,@p_mod_date = @p_mod_date
					  ,@p_mod_by = @p_mod_by
					  ,@p_mod_ip_address = @p_mod_ip_address ;

		   fetch next from curr_validate_agreementmain into 
			 @column_name
			,@sp_name
			,@order_key
	end
	
	close curr_validate_agreementmain
	deallocate curr_validate_agreementmain
end

