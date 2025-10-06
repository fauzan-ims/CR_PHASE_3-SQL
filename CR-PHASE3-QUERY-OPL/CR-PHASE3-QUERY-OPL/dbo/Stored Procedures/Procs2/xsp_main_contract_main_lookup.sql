CREATE procedure [dbo].[xsp_main_contract_main_lookup]
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	--				   
	,@p_client_no	   nvarchar(50)
	,@p_application_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	main_contract_main mcm with (nolock)
			outer apply
	(
		select		ae.main_contract_no
					,ae.is_valid
		from		dbo.application_extention ae
		where		ae.main_contract_no = mcm.main_contract_no
		group by	ae.main_contract_no
					,ae.is_valid
	) ae
	where	mcm.client_no								= @p_client_no
			and isnull(mcm.main_contract_file_name, '') <> ''
			and mcm.main_contract_no not in
				(
					select	main_contract_no
					from	dbo.application_extention with (nolock)
					where	application_no = @p_application_no
				)
			and ae.is_valid								= '1' 
			and
			(
				mcm.main_contract_no								like '%' + @p_keywords + '%'
				or	mcm.remarks										like '%' + @p_keywords + '%'
				or	case
						when mcm.is_standart = '1' then 'Standart'
						else 'Non Standart'
					end												like '%' + @p_keywords + '%'
			) ;

	select		id
				,mcm.main_contract_no
				,main_contract_file_name
				,main_contract_file_path
				,client_no
				,remarks
				,case
					 when is_standart = '1' then 'Standart'
					 else 'Non Standart'
				 end is_standart
				,@rows_count 'rowcount'
	from		main_contract_main mcm with (nolock)
				outer apply
	(
		select		ae.main_contract_no
					,ae.is_valid
		from		dbo.application_extention ae
		where		ae.main_contract_no = mcm.main_contract_no
		group by	ae.main_contract_no
					,ae.is_valid
	) ae
	where		mcm.client_no								= @p_client_no
				and isnull(mcm.main_contract_file_name, '') <> ''
				and mcm.main_contract_no not in
					(
						select	main_contract_no
						from	dbo.application_extention with (nolock)
						where	application_no = @p_application_no
					)
				and ae.is_valid								= '1' 
				and
				(
					mcm.main_contract_no								like '%' + @p_keywords + '%'
					or	mcm.remarks										like '%' + @p_keywords + '%'
					or	case
							when mcm.is_standart = '1' then 'Standart'
							else 'Non Standart'
						end												like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mcm.main_contract_no
													 when 2 then remarks
													 when 3 then case
																	 when is_standart = '1' then 'Standart'
																	 else 'Non Standart'
																 end
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then mcm.main_contract_no
													   when 2 then remarks
													   when 3 then case
																	   when is_standart = '1' then 'Standart'
																	   else 'Non Standart'
																   end
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
