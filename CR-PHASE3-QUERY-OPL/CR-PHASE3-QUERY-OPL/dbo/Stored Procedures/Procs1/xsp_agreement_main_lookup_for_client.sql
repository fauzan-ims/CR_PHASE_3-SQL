CREATE PROCEDURE dbo.xsp_agreement_main_lookup_for_client
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
	
	-- (+) Ari 2023-09-04 ket : add table temporary
	declare @table_temp	table
	(
		agreement_no			nvarchar(50)
		,client_no				nvarchar(50)
		,client_name			nvarchar(250)	
		,billing_to_name		nvarchar(250)
		,billing_to_area_no		nvarchar(4)
		,billing_to_phone_no	nvarchar(15)
		,billing_to_address		nvarchar(4000)
		,billing_to_npwp		nvarchar(20)
		,npwp_name				nvarchar(250)
		,npwp_address			nvarchar(4000)
		,rowscount				int
	)

	--select	distinct @rows_count = count(1)
	--from	agreement_main am
	--		inner join dbo.agreement_asset aa on (aa.agreement_no = am.agreement_no)
	--where	am.agreement_status = 'GO LIVE'
	--		and
	--		(
	--			client_no				like '%' + @p_keywords + '%'
	--			or	client_name			like '%' + @p_keywords + '%'
	--			or	billing_to_name		like '%' + @p_keywords + '%'
	--			or	billing_to_area_no	like '%' + @p_keywords + '%'
	--			or	billing_to_phone_no	like '%' + @p_keywords + '%'
	--			or	billing_to_address	like '%' + @p_keywords + '%'
	--			or	aa.npwp_name		like '%' + @p_keywords + '%'
	--			or	aa.npwp_address		like '%' + @p_keywords + '%'
	--		) ;

	insert into @table_temp
	(
		--agreement_no
		client_no
		,client_name
		,billing_to_name
		,billing_to_area_no
		,billing_to_phone_no
		,billing_to_address
		,billing_to_npwp
		,npwp_name
		,npwp_address
		--,rowscount
	)
	select		distinct
				--am.agreement_external_no
				client_no
				,am.client_name
				,aa.billing_to_name
				,billing_to_area_no
				,billing_to_phone_no
				,billing_to_address
				,billing_to_npwp
				-- (+) Ari 2023-09-21 ket : add npwp name & address
				,aa.npwp_name
				,aa.npwp_address
				--,@rows_count 'rowcount'
	from		agreement_main am
				inner join dbo.agreement_asset aa on (aa.agreement_no = am.agreement_no)
	where		am.agreement_status = 'GO LIVE'
				and
				(
					client_no						like '%' + @p_keywords + '%'
					or	client_name					like '%' + @p_keywords + '%'
					or	billing_to_name				like '%' + @p_keywords + '%'
					or	billing_to_address			like '%' + @p_keywords + '%'
					or	billing_to_area_no			like '%' + @p_keywords + '%'
					or	billing_to_phone_no			like '%' + @p_keywords + '%'
					or	aa.npwp_name				like '%' + @p_keywords + '%'
					or	aa.npwp_address				like '%' + @p_keywords + '%'
					--or	am.agreement_external_no	like '%' + @p_keywords + '%'
				)

	select	@rows_count = count(1)
	from	@table_temp

	select	--agreement_no
			client_no
		    ,client_name
		    ,billing_to_name
		    ,billing_to_area_no
		    ,billing_to_phone_no
		    ,billing_to_address
		    ,billing_to_npwp
		    ,npwp_name
		    ,npwp_address
		    ,@rows_count 'rowcount' 
	from	@table_temp
	order	by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then client_no + client_name --+ agreement_no
													 --when 2 then billing_to_name
													 --when 3 then billing_to_address
													 when 2 then npwp_name
													 when 3 then npwp_address
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then client_no + client_name --+ agreement_no
													 --when 2 then billing_to_name
													 --when 3 then billing_to_address
													 when 2 then npwp_name
													 when 3 then npwp_address
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end ;
