CREATE PROCEDURE [dbo].[xsp_bank_mutation_lookup_report]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_for_all			nvarchar(1)	= ''
)
as
begin

	declare @rows_count int = 0 ;

	if (@p_for_all <> '')
	begin
		select	@rows_count = count(1)
		FROM
				(
					select 	'ALL' as 'code'
							,'ALL' as 'name'
							,'ALL' as 'bank_account_no'
					union all
					select  branch_bank_code
							,branch_bank_name
							,sbb.bank_account_no 
					from	dbo.bank_mutation bm
							inner join ifinsys.dbo.sys_branch_bank sbb on (sbb.code = bm.branch_bank_code)
					where	bm.branch_code = case @p_branch_code
													when 'all' then bm.branch_code
													else @p_branch_code
												end
				) as account
		where	(
					account.code like '%' + @p_keywords + '%'
					or	account.name like '%' + @p_keywords + '%'
					or	account.bank_account_no like '%' + @p_keywords + '%'
				) ;

		if @p_sort_by = 'asc'
		begin
			select		*
			from
						(
							select	'ALL' as 'code'
									,'ALL' as 'name'
									,'ALL' as 'bank_account_no'
							union all
							select  branch_bank_code
									,branch_bank_name
									,sbb.bank_account_no
							from	dbo.bank_mutation bm
									inner join ifinsys.dbo.sys_branch_bank sbb on (sbb.code = bm.branch_bank_code)
							where	bm.branch_code = case @p_branch_code
															when 'all' then bm.branch_code
															else @p_branch_code
														end
						) as account
			where		(
							account.code like '%' + @p_keywords + '%'
							or	account.name like '%' + @p_keywords + '%'
							or	account.bank_account_no like '%' + @p_keywords + '%'
						)
			order by	case @p_order_by
							when 1 then account.code
							when 2 then account.name
							when 3 then account.bank_account_no
						end asc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
		end ;
		else
		begin
			select		*
			from
						(
							select	'ALL' as 'code'
									,'ALL' as 'name'
									,'ALL' as 'bank_account_no'
							union all
							select  branch_bank_code
									,branch_bank_name
									,sbb.bank_account_no 
							from	dbo.bank_mutation bm
									inner join ifinsys.dbo.sys_branch_bank sbb on (sbb.code = bm.branch_bank_code)
							where	bm.branch_code = case @p_branch_code
															when 'all' then bm.branch_code
															else @p_branch_code
														end
						) as account
			where		(
							account.code like '%' + @p_keywords + '%'
							or	account.name like '%' + @p_keywords + '%'
							or	account.bank_account_no like '%' + @p_keywords + '%'
						)
			order by	case @p_order_by
							when 1 then account.code
							when 2 then account.name
							when 2 then account.bank_account_no
						end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
		end ;
	end ;
	ELSE
    BEGIN

			select	@rows_count = count(1)
			from	dbo.bank_mutation bm
					inner join ifinsys.dbo.sys_branch_bank sbb on (sbb.code = bm.branch_bank_code)
			where	bm.branch_code = case @p_branch_code
										when 'ALL' then bm.branch_code
										else @p_branch_code
								  end
			and		(
						bm.branch_bank_code						like '%' + @p_keywords + '%'
						or	bm.branch_bank_name					like '%' + @p_keywords + '%'
						or	sbb.bank_account_no					like '%' + @p_keywords + '%'
					) ;

					select      bm.branch_bank_code
								,bm.branch_bank_name
								,sbb.bank_account_no 
								,@rows_count 'rowcount'
					from		dbo.bank_mutation bm
								inner join ifinsys.dbo.sys_branch_bank sbb on (sbb.code = bm.branch_bank_code)
					where		bm.branch_code = case @p_branch_code
													 when 'ALL' then bm.branch_code
													 else @p_branch_code
												  end
					and			(
									bm.branch_bank_code				like '%' + @p_keywords + '%'
									or	bm.branch_bank_name			like '%' + @p_keywords + '%'
									or	sbb.bank_account_no			like '%' + @p_keywords + '%'
								)
				order by case  
				when @p_sort_by = 'asc' then case @p_order_by
													when 1 then bm.branch_bank_code
													when 2 then sbb.bank_account_no
													when 3 then bm.branch_bank_name
												end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then bm.branch_bank_code
														when 2 then sbb.bank_account_no
														when 3 then bm.branch_bank_name
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

	END
end ;
