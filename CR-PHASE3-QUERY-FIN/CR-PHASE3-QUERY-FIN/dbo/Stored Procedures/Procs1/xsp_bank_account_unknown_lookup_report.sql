CREATE PROCEDURE dbo.xsp_bank_account_unknown_lookup_report
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_for_all			nvarchar(1)	= ''
	,@p_bank_code		nvarchar(50) = 'ALL'
)
as
begin
	declare @rows_count int = 0 ;

	if (@p_for_all <> '')
	begin
		select	@rows_count = count(1)
		from
				(
					select 	'ALL' as 'code'
							,'ALL' as 'name'
					union all
					select  bank_account_no
							,bank_account_name
					from	ifinsys.dbo.sys_branch_bank
					where	master_bank_code = case @p_bank_code
													when 'ALL' then master_bank_code
													else @p_bank_code
												end
					and		is_active	= '1'
				) as account
		where	(
					account.code like '%' + @p_keywords + '%'
					or	account.name like '%' + @p_keywords + '%'
				) ;

		if @p_sort_by = 'asc'
		begin
			select		*
			from
						(
							select	'ALL' as 'code'
									,'ALL' as 'name'
									,@rows_count 'rowcount'
							union all
							select  bank_account_no
									,bank_account_name
									,@rows_count 'rowcount'
							from	ifinsys.dbo.sys_branch_bank
							where	master_bank_code = case @p_bank_code
															when 'ALL' then master_bank_code
															else @p_bank_code
														end
							and		is_active	= '1'
						) as account
			where		(
							account.code like '%' + @p_keywords + '%'
							or	account.name like '%' + @p_keywords + '%'
						)
			order by	case @p_order_by
							when 1 then account.code
							when 2 then account.name
						end asc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
		end ;
		else
		begin
			select		*
			from
						(
							select	'ALL' as 'code'
									,'ALL' as 'name'
									,@rows_count 'rowcount'
							union all
							select	bank_account_no
									,bank_account_name
									,@rows_count 'rowcount'
							from	ifinsys.dbo.sys_branch_bank
							where	master_bank_code = case @p_bank_code
															when 'ALL' then master_bank_code
															else @p_bank_code
														end
							and		is_active = '1'
						) as account
			where		(
							account.code like '%' + @p_keywords + '%'
							or	account.name like '%' + @p_keywords + '%'
						)
			order by	case @p_order_by
							when 1 then account.code
							when 2 then account.name
						end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
		end ;
	end ;
	else
	begin

			select	@rows_count = count(1)
			from	ifinsys.dbo.sys_branch_bank
			where	(
						bank_account_no							like '%' + @p_keywords + '%'
						or	bank_account_name					like '%' + @p_keywords + '%'
					) ;

			if @p_sort_by = 'asc'
			begin
				select		bank_account_no
							,bank_account_name
							,@rows_count 'rowcount'
				from		ifinsys.dbo.sys_branch_bank
				where		master_bank_code = case @p_bank_code
													when 'ALL' then master_bank_code
													else @p_bank_code
												end
				and			is_active = '1'
				and			(
								bank_account_no					like '%' + @p_keywords + '%'
								or	bank_account_name			like '%' + @p_keywords + '%'
							)
				order by	case @p_order_by
								when 1 then bank_account_no
								when 2 then bank_account_name
							end asc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
			end ;
			else
			begin
				select      bank_account_no
							,bank_account_name
							,@rows_count 'rowcount'
				from		ifinsys.dbo.sys_branch_bank
				where		master_bank_code = case @p_bank_code
													when 'ALL' then master_bank_code
													else @p_bank_code
												end
				and			is_active = '1'
				and			(
								bank_account_no					like '%' + @p_keywords + '%'
								or	bank_account_name			like '%' + @p_keywords + '%'
							)
				order by	case @p_order_by
								when 1 then bank_account_no
								when 2 then bank_account_name
							end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
			end ;
	end ;
end ;
