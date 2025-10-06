CREATE PROCEDURE dbo.xsp_generate_application_no
	@p_unique_code		  nvarchar(50) output
	,@p_branch_code		  nvarchar(10)
	,@p_year			  nvarchar(4)
	,@p_month			  nvarchar(2)
	,@p_opl_code		  nvarchar(250)
	,@p_run_number_length int
	,@p_delimiter		  nvarchar(1)
	,@p_type			  nvarchar(20) = ''
as
begin
	declare @code				nvarchar(max)
			,@running_no		nvarchar(50)
			,@agreement_no		nvarchar(50)
			,@application_no	nvarchar(50) 
			,@main_contract_no	nvarchar(50);

	if	(@p_type = 'APPLICATION')
	begin
		select	@application_no = max(left(application_no, @p_run_number_length))
		from	application_main
		where	cre_by <> 'MIGRASI' ;

		set @running_no = right(replace(str(cast(isnull(right(isnull(@application_no, 0), @p_run_number_length), 0) as int) + 1), ' ', '0'), @p_run_number_length) ;
		set @code = @running_no + @p_delimiter + @p_opl_code + @p_delimiter + @p_branch_code + @p_delimiter + @p_month + @p_delimiter + @p_year ;
		set @p_unique_code = @code ;
	end
	else if (@p_type = 'AGREEMENT')
	begin
		select	@agreement_no = max(left(agreement_no, @p_run_number_length))
		from	dbo.realization
		where	cre_by <> 'MIGRASI' ;

		set @running_no = right(replace(str(cast(isnull(right(isnull(@agreement_no, 0), @p_run_number_length), 0) as int) + 1), ' ', '0'), @p_run_number_length) ;
		set @code = @running_no + @p_delimiter + @p_opl_code + @p_delimiter + right(@p_branch_code,2) + @p_delimiter + @p_month + @p_delimiter + @p_year ;
		set @p_unique_code = @code ;
	end
	else if (@p_type = 'MASTER CONTRACT')
	begin
		--select	@main_contract_no = max(left(main_contract_no, @p_run_number_length))
		--from	dbo.application_extention 
		--where	cre_by <> 'MIGRASI' ;
		--sepria(11-03-2025: update @p_run_number_length jadi 4 digit, dan jadikan pas ambil max itu jadi int agar keambil yang 1000
		select	@main_contract_no = max(cast((replace(left(main_contract_no, @p_run_number_length),'/','')) as int))
		from	dbo.application_extention 
		where	cre_by <> 'MIGRASI' ;

		set @running_no = right(replace(str(cast(isnull(right(isnull(@main_contract_no, 0), @p_run_number_length), 0) as int) + 1), ' ', '0'), @p_run_number_length) 
		set	@code	= @running_no + @p_delimiter + @p_opl_code + @p_delimiter + @p_month + @p_delimiter + @p_year
		set @p_unique_code = @code ;
		
	end

end ;
