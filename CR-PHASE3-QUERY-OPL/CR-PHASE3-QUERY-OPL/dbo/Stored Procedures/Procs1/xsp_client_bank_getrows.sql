CREATE PROCEDURE [dbo].[xsp_client_bank_getrows]
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	,@p_client_code		 nvarchar(50)
	,@p_approval_summary nvarchar(1)  = ''
)
as
begin
	declare @rows_count int = 0 ;
	if (@p_approval_summary <> '')
	begin
		select	@rows_count = count(1)
		from	client_bank
		where	client_code = @p_client_code
				and is_default = '1'
				and (
						bank_name					like '%' + @p_keywords + '%'
						or	bank_branch				like '%' + @p_keywords + '%'
						or	bank_account_no			like '%' + @p_keywords + '%'
						or	bank_account_name		like '%' + @p_keywords + '%'
						or	case is_default
								when '1' then 'YES'
								else 'NO'
							end						like '%' + @p_keywords + '%'
					) ;

		select		code
					,code 'client_bank_code'
					,bank_name
					,bank_branch
					,bank_account_no
					,bank_account_name
					,case is_default
							when '1' then 'YES'
							else 'NO'
						end 'is_default'
					,@rows_count 'rowcount'
		from		client_bank
		where		client_code = @p_client_code
					and is_default = '1'
					and (
							bank_name					like '%' + @p_keywords + '%'
							or	bank_branch				like '%' + @p_keywords + '%'
							or	bank_account_no			like '%' + @p_keywords + '%'
							or	bank_account_name		like '%' + @p_keywords + '%'
							or	case is_default
									when '1' then 'YES'
									else 'NO'
								end						like '%' + @p_keywords + '%'
						)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
															when 1 then bank_name
															when 2 then bank_branch
															when 3 then bank_account_no
															when 4 then bank_account_name
															when 5 then is_default
														end
					end asc
					,case
							when @p_sort_by = 'desc' then case @p_order_by
															when 1 then bank_name
															when 2 then bank_branch
															when 3 then bank_account_no
															when 4 then bank_account_name
															when 5 then is_default
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
	end 
	else
	begin
		select	@rows_count = count(1)
		from	client_bank
		where	client_code = @p_client_code
				and (
						bank_name					like '%' + @p_keywords + '%'
						or	bank_branch				like '%' + @p_keywords + '%'
						or	bank_account_no			like '%' + @p_keywords + '%'
						or	bank_account_name		like '%' + @p_keywords + '%'
						or	case is_default
								when '1' then 'YES'
								else 'NO'
							end						like '%' + @p_keywords + '%'
					) ;

		select		code
					,bank_name
					,bank_branch
					,bank_account_no
					,bank_account_name
					,case is_default
							when '1' then 'YES'
							else 'NO'
						end 'is_default'
					,@rows_count 'rowcount'
		from		client_bank
		where		client_code = @p_client_code
					and (
							bank_name					like '%' + @p_keywords + '%'
							or	bank_branch				like '%' + @p_keywords + '%'
							or	bank_account_no			like '%' + @p_keywords + '%'
							or	bank_account_name		like '%' + @p_keywords + '%'
							or	case is_default
									when '1' then 'YES'
									else 'NO'
								end						like '%' + @p_keywords + '%'
						)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
															when 1 then bank_name
															when 2 then bank_branch
															when 3 then bank_account_no
															when 4 then bank_account_name
															when 5 then is_default
														end
					end asc
					,case
							when @p_sort_by = 'desc' then case @p_order_by
															when 1 then bank_name
															when 2 then bank_branch
															when 3 then bank_account_no
															when 4 then bank_account_name
															when 5 then is_default
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
	end
end ;

