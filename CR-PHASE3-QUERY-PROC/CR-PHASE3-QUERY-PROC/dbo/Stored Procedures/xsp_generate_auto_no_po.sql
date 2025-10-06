CREATE PROCEDURE dbo.xsp_generate_auto_no_po
(
	@p_unique_code		  nvarchar(50)	output
	,@p_branch_code		  nvarchar(10)	= ''
	,@p_year			  nvarchar(4)	= ''
	,@p_month			  nvarchar(4)	= ''
	,@p_opl_code		  nvarchar(250)
	,@p_jkn				  nvarchar(250) 
	,@p_por				  nvarchar(250)
	,@p_run_number_length int
	,@p_delimiter		  nvarchar(1)
	,@p_table_name		  nvarchar(250) = ''
	,@p_column_name		  nvarchar(250) = ''
)
as
begin
	declare @code			   nvarchar(max)
			,@next_run_number  nvarchar(50)
			,@running_no	   nvarchar(50)
			,@agreement_no	   nvarchar(50)
			,@column_name	   nvarchar(250)
			,@main_contract_no nvarchar(50)
			,@query			   nvarchar(1000)
			,@param			   nvarchar(50) = '@next_run_numberOUT nvarchar(50) output' ;

	begin
		set @query = '	select	@next_run_numberOUT = replace(str(cast((isnull(max(substring(' + @p_column_name + ', 0, ' + cast(@p_run_number_length+1 as nvarchar) + ')), 0) +1) as nvarchar), ' + cast(@p_run_number_length as nvarchar) + ', 0), '' '', ''0'')
				from	' + @p_table_name + '
				where	cre_by	<> ''MIGRASI'' and code not like ''DSF.POR%'' and  code not like ''IMS.POR%''' ;

		execute sp_executesql @query
							  ,@param
							  ,@next_run_numberOUT = @next_run_number output ;

			set @p_unique_code = @next_run_number + @p_delimiter + @p_jkn + @p_delimiter + @p_por + @p_delimiter + @p_month + @p_delimiter + @p_year ;
		--end
		
	end ;
end;

