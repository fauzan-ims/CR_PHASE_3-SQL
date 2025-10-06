-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_core_interface_upload_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_code_table nvarchar(50)
	,@p_cre_by	   nvarchar(15)
	,@p_status	   nvarchar(15)
)
as
begin
	declare @rows_count	 int = 0
			,@column1	 varchar(250)
			,@column2	 varchar(250)
			,@column3	 varchar(250)
			,@column4	 varchar(250)
			,@column5	 varchar(250)
			,@table_name varchar(250)
			,@query		 nvarchar(max) ;

	select	@table_name = tabel_name
	from	dbo.master_upload_table
	where	code = @p_code_table ;

	select	@column1 = column_name
	from	dbo.master_upload_tabel_column
	where	upload_tabel_code = @p_code_table
			and order_key	  = 'column_01' ;

	select	@column2 = column_name
	from	dbo.master_upload_tabel_column
	where	upload_tabel_codE = @p_code_table
			and order_key	  = 'column_02' ;

	select	@column3 = column_name
	from	dbo.master_upload_tabel_column
	where	upload_tabel_code = @p_code_table
			and order_key	  = 'column_03' ;

	select	@column4 = column_name
	from	dbo.master_upload_tabel_column
	where	upload_tabel_code = @p_code_table
			and order_key	  = 'column_04' ;

	select	@column5 = column_name
	from	dbo.master_upload_tabel_column
	where	upload_tabel_code = @p_code_table
			and order_key	  = 'column_05' ;

	--set @Query = 'select 
	--				COLUMN_01 AS '+ @column1 +' 
	--				,COLUMN_02 AS '+ @column2 +' 
	--				,COLUMN_03 AS '+ @column3 +' 
	--				,COLUMN_04 AS '+ @column4 +' 
	--				,COLUMN_05 AS '+ @column5 +'
	--				FROM dbo.CORE_UPLOAD_GENERIC   ' 
	--EXEC(@Query)

	-- buat tabel
	if object_id('tempdb..#Temp') is not null
		drop table #Temp ;

	create table #Temp
	(
		PRIMARY_KEY nvarchar(250)	COLLATE Latin1_General_CI_AS
	) ;

	-- tambah kolom
	select	@Query = 'ALTER TABLE #Temp add ' + COLUMN_NAME + case
																  when DATA_TYPE = 'STRING' then ' nvarchar(4000)'
																  when DATA_TYPE = 'DATE' then ' nvarchar(4000)'
																  when DATA_TYPE = 'DECIMAL' then ' nvarchar(4000)'
																  when DATA_TYPE = 'NUMBER' then ' nvarchar(4000)'
															  end
	from	dbo.MASTER_UPLOAD_TABEL_COLUMN
	where	UPLOAD_TABEL_CODE = @p_code_table
			and ORDER_KEY	  = 'column_01' ;

	exec (@Query) ;

	select	@Query = 'ALTER TABLE #Temp add ' + COLUMN_NAME + case
																  when DATA_TYPE = 'STRING' then ' nvarchar(4000)'
																  when DATA_TYPE = 'DATE' then ' nvarchar(4000)'
																  when DATA_TYPE = 'DECIMAL' then ' nvarchar(4000)'
																  when DATA_TYPE = 'NUMBER' then ' nvarchar(4000)'
															  end
	from	dbo.MASTER_UPLOAD_TABEL_COLUMN
	where	UPLOAD_TABEL_CODE = @p_code_table
			and ORDER_KEY	  = 'column_02' ;

	if (@column2 is null)
	begin
		set @Query = 'ALTER TABLE #Temp add column_02 nvarchar(4000) ' ;
	end ;

	exec (@Query) ;

	select	@Query = 'ALTER TABLE #Temp add ' + COLUMN_NAME + case
																  when DATA_TYPE = 'STRING' then ' nvarchar(4000)'
																  when DATA_TYPE = 'DATE' then ' nvarchar(4000)'
																  when DATA_TYPE = 'DECIMAL' then ' nvarchar(4000)'
																  when DATA_TYPE = 'NUMBER' then ' nvarchar(4000)'
															  end
	from	dbo.MASTER_UPLOAD_TABEL_COLUMN
	where	UPLOAD_TABEL_CODE = @p_code_table
			and ORDER_KEY	  = 'column_03' ;

	if (@column3 is null)
	begin
		set @Query = 'ALTER TABLE #Temp add column_03 nvarchar(4000) ' ;
	end ;

	exec (@Query) ;

	select	@Query = 'ALTER TABLE #Temp add ' + COLUMN_NAME + case
																  when DATA_TYPE = 'STRING' then ' nvarchar(4000)'
																  when DATA_TYPE = 'DATE' then ' nvarchar(4000)'
																  when DATA_TYPE = 'DECIMAL' then ' nvarchar(4000)'
																  when DATA_TYPE = 'NUMBER' then ' nvarchar(4000)'
															  end
	from	dbo.MASTER_UPLOAD_TABEL_COLUMN
	where	UPLOAD_TABEL_CODE = @p_code_table
			and ORDER_KEY	  = 'column_04' ;

	if (@column4 is null)
	begin
		set @Query = 'ALTER TABLE #Temp add column_04 nvarchar(4000) ' ;
	end ;

	exec (@Query) ;

	select	@Query = 'ALTER TABLE #Temp add ' + COLUMN_NAME + case
																  when DATA_TYPE = 'STRING' then ' nvarchar(4000)'
																  when DATA_TYPE = 'DATE' then ' nvarchar(4000)'
																  when DATA_TYPE = 'DECIMAL' then ' nvarchar(4000)'
																  when DATA_TYPE = 'NUMBER' then ' nvarchar(4000)'
															  end
	from	dbo.master_upload_tabel_column
	where	upload_tabel_code = @p_code_table
			and order_key	  = 'column_05' ;

	if (@column5 is null)
	begin
		set @Query = 'ALTER TABLE #Temp add column_05 nvarchar(4000) ' ;
	end ;

	exec (@Query) ;

	set @Query = 'ALTER TABLE #Temp add status nvarchar(4000) ' ;

	exec (@Query) ;

	-- query select

	---- isi data
	if (@p_sort_by = 'asc')
	begin
		insert into #temp
		select		primary_key
					,column_01
					,column_02
					,column_03
					,column_04
					,column_05
					,status
		from		dbo.core_upload_generic
		where		table_name			  = @table_name
					and cre_by			  = @p_cre_by
					and (
							case
								when STATUS = 'OK' then 'OK'
								else 'NOK'
							end			  = case @p_status
												when 'OK' then 'OK'
												when 'NOk' then 'NOk'
											end
							or	@p_status = 'ALL'
						)
					and (
							primary_key like '%' + @p_keywords + '%'
							or	column_01 like '%' + @p_keywords + '%'
							or	column_02 like '%' + @p_keywords + '%'
							or	column_03 like '%' + @p_keywords + '%'
							or	column_04 like '%' + @p_keywords + '%'
							or	column_05 like '%' + @p_keywords + '%'
							or	status	  like '%' + @p_keywords + '%'
						)
		order by	case @p_order_by
						when 1 then primary_key
						when 2 then column_01
						when 3 then column_02
						when 4 then column_03
						when 5 then column_04
						when 6 then column_05
						when 7 then status
					end asc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
	else
	begin
		insert into #temp
		select		primary_key
					,column_01
					,column_02
					,column_03
					,column_04
					,column_05
					,status
		from		dbo.core_upload_generic
		where		table_name = @table_name
					and cre_by = @p_cre_by
					and (
							case
								when STATUS = 'OK' then 'OK'
								else 'NOK'
							end			  = case @p_status
												when 'OK' then 'OK'
												when 'NOk' then 'NOk'
											end
							or	@p_status = 'ALL'
						)
					and (
							primary_key like '%' + @p_keywords + '%'
							or	column_01 like '%' + @p_keywords + '%'
							or	column_02 like '%' + @p_keywords + '%'
							or	column_03 like '%' + @p_keywords + '%'
							or	column_04 like '%' + @p_keywords + '%'
							or	column_05 like '%' + @p_keywords + '%'
							or	status	  like '%' + @p_keywords + '%'
						)
		order by	case @p_order_by
						when 1 then primary_key
						when 2 then column_01
						when 3 then column_02
						when 4 then column_03
						when 5 then column_04
						when 6 then column_05
						when 7 then status
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;

	select	@rows_count = count(1)
	from	#temp ;

	select	*
			,@rows_count as 'rowcount'
	from	#Temp ;

/*
	declare @sp_getrows_name		nvarchar(250)
			,@execute_sp_name		nvarchar(max)


	select	@sp_getrows_name	= sp_getrows_name
	from	dbo.master_upload_table
	where	code				= @p_code_table
	
	exec	@sp_getrows_name
			@p_keywords		
			,@p_pagenumber		
			,@p_rowspage		
			,@p_order_by		
			,@p_sort_by	
			,'UPLOAD'	
	*/
end ;
