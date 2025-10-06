create procedure [dbo].[xsp_inquiry_client_master_contract_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	--
	,@p_client_no  nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.master_contract
	where	CLIENT_CODE = @p_client_no
			and
			(
				main_contract_no like '%' + @p_keywords + '%'
				or	convert(varchar(15), date, 103) like '%' + @p_keywords + '%'
				or	case
						when contract_standart = 'NONSTANDART' then 'NON STANDART'
						else contract_standart
					end like '%' + @p_keywords + '%'
				or	status like '%' + @p_keywords + '%'
			) ;

	select		main_contract_no
				,status
				,convert(nvarchar(30), date, 103) 'date'
				,case
					 when contract_standart = 'NONSTANDART' then 'NON STANDART'
					 else contract_standart
				 end							  'contract_standart'
				,client_name
				,@rows_count					  'rowcount'
	from		dbo.master_contract
	where		client_code = @p_client_no
				and
				(
					main_contract_no like '%' + @p_keywords + '%'
					or	convert(varchar(15), date, 103) like '%' + @p_keywords + '%'
					or	case
							when contract_standart = 'NONSTANDART' then 'NON STANDART'
							else contract_standart
						end like '%' + @p_keywords + '%'
					or	status like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then main_contract_no
													 when 2 then cast(date as sql_variant)
													 when 3 then contract_standart
													 when 4 then status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then main_contract_no
													   when 2 then cast(date as sql_variant)
													   when 3 then contract_standart
													   when 4 then status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
