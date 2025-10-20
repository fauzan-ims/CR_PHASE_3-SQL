-- Stored Procedure

CREATE PROCEDURE dbo.xsp_dimension_get_data_match
(
	@p_code					 nvarchar(50) output
	,@p_reff_tabel_dimension nvarchar(50)
	,@p_reff_no				 nvarchar(50)
	,@p_reff_tabel_type		 nvarchar(50)
	,@p_reff_from_table		 nvarchar(50)
)
as
begin
	declare @dim_code			nvarchar(50)
			,@dim_tbl			nvarchar(50)
			,@dim_column		nvarchar(50)
			,@dim_value			nvarchar(100)
			,@dim_primary_col	nvarchar(50)
			,@dim_1				nvarchar(50)
			,@operator_1		nvarchar(50)
			,@dim_value_from_1	nvarchar(50)
			,@dim_value_to_1	nvarchar(50)
			,@dim_2				nvarchar(50)
			,@operator_2		nvarchar(50)
			,@dim_value_from_2	nvarchar(50)
			,@dim_value_to_2	nvarchar(50)
			,@dim_3				nvarchar(50)
			,@operator_3		nvarchar(50)
			,@dim_value_from_3	nvarchar(50)
			,@dim_value_to_3	nvarchar(50)
			,@dim_4				nvarchar(50)
			,@operator_4		nvarchar(50)
			,@dim_value_from_4	nvarchar(50)
			,@dim_value_to_4	nvarchar(50)
			,@dim_5				nvarchar(50)
			,@operator_5		nvarchar(50)
			,@dim_value_from_5	nvarchar(50)
			,@dim_value_to_5	nvarchar(50)
			,@dim_6				nvarchar(50)
			,@operator_6		nvarchar(50)
			,@dim_value_from_6	nvarchar(50)
			,@dim_value_to_6	nvarchar(50)
			,@dim_7				nvarchar(50)
			,@operator_7		nvarchar(50)
			,@dim_value_from_7	nvarchar(50)
			,@dim_value_to_7	nvarchar(50)
			,@dim_8				nvarchar(50)
			,@operator_8		nvarchar(50)
			,@dim_value_from_8	nvarchar(50)
			,@dim_value_to_8	nvarchar(50)
			,@dim_9				nvarchar(50)
			,@operator_9		nvarchar(50)
			,@dim_value_from_9	nvarchar(50)
			,@dim_value_to_9	nvarchar(50)
			,@dim_10			nvarchar(50)
			,@operator_10		nvarchar(50)
			,@dim_value_from_10 nvarchar(50)
			,@dim_value_to_10	nvarchar(50)
			,@query				nvarchar(max) 
			,@queryselect		varchar(max) 
			,@code				nvarchar(50) = ''
			,@msg				nvarchar(max);
	begin try
		create table #dimension_tbl 
		(
			code			nvarchar(50)	COLLATE Latin1_General_CI_AS
			,table_name		nvarchar(50)	COLLATE Latin1_General_CI_AS
			,column_name	nvarchar(50)	COLLATE Latin1_General_CI_AS
			,primary_column nvarchar(50)	COLLATE Latin1_General_CI_AS
			,join_table		nvarchar(50)	COLLATE Latin1_General_CI_AS
			,join_column	nvarchar(50)	COLLATE Latin1_General_CI_AS
			,value			nvarchar(100)	COLLATE Latin1_General_CI_AS
			,operator		nvarchar(50)	COLLATE Latin1_General_CI_AS
			,dim_value_from nvarchar(50)	COLLATE Latin1_General_CI_AS
			,dim_value_to	nvarchar(50)	COLLATE Latin1_General_CI_AS
		) ;
 
		--get all dimension for supplier document group
		set @query = N'declare dim_cur cursor for 
						select dim_1				
								,operator_1		
								,dim_value_from_1	
								,dim_value_to_1	
								,dim_2				
								,operator_2		
								,dim_value_from_2	
								,dim_value_to_2	
								,dim_3				
								,operator_3		
								,dim_value_from_3	
								,dim_value_to_3	
								,dim_4				
								,operator_4		
								,dim_value_from_4	
								,dim_value_to_4	
								,dim_5				
								,operator_5		
								,dim_value_from_5	
								,dim_value_to_5	
								,dim_6				
								,operator_6		
								,dim_value_from_6	
								,dim_value_to_6	
								,dim_7				
								,operator_7		
								,dim_value_from_7	
								,dim_value_to_7	
								,dim_8				
								,operator_8		
								,dim_value_from_8	
								,dim_value_to_8	
								,dim_9				
								,operator_9		
								,dim_value_from_9	
								,dim_value_to_9	
								,dim_10			
								,operator_10		
								,dim_value_from_10 
								,dim_value_to_10	
						from ' + @p_reff_tabel_dimension + ' where is_active = ''1''';
	
		if (@p_reff_tabel_type in(	'APPLICATION', 'DRAWDOWN', 'PLAFOND'))
		begin
			set @query = @query + ' and flow_type = ''' + @p_reff_tabel_type + '''' ;
		end ;
		else if (@p_reff_tabel_type in('DGASSET', 'DGCOLL', 'DGPCOLL','DGAPPLICATION','DGDRAWDOWN','DGPLAFOND', 'DGAPCOLL','DGRLZTN'))
		begin
			set @query = @query + ' and DOCUMENT_GROUP_TYPE_CODE = ''' + @p_reff_tabel_type + '''' ;
		end ;
		else if (@p_reff_tabel_type in('DCAPPLICATION','DCPLAFOND' ,'DCDRAWDOWN'))
		begin
			set @query = @query + ' and CONTRACT_TYPE = ''' + @p_reff_tabel_type + '''' ;
		end ;
		else if (@p_reff_tabel_type <> '')
		begin
			raiserror('Reff table not found', 16, -1) ;
			return  ;
		end
	 
		set @query = @query + ' order by dim_count desc' ;
	
		execute sp_executesql @query ;
 
		open dim_cur ;

		fetch next from dim_cur
		into @dim_1
			 ,@operator_1
			 ,@dim_value_from_1
			 ,@dim_value_to_1
			 ,@dim_2
			 ,@operator_2
			 ,@dim_value_from_2
			 ,@dim_value_to_2
			 ,@dim_3
			 ,@operator_3
			 ,@dim_value_from_3
			 ,@dim_value_to_3
			 ,@dim_4
			 ,@operator_4
			 ,@dim_value_from_4
			 ,@dim_value_to_4
			 ,@dim_5
			 ,@operator_5
			 ,@dim_value_from_5
			 ,@dim_value_to_5
			 ,@dim_6
			 ,@operator_6
			 ,@dim_value_from_6
			 ,@dim_value_to_6
			 ,@dim_7
			 ,@operator_7
			 ,@dim_value_from_7
			 ,@dim_value_to_7
			 ,@dim_8
			 ,@operator_8
			 ,@dim_value_from_8
			 ,@dim_value_to_8
			 ,@dim_9
			 ,@operator_9
			 ,@dim_value_from_9
			 ,@dim_value_to_9
			 ,@dim_10
			 ,@operator_10
			 ,@dim_value_from_10
			 ,@dim_value_to_10 ;

		while @@fetch_status = 0
		BEGIN
   
			if not exists
			(
				select	1
				from	#dimension_tbl
				where	code = @dim_1
			)
			   and	@dim_1 is not null
			begin
				insert into #dimension_tbl
				(
					code
					,table_name
					,column_name
					,primary_column
					,join_table
					,join_column
					,operator
					,dim_value_from
					,dim_value_to
				)
				select	code
						,table_name
						,column_name
						,primary_column
						,''
						,''
						,@operator_1
						,@dim_value_from_1
						,@dim_value_to_1
				from	dbo.sys_dimension
				where	code = @dim_1 ;
			end ;
		
			if not exists
			(
				select	1
				from	#dimension_tbl
				where	code = @dim_2
			)
			   and	@dim_2 is not null
			begin
				insert into #dimension_tbl
				(
					code
					,table_name
					,column_name
					,primary_column
					,join_table
					,join_column
					,operator
					,dim_value_from
					,dim_value_to
				)
				select	code
						,table_name
						,column_name
						,primary_column
						,''
						,''
						,@operator_2
						,@dim_value_from_2
						,@dim_value_to_2
				from	dbo.sys_dimension
				where	code = @dim_2 ;
			end ;

			if not exists
			(
				select	1
				from	#dimension_tbl
				where	code = @dim_3
			)
			   and	@dim_3 is not null
			begin
				insert into #dimension_tbl
				(
					code
					,table_name
					,column_name
					,primary_column
					,join_table
					,join_column
					,operator
					,dim_value_from
					,dim_value_to
				)
				select	code
						,table_name
						,column_name
						,primary_column
						,''
						,''
						,@operator_3
						,@dim_value_from_3
						,@dim_value_to_3
				from	dbo.sys_dimension
				where	code = @dim_3 ;
			end ;

			if not exists
			(
				select	1
				from	#dimension_tbl
				where	code = @dim_4
			)
			   and	@dim_4 is not null
			begin
				insert into #dimension_tbl
				(
					code
					,table_name
					,column_name
					,primary_column
					,join_table
					,join_column
					,operator
					,dim_value_from
					,dim_value_to
				)
				select	code
						,table_name
						,column_name
						,primary_column
						,''
						,''
						,@operator_4
						,@dim_value_from_4
						,@dim_value_to_4
				from	dbo.sys_dimension
				where	code = @dim_4 ;
			end ;

			if not exists
			(
				select	1
				from	#dimension_tbl
				where	code = @dim_5
			)
			   and	@dim_5 is not null
			begin
				insert into #dimension_tbl
				(
					code
					,table_name
					,column_name
					,primary_column
					,join_table
					,join_column
					,operator
					,dim_value_from
					,dim_value_to
				)
				select	code
						,table_name
						,column_name
						,primary_column
						,''
						,''
						,@operator_5
						,@dim_value_from_5
						,@dim_value_to_5
				from	dbo.sys_dimension
				where	code = @dim_5 ;
			end ;

			if not exists
			(
				select	1
				from	#dimension_tbl
				where	code = @dim_6
			)
			   and	@dim_6 is not null
			begin
				insert into #dimension_tbl
				(
					code
					,table_name
					,column_name
					,primary_column
					,join_table
					,join_column
					,operator
					,dim_value_from
					,dim_value_to
				)
				select	code
						,table_name
						,column_name
						,primary_column
						,''
						,''
						,@operator_6
						,@dim_value_from_6
						,@dim_value_to_6
				from	dbo.sys_dimension
				where	code = @dim_6 ;
			end ;

			if not exists
			(
				select	1
				from	#dimension_tbl
				where	code = @dim_7
			)
			   and	@dim_7 is not null
			begin
				insert into #dimension_tbl
				(
					code
					,table_name
					,column_name
					,primary_column
					,join_table
					,join_column
					,operator
					,dim_value_from
					,dim_value_to
				)
				select	code
						,table_name
						,column_name
						,primary_column
						,''
						,''
						,@operator_7
						,@dim_value_from_7
						,@dim_value_to_7
				from	dbo.sys_dimension
				where	code = @dim_7 ;
			end ;

			if not exists
			(
				select	1
				from	#dimension_tbl
				where	code = @dim_8
			)
			   and	@dim_8 is not null
			begin
				insert into #dimension_tbl
				(
					code
					,table_name
					,column_name
					,primary_column
					,join_table
					,join_column
					,operator
					,dim_value_from
					,dim_value_to
				)
				select	code
						,table_name
						,column_name
						,primary_column
						,''
						,''
						,@operator_8
						,@dim_value_from_8
						,@dim_value_to_8
				from	dbo.sys_dimension
				where	code = @dim_8 ;
			end ;

			if not exists
			(
				select	1
				from	#dimension_tbl
				where	code = @dim_9
			)
			   and	@dim_9 is not null
			begin
				insert into #dimension_tbl
				(
					code
					,table_name
					,column_name
					,primary_column
					,join_table
					,join_column
					,operator
					,dim_value_from
					,dim_value_to
				)
				select	code
						,table_name
						,column_name
						,primary_column
						,''
						,''
						,@operator_9
						,@dim_value_from_9
						,@dim_value_to_9
				from	dbo.sys_dimension
				where	code = @dim_9 ;
			end ;

			if not exists
			(
				select	1
				from	#dimension_tbl
				where	code = @dim_10
			)
			   and	@dim_10 is not null
			begin
				insert into #dimension_tbl
				(
					code
					,table_name
					,column_name
					,primary_column
					,join_table
					,join_column
					,operator
					,dim_value_from
					,dim_value_to
				)
				select	code
						,table_name
						,column_name
						,primary_column
						,''
						,''
						,@operator_10
						,@dim_value_from_10
						,@dim_value_to_10
				from	dbo.sys_dimension
				where	code = @dim_10 ;
			end ;
		
			fetch next from dim_cur
			into @dim_1
				 ,@operator_1
				 ,@dim_value_from_1
				 ,@dim_value_to_1
				 ,@dim_2
				 ,@operator_2
				 ,@dim_value_from_2
				 ,@dim_value_to_2
				 ,@dim_3
				 ,@operator_3
				 ,@dim_value_from_3
				 ,@dim_value_to_3
				 ,@dim_4
				 ,@operator_4
				 ,@dim_value_from_4
				 ,@dim_value_to_4
				 ,@dim_5
				 ,@operator_5
				 ,@dim_value_from_5
				 ,@dim_value_to_5
				 ,@dim_6
				 ,@operator_6
				 ,@dim_value_from_6
				 ,@dim_value_to_6
				 ,@dim_7
				 ,@operator_7
				 ,@dim_value_from_7
				 ,@dim_value_to_7
				 ,@dim_8
				 ,@operator_8
				 ,@dim_value_from_8
				 ,@dim_value_to_8
				 ,@dim_9
				 ,@operator_9
				 ,@dim_value_from_9
				 ,@dim_value_to_9
				 ,@dim_10
				 ,@operator_10
				 ,@dim_value_from_10
				 ,@dim_value_to_10 ;
		end ;

		close dim_cur ;
		deallocate dim_cur ;
  
		--get all dimension value
		declare dim_cur cursor local fast_forward for
		select	code
				,table_name
				,column_name
				,primary_column
		from	#dimension_tbl ;

		open dim_cur ;

		fetch next from dim_cur
		into @dim_code
			 ,@dim_tbl
			 ,@dim_column
			 ,@dim_primary_col ;

		while @@fetch_status = 0
		begin
	 
			exec dbo.xsp_get_table_value_by_dimension @p_dim_code		= @dim_code
													  ,@p_reff_code		= @p_reff_no
													  ,@p_reff_table	= @p_reff_from_table
													  ,@p_output		= @dim_value output ;
			update	#dimension_tbl
			set		value = @dim_value
			where	code = @dim_code ;
		
			fetch next from dim_cur
			into @dim_code
				 ,@dim_tbl
				 ,@dim_column
				 ,@dim_primary_col ;
		end ;

		close dim_cur ;
		deallocate dim_cur ;
	 
		--SELECT * FROM #dimension_tbl

		if
		(
			select	count(code)
			from	#dimension_tbl
		) <> 0
		begin
			set @queryselect = '' ; 
			set @p_code = '' ;
			set @query = 'select top 1 @code2  = code from ' + @p_reff_tabel_dimension + ' maf where is_active = ''1''' ;

			if (@p_reff_tabel_type in (	'APPLICATION', 'DRAWDOWN', 'PLAFOND'))
			begin
				set @query = @query + ' and flow_type = @p_reff_tabel_type and ' ;
			end ;
			else if (@p_reff_tabel_type in ('DGASSET', 'DGCOLL', 'DGPCOLL', 'DGAPPLICATION','DGDRAWDOWN','DGPLAFOND', 'DGAPCOLL','DGRLZTN'))
			begin
				set @query = @query + ' and document_group_type_code = @p_reff_tabel_type and ' ;
			end ;
			else if (@p_reff_tabel_type in('DCAPPLICATION','DCPLAFOND' ,'DCDRAWDOWN'))
			begin
				set @query = @query + ' and CONTRACT_TYPE = ''' + @p_reff_tabel_type + '''' + ' and ' ;
			end ;
		
			set @query = @query + N' exists (select dt.code from #dimension_tbl dt where dt.code = isnull(maf.dim_1  ,dt.code) and (	( value = isnull(dim_value_from_1  ,value) and isnull(operator_1 ,''equal'' ) = ''equal'') or	 (value <  isnull(dim_value_from_1  ,value)   and isnull( operator_1 ,''less than'' ) = ''less than'') or	 (value >  isnull(dim_value_from_1  ,value)   and isnull( operator_1 ,''more than'') = ''more than''))  or (value >  isnull(dim_value_from_1  ,value)   and value <  isnull(dim_value_to_1 ,value)   and  isnull( operator_1  ,''between'') = ''between''))
								 and exists (select dt.code from #dimension_tbl dt where dt.code = isnull(maf.dim_2  ,dt.code) and (	( value = isnull(dim_value_from_2  ,value) and isnull(operator_2 ,''equal'' ) = ''equal'') or	 (value <  isnull(dim_value_from_2  ,value)   and isnull( operator_2 ,''less than'' ) = ''less than'') or	 (value >  isnull(dim_value_from_2  ,value)   and isnull( operator_2 ,''more than'') = ''more than''))  or (value >  isnull(dim_value_from_2  ,value)   and value <  isnull(dim_value_to_2 ,value)   and  isnull( operator_2  ,''between'') = ''between''))
		 						 and exists (select dt.code from #dimension_tbl dt where dt.code = isnull(maf.dim_3  ,dt.code) and (	( value = isnull(dim_value_from_3  ,value) and isnull(operator_3 ,''equal'' ) = ''equal'') or	 (value <  isnull(dim_value_from_3  ,value)   and isnull( operator_3 ,''less than'' ) = ''less than'') or	 (value >  isnull(dim_value_from_3  ,value)   and isnull( operator_3 ,''more than'') = ''more than''))  or (value >  isnull(dim_value_from_3  ,value)   and value <  isnull(dim_value_to_3 ,value)   and  isnull( operator_3  ,''between'') = ''between''))
		 						 and exists (select dt.code from #dimension_tbl dt where dt.code = isnull(maf.dim_4  ,dt.code) and (	( value = isnull(dim_value_from_4  ,value) and isnull(operator_4 ,''equal'' ) = ''equal'') or	 (value <  isnull(dim_value_from_4  ,value)   and isnull( operator_4 ,''less than'' ) = ''less than'') or	 (value >  isnull(dim_value_from_4  ,value)   and isnull( operator_4 ,''more than'') = ''more than''))  or (value >  isnull(dim_value_from_4  ,value)   and value <  isnull(dim_value_to_4 ,value)   and  isnull( operator_4  ,''between'') = ''between''))
		 						 and exists (select dt.code from #dimension_tbl dt where dt.code = isnull(maf.dim_5  ,dt.code) and (	( value = isnull(dim_value_from_5  ,value) and isnull(operator_5 ,''equal'' ) = ''equal'') or	 (value <  isnull(dim_value_from_5  ,value)   and isnull( operator_5 ,''less than'' ) = ''less than'') or	 (value >  isnull(dim_value_from_5  ,value)   and isnull( operator_5 ,''more than'') = ''more than''))  or (value >  isnull(dim_value_from_5  ,value)   and value <  isnull(dim_value_to_5 ,value)   and  isnull( operator_5  ,''between'') = ''between''))
		 						 and exists (select dt.code from #dimension_tbl dt where dt.code = isnull(maf.dim_6  ,dt.code) and (	( value = isnull(dim_value_from_6  ,value) and isnull(operator_6 ,''equal'' ) = ''equal'') or	 (value <  isnull(dim_value_from_6  ,value)   and isnull( operator_6 ,''less than'' ) = ''less than'') or	 (value >  isnull(dim_value_from_6  ,value)   and isnull( operator_6 ,''more than'') = ''more than''))  or (value >  isnull(dim_value_from_6  ,value)   and value <  isnull(dim_value_to_6 ,value)   and  isnull( operator_6  ,''between'') = ''between''))
		 						 and exists (select dt.code from #dimension_tbl dt where dt.code = isnull(maf.dim_7  ,dt.code) and (	( value = isnull(dim_value_from_7  ,value) and isnull(operator_7 ,''equal'' ) = ''equal'') or	 (value <  isnull(dim_value_from_7  ,value)   and isnull( operator_7 ,''less than'' ) = ''less than'') or	 (value >  isnull(dim_value_from_7  ,value)   and isnull( operator_7 ,''more than'') = ''more than''))  or (value >  isnull(dim_value_from_7  ,value)   and value <  isnull(dim_value_to_7 ,value)   and  isnull( operator_7  ,''between'') = ''between''))
		 						 and exists (select dt.code from #dimension_tbl dt where dt.code = isnull(maf.dim_8  ,dt.code) and (	( value = isnull(dim_value_from_8  ,value) and isnull(operator_8 ,''equal'' ) = ''equal'') or	 (value <  isnull(dim_value_from_8  ,value)   and isnull( operator_8 ,''less than'' ) = ''less than'') or	 (value >  isnull(dim_value_from_8  ,value)   and isnull( operator_8 ,''more than'') = ''more than''))  or (value >  isnull(dim_value_from_8  ,value)   and value <  isnull(dim_value_to_8 ,value)   and  isnull( operator_8  ,''between'') = ''between''))
		 						 and exists (select dt.code from #dimension_tbl dt where dt.code = isnull(maf.dim_9  ,dt.code) and (	( value = isnull(dim_value_from_9  ,value) and isnull(operator_9 ,''equal'' ) = ''equal'') or	 (value <  isnull(dim_value_from_9  ,value)   and isnull( operator_9 ,''less than'' ) = ''less than'') or	 (value >  isnull(dim_value_from_9  ,value)   and isnull( operator_9 ,''more than'') = ''more than''))  or (value >  isnull(dim_value_from_9  ,value)   and value <  isnull(dim_value_to_9 ,value)   and  isnull( operator_9  ,''between'') = ''between''))
		 						 and exists (select dt.code from #dimension_tbl dt where dt.code = isnull(maf.dim_10 ,dt.code) and (	( value = isnull(dim_value_from_10 ,value) and isnull(operator_10,''equal'' ) = ''equal'') or	 (value <  isnull(dim_value_from_10 ,value)   and isnull( operator_10,''less than'' ) = ''less than'') or	 (value >  isnull(dim_value_from_10 ,value)   and isnull( operator_10,''more than'') = ''more than''))  or (value >  isnull(dim_value_from_10 ,value)   and value <  isnull(dim_value_to_10 ,value)   and  isnull( operator_10,''between'') = ''between''))
								 and maf.is_active = ''1''
								 order by dim_count desc
								 ;'
		 
			EXECUTE sp_executesql @query, N'@p_reff_tabel_type nvarchar(250), @code2 nvarchar(50) output', @p_reff_tabel_type = @p_reff_tabel_type, @code2 = @p_code output
		end ;
		else
		BEGIN
			set @query = '' ; 
			set @p_code = '' ;
			set @query = 'select top 1 @code2  = code from ' + @p_reff_tabel_dimension + ' maf where is_active = ''1''' ;
				
			if (@p_reff_tabel_type in (	'APPLICATION', 'DRAWDOWN', 'PLAFOND'))
			begin
				set @query = @query + ' and flow_type = @p_reff_tabel_type ' ;
			end ;
			else if (@p_reff_tabel_type in ('DGASSET', 'DGCOLL', 'DGPCOLL','DGAPPLICATION','DGDRAWDOWN','DGPLAFOND', 'DGAPCOLL','DGRLZTN'))
			begin
				set @query = @query + ' and document_group_type_code = @p_reff_tabel_type ' ;
			end ;
			else if (@p_reff_tabel_type in('DCAPPLICATION','DCPLAFOND' ,'DCDRAWDOWN'))
			begin
				set @query = @query + ' and CONTRACT_TYPE = ''' + @p_reff_tabel_type + '''' ;
			end ;
			execute sp_executesql @query, N'@p_reff_tabel_type nvarchar(250), @code2 nvarchar(50) output', @p_reff_tabel_type = @p_reff_tabel_type, @code2 = @p_code output
		end
	 
		drop table #dimension_tbl
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