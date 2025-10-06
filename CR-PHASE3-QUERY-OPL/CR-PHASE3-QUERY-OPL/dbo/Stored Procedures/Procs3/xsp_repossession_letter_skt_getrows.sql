CREATE PROCEDURE dbo.xsp_repossession_letter_skt_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_branch_code	  nvarchar(50)
	,@p_letter_status nvarchar(50) 
	,@p_is_remedial	  nvarchar(1)
)
as
begin
	declare @rows_count int = 0 ;

	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	END

	select	@rows_count = count(1)
	from	repossession_letter rl
			left join dbo.agreement_main am	on (am.agreement_no = rl.agreement_no)
			--left join dbo.master_executor mec	on (mec.code		= rl.letter_executor_code)
			left join dbo.master_collector mcr	on (mcr.code		= rl.letter_collector_code)
	where	--rl.is_remedial = @p_is_remedial
			 rl.branch_code		 = case @p_branch_code
										   when 'ALL' then rl.branch_code
										   else @p_branch_code
									   end
			and rl.letter_status	= case @p_letter_status
										   when 'ALL' then rl.letter_status
										   else @p_letter_status
									  end
			and rl.letter_status in('HOLD','CANCEL','POST')
			and (
					rl.letter_no									like '%' + @p_keywords + '%'
					or	am.agreement_external_no					like '%' + @p_keywords + '%'
					or	am.client_name								like '%' + @p_keywords + '%'
					or	convert(varchar(30), rl.letter_date, 103)	like '%' + @p_keywords + '%'
					or	rl.letter_status							like '%' + @p_keywords + '%'
					or	mcr.collector_name							like '%' + @p_keywords + '%'
					--or	mec.executor_name							like '%' + @p_keywords + '%'
					or	rl.branch_name								like '%' + @p_keywords + '%'
				) ;

		select		rl.code
					,rl.letter_no
					,am.agreement_external_no 'agreement_no'
					,am.client_name
					,convert(varchar(30), rl.letter_date, 103) 'letter_date'
					,rl.letter_status
					,rl.result_status
					,mcr.collector_name	
					--,mec.executor_name
					,rl.branch_name
					,rl.letter_exp_date	
					,@rows_count 'rowcount'
		from		repossession_letter rl
					left join dbo.agreement_main am on (am.agreement_no = rl.agreement_no)
					--left join dbo.master_executor mec	on (mec.code		= rl.letter_executor_code)
					left join dbo.master_collector mcr	on (mcr.code		= rl.letter_collector_code)
		where		--rl.is_remedial = @p_is_remedial
					rl.branch_code		 = case @p_branch_code
												   when 'ALL' then rl.branch_code
												   else @p_branch_code
											   end
					and rl.letter_status	= case @p_letter_status
												   when 'ALL' then rl.letter_status
												   else @p_letter_status
											  end
					and rl.letter_status in('HOLD','CANCEL','POST')
					and (
							rl.letter_no									like '%' + @p_keywords + '%'
							or	am.agreement_external_no					like '%' + @p_keywords + '%'
							or	am.client_name								like '%' + @p_keywords + '%'
							or	convert(varchar(30), rl.letter_date, 103)	like '%' + @p_keywords + '%'
							or	rl.letter_status							like '%' + @p_keywords + '%'
							or	mcr.collector_name							like '%' + @p_keywords + '%'
							--or	mec.executor_name							like '%' + @p_keywords + '%'
							or	rl.branch_name								like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then rl.letter_no
														when 2 then rl.branch_name
														when 3 then cast(rl.letter_date as sql_variant)
														when 4 then am.agreement_external_no
														when 5 then rl.letter_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then rl.letter_no
														when 2 then rl.branch_name
														when 3 then cast(rl.letter_date as sql_variant)
														when 4 then am.agreement_external_no
														when 5 then rl.letter_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
