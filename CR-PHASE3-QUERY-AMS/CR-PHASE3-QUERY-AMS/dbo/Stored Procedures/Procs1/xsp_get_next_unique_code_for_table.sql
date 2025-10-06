
CREATE procedure dbo.xsp_get_next_unique_code_for_table
(
	@p_unique_code		  nvarchar(50) output
	,@p_branch_code		  nvarchar(10)
	,@p_sys_document_code nvarchar(10)
	,@p_custom_prefix	  nvarchar(10) = ''
	,@p_year			  nvarchar(2)
	,@p_month			  nvarchar(2)
	,@p_table_name		  nvarchar(100)
	,@p_run_number_length int
	,@p_delimiter		  nvarchar(1)  = ''
	,@p_run_number_only	  nvarchar(1)  = '0'
	,@p_specified_column  nvarchar(50)  = ''
)
as
BEGIN
	
	if @p_table_name <> ''
	   and	@p_table_name is not null
	   and	@p_run_number_length <> 0
	   and	@p_run_number_length is not null
	begin
		--max run number allowed only 8
		--if @p_run_number_length > 8
		--	set @p_unique_code = 'number length error'
		--else
		--begin
		declare @next_run_number nvarchar(50)
				,@sys_doc_code	 nvarchar(10)  = ''
				,@sys_brc_code	 nvarchar(10)  = ''
				--
				,@run_length	 int		   = 0
				,@year_length	 int		   = 0
				,@month_length	 int		   = 0
				--
				,@pk_column		 nvarchar(100)
				,@dot_a			 int		   = 3
				,@dot_b			 int		   = 2
				--
				,@query			 nvarchar(1000)
				,@param			 nvarchar(50)  = '@next_run_numberOUT nvarchar(50) output' ;

		/*
		dot use for counting (.) in unique code
		exmp : XXXX.YYY.199001.000001 ->  dot is 3
		XXXX -> branch document code
		YYY -> sys document code
		199001 -> year and month
		000001 -> run number length
		*/
		set @sys_brc_code = @p_branch_code ;
		--get pk column of specified table
		IF @p_specified_column = ''
		begin
			select top 1
					@pk_column = column_name
			from	information_schema.key_column_usage
			where	table_name = upper(@p_table_name)
					and constraint_name like 'PK%' ;
		end
        else
        begin
			set @pk_column = @p_specified_column
		end
	 

		--check if pk column is exists
		if @pk_column is null
			set @p_unique_code = 'primary key error' ;
		else
		begin
			if @p_run_number_only = '0'
			begin
				--if custom prefix <> '' then unique code using custom prefix
				if @p_custom_prefix = ''
				begin
					----check if branch is exists to get code document
					--if @p_branch_code is not null
					--   and	@p_branch_code <> ''
					--begin
					--	set @sys_brc_code = @p_branch_code ;
					----select	@sys_brc_code	= code_document
					----from	sys_branch 
					----where	code			= @p_branch_code
					--end ;
					--else
					begin
						if @p_delimiter <> ''
						begin
							set @dot_a -= 1 ;
							set @dot_b -= 1 ;
						end ;
						else
						begin
							set @dot_a = 0 ;
							set @dot_b = 0 ;
						end ;
					end ;

					--check sys document code to get code document if exists
					if @p_sys_document_code is not null
					   and	@p_sys_document_code <> ''
					begin
						select	@sys_doc_code = code_document
						from	dbo.sys_document_number
						where	code = @p_sys_document_code ;
					end ;
					else
					begin
						if @p_delimiter <> ''
						begin
							set @dot_a -= 1 ;
							set @dot_b -= 1 ;
						end ;
						else
						begin
							set @dot_a = 0 ;
							set @dot_b = 0 ;
						end ;
					end ;
					if (@sys_brc_code = '')
					begin
						set @run_length += ( len(@sys_doc_code) + len(@p_year) + len(@p_month) + @dot_a) + 1 ; -- Trisna 12-Oct-2022 ket : for WOM, additional len(@p_delimiter) betweenn @p_year and @p_month (-) ====
						set @year_length += (len(@sys_doc_code) + @dot_b) + 1 ;
						set @month_length += (len(@sys_doc_code) + len(@p_year) + @dot_b) + 1 ;
						
					end
                    else
                    begin
						set @run_length += (len(@sys_brc_code)  +len(@p_delimiter)+ len(@sys_doc_code) + len(@p_year) + len(@p_month) + @dot_a) + 1 ; -- Trisna 12-Oct-2022 ket : for WOM, additional len(@p_delimiter) betweenn @p_year and @p_month (-) ====
						set @year_length += (len(@sys_brc_code) +len(@p_delimiter) + len(@sys_doc_code) + @dot_b) + 1 ;
						set @month_length += (len(@sys_brc_code)  +len(@p_delimiter)+ len(@sys_doc_code) + len(@p_year) + @dot_b) + 1 ;
						
					END
				end ;
				else
				begin
					if @p_delimiter <> ''
					begin
						set @dot_a = 2 ;
						set @dot_b = 1 ;
					end ;
					else
					begin
						set @dot_a = 0 ;
						set @dot_b = 0 ;
					end ;

					if (@sys_brc_code = '')
					begin
						set @run_length += (len(@p_custom_prefix) + len(@p_year) + len(@p_month) + @dot_a) + 1 ;  -- Trisna 12-Oct-2022 ket : for WOM, additional len(@p_delimiter) betweenn @p_year and @p_month (-) ====
						set @year_length += (len(@p_custom_prefix) + @dot_b) + 1 ;
						set @month_length += (len(@p_custom_prefix) + len(@p_year) + @dot_b) + 1 ;
					end
                    else
                    begin
						set @run_length += (len(@sys_brc_code) + len(@p_delimiter) + len(@p_custom_prefix) + len(@p_year) + len(@p_month) + @dot_a) + 1 ; -- Trisna 12-Oct-2022 ket : for WOM, additional len(@p_delimiter) betweenn @p_year and @p_month (-) ====
						set @year_length += (len(@sys_brc_code) + len(@p_delimiter) + len(@p_custom_prefix) + @dot_b) + 1 ;
						set @month_length += (len(@sys_brc_code) + len(@p_delimiter) + len(@p_custom_prefix) + len(@p_year) + @dot_b) + 1 ;
					end
				end ;

				--SELECT @run_length, @year_length,@month_length
				--dynamically generate run number
				if len(@p_year) < 1
				   and	len(@p_month) > 0
				begin
					set @query = '	select	@next_run_numberOUT = replace(str(cast((isnull(max(substring(' + @pk_column + ', ' + cast(@run_length as nvarchar) + ', ' + cast(@p_run_number_length as nvarchar) + ')), 0) + 1) as nvarchar), ' + cast(@p_run_number_length as nvarchar) + ', 0), '' '', ''0'')
									from	' + @p_table_name + '
									where	substring(' + @pk_column + ', ' + cast(@month_length as nvarchar) + ', 2)	= ''' + @p_month + '''
									and		cre_by	<> ''MIGRASI''';
									
									--and		substring(' + @pk_column + ', 1, 4)	= ''' + @p_branch_code + ''
				end ;
				else if len(@p_month) < 1
						and len(@p_year) > 0
				begin
					set @query = '	select	@next_run_numberOUT = replace(str(cast((isnull(max(substring(' + @pk_column + ', ' + cast(@run_length as nvarchar) + ', ' + cast(@p_run_number_length as nvarchar) + ')), 0) + 1) as nvarchar), ' + cast(@p_run_number_length as nvarchar) + ', 0), '' '', ''0'')
									from	' + @p_table_name + '
									where	substring(' + @pk_column + ', ' + cast(@year_length as nvarchar) + ', ' + cast(len(@p_year) as nvarchar) + ')	= ''' + @p_year + '''
									and		cre_by	<> ''MIGRASI'' ';
									--and		substring(' + @pk_column + ', 1, 4)	= ''' + @p_branch_code + '''' ;
				end ;
				else if len(@p_year) < 1
						and len(@p_month) < 1
				begin
					set @query = '	select	@next_run_numberOUT = replace(str(cast((isnull(max(substring(' + @pk_column + ', ' + cast(@run_length as nvarchar) + ', ' + cast(@p_run_number_length as nvarchar) + ')), 0) + 1) as nvarchar), ' + cast(@p_run_number_length as nvarchar) + ', 0), '' '', ''0'')
									from	' + @p_table_name + '
									where	cre_by	<> ''MIGRASI'' ';
									--and		substring(' + @pk_column + ', 1, 4)	= ''' + @p_branch_code + '''' ;
				end ;
				else
				BEGIN
					set @query = '	select	@next_run_numberOUT = replace(str(cast((isnull(max(substring(' + @pk_column + ', ' + cast(@run_length as nvarchar) + ', ' + cast(@p_run_number_length as nvarchar) + ')), 0) + 1) as nvarchar), ' + cast(@p_run_number_length as nvarchar) + ', 0), '' '', ''0'')
									from	' + @p_table_name + '
									where	substring(' + @pk_column + ', ' + cast(@year_length as nvarchar) + ', ' + cast(len(@p_year) as nvarchar) + ')	= ''' + @p_year + '''
									and		substring(' + @pk_column + ', ' + cast(@month_length as nvarchar) + ', 2)	= ''' + @p_month + '''
									and		cre_by	<> ''MIGRASI'' ';
									--and		substring(' + @pk_column + ', 1, 4)	= ''' + @p_branch_code + '''' ;
				end ;
				 
				IF LEN(@p_branch_code) > 0  
				BEGIN
					SET @query = @query + 'and		substring(' + @pk_column + ', 1, '+CAST(LEN(@p_branch_code) AS NVARCHAR(50))+')	= ''' + @p_branch_code + '''' ;
				END
                
				--if len(@sys_brc_code) > 1
				--	set @query += ' and branch_code = ' + @sys_brc_code
				execute sp_executesql @query
									  ,@param
									  ,@next_run_numberOUT = @next_run_number output ;

				--lastly build unique code
				if @p_custom_prefix = ''
				begin
					if @sys_brc_code = '' and	@sys_doc_code <> ''
						set @p_unique_code = @sys_doc_code + @p_delimiter + @p_year + @p_month + @p_delimiter + @next_run_number ; -- Trisna 12-Oct-2022 ket : for WOM, additional @p_delimiter betweenn @p_year and @p_month (-) ====
					else if @sys_doc_code = '' and @sys_brc_code <> ''			    
						set @p_unique_code = @sys_brc_code + @p_delimiter + @p_year + @p_month + @p_delimiter + @next_run_number ; -- Trisna 12-Oct-2022 ket : for WOM, additional @p_delimiter betweenn @p_year and @p_month (-) ====
					else
					begin
						if @sys_brc_code = ''  and	@sys_doc_code = ''
							set @p_unique_code = @p_year + @p_month + @p_delimiter + @next_run_number ; -- Trisna 12-Oct-2022 ket : for WOM, additional @p_delimiter betweenn @p_year and @p_month (-) ====
						else
							set @p_unique_code = @sys_brc_code + @p_delimiter + @sys_doc_code + @p_delimiter + @p_year + @p_month + @p_delimiter + @next_run_number ; -- Trisna 12-Oct-2022 ket : for WOM, additional @p_delimiter betweenn @p_year and @p_month (-) ====
					end ;
				end ;
				else
					if @p_branch_code <> ''
					begin
						set @p_unique_code = @p_branch_code + @p_delimiter + @p_custom_prefix + @p_delimiter + @p_year + @p_month + @p_delimiter + @next_run_number ; -- Trisna 12-Oct-2022 ket : for WOM, additional @p_delimiter betweenn @p_year and @p_month (-) ====
					end
					else
					begin
						set @p_unique_code = @p_custom_prefix + @p_delimiter + @p_year + @p_month + @p_delimiter + @next_run_number ; -- Trisna 12-Oct-2022 ket : for WOM, additional @p_delimiter betweenn @p_year and @p_month (-) ====
					end
			end ;
			else if @p_run_number_only = '1'
			begin
			
				--generating only with running number
				set @query = '	select	@next_run_numberOUT = replace(str(cast((isnull(max(substring(' + @pk_column + ', 1, ' + cast(@p_run_number_length as nvarchar) + ')), 0) +1) as nvarchar), ' + cast(@p_run_number_length as nvarchar) + ', 0), '' '', ''0'')
								from	' + @p_table_name + '
								where	cre_by	<> ''MIGRASI'' ';
								--and		substring(' + @pk_column + ', 1, 4)	= ''' + @p_branch_code + '''' ;

				execute sp_executesql @query
									  ,@param
									  ,@next_run_numberOUT = @next_run_number output ;

				set @p_unique_code = @next_run_number ;
			end ;
			else
				set @p_unique_code = 'parameter setting error' ;
		end ;
	--end
	end ;
	else
	begin
		if @p_table_name = ''
		   or	@p_table_name is null
			set @p_unique_code = 'table name error' ;
		else if @p_run_number_length < 1
				or	@p_run_number_length is null
			set @p_unique_code = 'number length error' ;
	end ;
end ;




