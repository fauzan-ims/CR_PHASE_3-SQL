CREATE PROCEDURE dbo.xsp_sys_client_bank_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sys_client_bank
	where	(
				code							like '%' + @p_keywords + '%'
				or	client_code					like '%' + @p_keywords + '%'
				or	currency_code				like '%' + @p_keywords + '%'
				or	bank_code					like '%' + @p_keywords + '%'
				or	bank_name					like '%' + @p_keywords + '%'
				or	bank_branch					like '%' + @p_keywords + '%'
				or	bank_account_no				like '%' + @p_keywords + '%'
				or	bank_account_name			like '%' + @p_keywords + '%'
				or	case is_default
						when '1' then 'YES'
						else 'NO'
					end							like '%' + @p_keywords + '%'
				or	case is_auto_debet_bank
						when '1' then 'YES'
						else 'NO'
					end							like '%' + @p_keywords + '%'
			) ;
			 
		select		code
					,case is_default
						 when '1' then 'YES'
						 else 'NO'
					 end 'is_default'
					,case is_auto_debet_bank
						 when '1' then 'YES'
						 else 'NO'
					 end 'is_auto_debet_bank'
					,@rows_count 'rowcount'
		from		sys_client_bank
		where		(
						code							like '%' + @p_keywords + '%'
						or	client_code					like '%' + @p_keywords + '%'
						or	currency_code				like '%' + @p_keywords + '%'
						or	bank_code					like '%' + @p_keywords + '%'
						or	bank_name					like '%' + @p_keywords + '%'
						or	bank_branch					like '%' + @p_keywords + '%'
						or	bank_account_no				like '%' + @p_keywords + '%'
						or	bank_account_name			like '%' + @p_keywords + '%'
						or	case is_default
								when '1' then 'YES'
								else 'NO'
							end							like '%' + @p_keywords + '%'
						or	case is_auto_debet_bank
								when '1' then 'YES'
								else 'NO'
							end							like '%' + @p_keywords + '%'
					) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then code
													when 2 then client_code
													when 3 then currency_code
													when 4 then bank_code
													when 5 then bank_name
													when 6 then bank_branch
													when 7 then bank_account_no
													when 8 then bank_account_name
													when 9 then is_default
													when 10 then is_auto_debet_bank
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then code
													when 2 then client_code
													when 3 then currency_code
													when 4 then bank_code
													when 5 then bank_name
													when 6 then bank_branch
													when 7 then bank_account_no
													when 8 then bank_account_name
													when 9 then is_default
													when 10 then is_auto_debet_bank
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

