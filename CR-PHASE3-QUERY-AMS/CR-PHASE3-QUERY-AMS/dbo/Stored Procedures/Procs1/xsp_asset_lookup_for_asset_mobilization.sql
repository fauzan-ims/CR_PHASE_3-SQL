CREATE PROCEDURE dbo.xsp_asset_lookup_for_asset_mobilization
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_branch_code			nvarchar(50)
	,@p_type_code			nvarchar(50) = 'ALL'
	,@p_merk_code			nvarchar(50) = 'ALL'
	,@p_model_code			nvarchar(50) = 'ALL'
	,@p_type_item_code		nvarchar(50) = 'ALL'
	,@p_is_reimburse		nvarchar(10) = '0'
)
as
begin
	declare @rows_count int = 0 ;

	--if exists
	--(
	--	select	1
	--	from	sys_global_param
	--	where	code	  = 'HO'
	--	and		value = @p_branch_code
	--)
	--begin
	--	set @p_branch_code = 'ALL' ;
	--end ;

	if (@p_is_reimburse = '0')
	begin
		select	@rows_count = count(1)
		from
				(
					select	ass.code
							,ass.branch_code
							,ass.branch_name
							,ass.item_name
							,ass.division_code
							,ass.division_name
							,ass.department_code
							,ass.department_name
							,av.built_year
							,ass.type_code
							,sgs.description
							,av.engine_no
							,av.chassis_no
							,av.plat_no
							,av.colour
							,ass.net_book_value_comm
					from	dbo.asset ass
							inner join dbo.sys_general_subcode sgs on (sgs.code = ass.type_code)
							inner join dbo.asset_vehicle av on (av.asset_code	= ass.code)
					where	ass.status in
										(
											'REPLACEMENT', 'STOCK'
										)
							and ass.type_code	  = case @p_type_code
														when 'ALL' then ass.type_code
														else @p_type_code
													end
							and av.merk_code	  = case @p_merk_code
														when 'ALL' then av.merk_code
														else @p_merk_code
													end
							and av.model_code	  = case @p_model_code
														when 'ALL' then av.model_code
														else @p_model_code
													end
							and av.type_item_code = case @p_type_item_code
														when 'ALL' then av.type_item_code
														else @p_type_item_code
													end
							and ass.branch_code	= @p_branch_code
							--and	ass.branch_code = case @p_branch_code
							--		when 'ALL' then ass.branch_code
							--		else @p_branch_code
							--	end	
					union
					select	ass.code
							,ass.branch_code
							,ass.branch_name
							,ass.item_name
							,ass.division_code
							,ass.division_name
							,ass.department_code
							,ass.department_name
							,am.built_year
							,ass.type_code
							,sgs.description
							,am.engine_no
							,am.chassis_no
							,'' as 'plat_no'
							,am.colour
							,ass.net_book_value_comm
					from	dbo.asset ass
							inner join dbo.sys_general_subcode sgs on (sgs.code = ass.type_code)
							inner join dbo.asset_machine am on (am.asset_code	= ass.code)
					where	ass.status in
										(
											'REPLACEMENT', 'STOCK'
										)
							and ass.type_code	  = case @p_type_code
														when 'ALL' then ass.type_code
														else @p_type_code
													end
							and am.merk_code	  = case @p_merk_code
														when 'ALL' then am.merk_code
														else @p_merk_code
													end
							and am.model_code	  = case @p_model_code
														when 'ALL' then am.model_code
														else @p_model_code
													end
							and am.type_item_code = case @p_type_item_code
														when 'ALL' then am.type_item_code
														else @p_type_item_code
													end
							and ass.branch_code	= @p_branch_code
					union
					select	ass.code
							,ass.branch_code
							,ass.branch_name
							,ass.item_name
							,ass.division_code
							,ass.division_name
							,ass.department_code
							,ass.department_name
							,am.built_year
							,ass.type_code
							,sgs.description
							,am.engine_no
							,am.chassis_no
							,'' as 'plat_no'
							,am.colour
							,ass.net_book_value_comm
					from	dbo.asset ass
							inner join dbo.sys_general_subcode sgs on (sgs.code = ass.type_code)
							inner join dbo.asset_he am on (am.asset_code		= ass.code)
					where	ass.status in
										(
											'REPLACEMENT', 'STOCK'
										)
							and ass.type_code	  = case @p_type_code
														when 'ALL' then ass.type_code
														else @p_type_code
													end
							and am.merk_code	  = case @p_merk_code
														when 'ALL' then am.merk_code
														else @p_merk_code
													end
							and am.model_code	  = case @p_model_code
														when 'ALL' then am.model_code
														else @p_model_code
													end
							and am.type_item_code = case @p_type_item_code
														when 'ALL' then am.type_item_code
														else @p_type_item_code
													end
							and ass.branch_code	= @p_branch_code
					union
					select	ass.code
							,ass.branch_code
							,ass.branch_name
							,ass.item_name
							,ass.division_code
							,ass.division_name
							,ass.department_code
							,ass.department_name
							,'' 'built_year'
							,ass.type_code
							,sgs.description
							,'' as 'engine_no'
							,'' as 'chassis_no'
							,'' as 'plat_no'
							,'' as 'colour'
							,ass.net_book_value_comm
					from	dbo.asset ass
							inner join dbo.sys_general_subcode sgs on (sgs.code	 = ass.type_code)
							inner join dbo.asset_electronic ae on (ae.asset_code = ass.code)
					where	ass.status in
										(
											'REPLACEMENT', 'STOCK'
										)
							and ass.type_code	  = case @p_type_code
														when 'ALL' then ass.type_code
														else @p_type_code
													end
							and ae.merk_code	  = case @p_merk_code
														when 'ALL' then ae.merk_code
														else @p_merk_code
													end
							and ae.model_code	  = case @p_model_code
														when 'ALL' then ae.model_code
														else @p_model_code
													end
							and ae.type_item_code = case @p_type_item_code
														when 'ALL' then ae.type_item_code
														else @p_type_item_code
													end
							and ass.branch_code	= @p_branch_code
				) asset
		where	(
					asset.code like '%' + @p_keywords + '%'
					or	asset.item_name like '%' + @p_keywords + '%'
				) ;

		select		*
		from
					(
						select	ass.code
								,ass.branch_code
								,ass.branch_name
								,ass.item_name
								,ass.division_code
								,ass.division_name
								,ass.department_code
								,ass.department_name
								,av.built_year
								,ass.type_code
								,sgs.description
								,av.engine_no
								,av.chassis_no
								,av.plat_no
								,av.colour
								,ass.net_book_value_comm
								,@rows_count 'rowcount'
						from	dbo.asset ass
								inner join dbo.sys_general_subcode sgs on (sgs.code = ass.type_code)
								inner join dbo.asset_vehicle av on (av.asset_code	= ass.code)
						where	ass.status in
											(
												'REPLACEMENT', 'STOCK'
											)
								and ass.type_code	  = case @p_type_code
															when 'ALL' then ass.type_code
															else @p_type_code
														end
								and av.merk_code	  = case @p_merk_code
															when 'ALL' then av.merk_code
															else @p_merk_code
														end
								and av.model_code	  = case @p_model_code
															when 'ALL' then av.model_code
															else @p_model_code
														end
								and av.type_item_code = case @p_type_item_code
															when 'ALL' then av.type_item_code
															else @p_type_item_code
														end
								and ass.branch_code	= @p_branch_code
						union
						select	ass.code
								,ass.branch_code
								,ass.branch_name
								,ass.item_name
								,ass.division_code
								,ass.division_name
								,ass.department_code
								,ass.department_name
								,am.built_year
								,ass.type_code
								,sgs.description
								,am.engine_no
								,am.chassis_no
								,'' as 'plat_no'
								,am.colour
								,ass.net_book_value_comm
								,@rows_count 'rowcount'
						from	dbo.asset ass
								inner join dbo.sys_general_subcode sgs on (sgs.code = ass.type_code)
								inner join dbo.asset_machine am on (am.asset_code	= ass.code)
						where	ass.status in
											(
												'REPLACEMENT', 'STOCK'
											)
								and ass.type_code	  = case @p_type_code
															when 'ALL' then ass.type_code
															else @p_type_code
														end
								and am.merk_code	  = case @p_merk_code
															when 'ALL' then am.merk_code
															else @p_merk_code
														end
								and am.model_code	  = case @p_model_code
															when 'ALL' then am.model_code
															else @p_model_code
														end
								and am.type_item_code = case @p_type_item_code
															when 'ALL' then am.type_item_code
															else @p_type_item_code
														end
								and ass.branch_code	= @p_branch_code
						union
						select	ass.code
								,ass.branch_code
								,ass.branch_name
								,ass.item_name
								,ass.division_code
								,ass.division_name
								,ass.department_code
								,ass.department_name
								,am.built_year
								,ass.type_code
								,sgs.description
								,am.engine_no
								,am.chassis_no
								,'' as 'plat_no'
								,am.colour
								,ass.net_book_value_comm
								,@rows_count 'rowcount'
						from	dbo.asset ass
								inner join dbo.sys_general_subcode sgs on (sgs.code = ass.type_code)
								inner join dbo.asset_he am on (am.asset_code		= ass.code)
						where	ass.status in
											(
												'REPLACEMENT', 'STOCK'
											)
								and ass.type_code	  = case @p_type_code
															when 'ALL' then ass.type_code
															else @p_type_code
														end
								and am.merk_code	  = case @p_merk_code
															when 'ALL' then am.merk_code
															else @p_merk_code
														end
								and am.model_code	  = case @p_model_code
															when 'ALL' then am.model_code
															else @p_model_code
														end
								and am.type_item_code = case @p_type_item_code
															when 'ALL' then am.type_item_code
															else @p_type_item_code
														end
								and ass.branch_code	= @p_branch_code
						union
						select	ass.code
								,ass.branch_code
								,ass.branch_name
								,ass.item_name
								,ass.division_code
								,ass.division_name
								,ass.department_code
								,ass.department_name
								,'' 'built_year'
								,ass.type_code
								,sgs.description
								,'' as 'engine_no'
								,'' as 'chassis_no'
								,'' as 'plat_no'
								,'' as 'colour'
								,ass.net_book_value_comm
								,@rows_count 'rowcount'
						from	dbo.asset ass
								inner join dbo.sys_general_subcode sgs on (sgs.code	 = ass.type_code)
								inner join dbo.asset_electronic ae on (ae.asset_code = ass.code)
						where	ass.status in
											(
												'REPLACEMENT', 'STOCK'
											)
								and ass.type_code	  = case @p_type_code
															when 'ALL' then ass.type_code
															else @p_type_code
														end
								and ae.merk_code	  = case @p_merk_code
															when 'ALL' then ae.merk_code
															else @p_merk_code
														end
								and ae.model_code	  = case @p_model_code
															when 'ALL' then ae.model_code
															else @p_model_code
														end
								and ae.type_item_code = case @p_type_item_code
															when 'ALL' then ae.type_item_code
															else @p_type_item_code
														end
								and ass.branch_code	= @p_branch_code
					) asset
		where		(
						asset.code like '%' + @p_keywords + '%'
						or	asset.item_name like '%' + @p_keywords + '%'
						or	asset.plat_no like '%' + @p_keywords + '%'
					)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														 when 1 then asset.code
														 when 2 then asset.item_name
														 when 3 then asset.plat_no
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
														   when 1 then asset.code
														   when 2 then asset.item_name
														   when 3 then asset.plat_no
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
	else
	begin
		select	@rows_count = count(1)
		from
				(
					select	ass.code
							,ass.branch_code
							,ass.branch_name
							,ass.item_name
							,ass.division_code
							,ass.division_name
							,ass.department_code
							,ass.department_name
							,av.built_year
							,ass.type_code
							,sgs.description
							,av.engine_no
							,av.chassis_no
							,av.plat_no
							,av.colour
							,ass.net_book_value_comm
					from	dbo.asset ass
							inner join dbo.sys_general_subcode sgs on (sgs.code = ass.type_code)
							inner join dbo.asset_vehicle av on (av.asset_code	= ass.code)
					where	ass.status in
										(
											'REPLACEMENT', 'STOCK'
										)
							and	isnull(ass.agreement_no, '') <> ''
							and ass.type_code	  = case @p_type_code
														when 'ALL' then ass.type_code
														else @p_type_code
													end
							and av.merk_code	  = case @p_merk_code
														when 'ALL' then av.merk_code
														else @p_merk_code
													end
							and av.model_code	  = case @p_model_code
														when 'ALL' then av.model_code
														else @p_model_code
													end
							and av.type_item_code = case @p_type_item_code
														when 'ALL' then av.type_item_code
														else @p_type_item_code
													end
							and ass.branch_code	= @p_branch_code
					union
					select	ass.code
							,ass.branch_code
							,ass.branch_name
							,ass.item_name
							,ass.division_code
							,ass.division_name
							,ass.department_code
							,ass.department_name
							,am.built_year
							,ass.type_code
							,sgs.description
							,am.engine_no
							,am.chassis_no
							,'' as 'plat_no'
							,am.colour
							,ass.net_book_value_comm
					from	dbo.asset ass
							inner join dbo.sys_general_subcode sgs on (sgs.code = ass.type_code)
							inner join dbo.asset_machine am on (am.asset_code	= ass.code)
					where	ass.status in
										(
											'REPLACEMENT', 'STOCK'
										)
							and	isnull(ass.agreement_no, '') <> ''
							and ass.type_code	  = case @p_type_code
														when 'ALL' then ass.type_code
														else @p_type_code
													end
							and am.merk_code	  = case @p_merk_code
														when 'ALL' then am.merk_code
														else @p_merk_code
													end
							and am.model_code	  = case @p_model_code
														when 'ALL' then am.model_code
														else @p_model_code
													end
							and am.type_item_code = case @p_type_item_code
														when 'ALL' then am.type_item_code
														else @p_type_item_code
													end
							and ass.branch_code	= @p_branch_code
					union
					select	ass.code
							,ass.branch_code
							,ass.branch_name
							,ass.item_name
							,ass.division_code
							,ass.division_name
							,ass.department_code
							,ass.department_name
							,am.built_year
							,ass.type_code
							,sgs.description
							,am.engine_no
							,am.chassis_no
							,'' as 'plat_no'
							,am.colour
							,ass.net_book_value_comm
					from	dbo.asset ass
							inner join dbo.sys_general_subcode sgs on (sgs.code = ass.type_code)
							inner join dbo.asset_he am on (am.asset_code		= ass.code)
					where	ass.status in
										(
											'REPLACEMENT', 'STOCK'
										)
							and	isnull(ass.agreement_no, '') <> ''
							and ass.type_code	  = case @p_type_code
														when 'ALL' then ass.type_code
														else @p_type_code
													end
							and am.merk_code	  = case @p_merk_code
														when 'ALL' then am.merk_code
														else @p_merk_code
													end
							and am.model_code	  = case @p_model_code
														when 'ALL' then am.model_code
														else @p_model_code
													end
							and am.type_item_code = case @p_type_item_code
														when 'ALL' then am.type_item_code
														else @p_type_item_code
													end
							and ass.branch_code	= @p_branch_code
					union
					select	ass.code
							,ass.branch_code
							,ass.branch_name
							,ass.item_name
							,ass.division_code
							,ass.division_name
							,ass.department_code
							,ass.department_name
							,'' 'built_year'
							,ass.type_code
							,sgs.description
							,'' as 'engine_no'
							,'' as 'chassis_no'
							,'' as 'plat_no'
							,'' as 'colour'
							,ass.net_book_value_comm
					from	dbo.asset ass
							inner join dbo.sys_general_subcode sgs on (sgs.code	 = ass.type_code)
							inner join dbo.asset_electronic ae on (ae.asset_code = ass.code)
					where	ass.status in
										(
											'REPLACEMENT', 'STOCK'
										)
							and	isnull(ass.agreement_no, '') <> ''
							and ass.type_code	  = case @p_type_code
														when 'ALL' then ass.type_code
														else @p_type_code
													end
							and ae.merk_code	  = case @p_merk_code
														when 'ALL' then ae.merk_code
														else @p_merk_code
													end
							and ae.model_code	  = case @p_model_code
														when 'ALL' then ae.model_code
														else @p_model_code
													end
							and ae.type_item_code = case @p_type_item_code
														when 'ALL' then ae.type_item_code
														else @p_type_item_code
													end
							and ass.branch_code	= @p_branch_code
				) asset
		where	(
					asset.code like '%' + @p_keywords + '%'
					or	asset.item_name like '%' + @p_keywords + '%'
				) ;

		select		*
		from
					(
						select	ass.code
								,ass.branch_code
								,ass.branch_name
								,ass.item_name
								,ass.division_code
								,ass.division_name
								,ass.department_code
								,ass.department_name
								,av.built_year
								,ass.type_code
								,sgs.description
								,av.engine_no
								,av.chassis_no
								,av.plat_no
								,av.colour
								,ass.net_book_value_comm
								,@rows_count 'rowcount'
						from	dbo.asset ass
								inner join dbo.sys_general_subcode sgs on (sgs.code = ass.type_code)
								inner join dbo.asset_vehicle av on (av.asset_code	= ass.code)
						where	ass.status in
											(
												'REPLACEMENT', 'STOCK'
											)
								and	isnull(ass.agreement_no, '') <> ''
								and ass.type_code	  = case @p_type_code
															when 'ALL' then ass.type_code
															else @p_type_code
														end
								and av.merk_code	  = case @p_merk_code
															when 'ALL' then av.merk_code
															else @p_merk_code
														end
								and av.model_code	  = case @p_model_code
															when 'ALL' then av.model_code
															else @p_model_code
														end
								and av.type_item_code = case @p_type_item_code
															when 'ALL' then av.type_item_code
															else @p_type_item_code
														end
								and ass.branch_code	= @p_branch_code
						union
						select	ass.code
								,ass.branch_code
								,ass.branch_name
								,ass.item_name
								,ass.division_code
								,ass.division_name
								,ass.department_code
								,ass.department_name
								,am.built_year
								,ass.type_code
								,sgs.description
								,am.engine_no
								,am.chassis_no
								,'' as 'plat_no'
								,am.colour
								,ass.net_book_value_comm
								,@rows_count 'rowcount'
						from	dbo.asset ass
								inner join dbo.sys_general_subcode sgs on (sgs.code = ass.type_code)
								inner join dbo.asset_machine am on (am.asset_code	= ass.code)
						where	ass.status in
											(
												'REPLACEMENT', 'STOCK'
											)
								and	isnull(ass.agreement_no, '') <> ''
								and ass.type_code	  = case @p_type_code
															when 'ALL' then ass.type_code
															else @p_type_code
														end
								and am.merk_code	  = case @p_merk_code
															when 'ALL' then am.merk_code
															else @p_merk_code
														end
								and am.model_code	  = case @p_model_code
															when 'ALL' then am.model_code
															else @p_model_code
														end
								and am.type_item_code = case @p_type_item_code
															when 'ALL' then am.type_item_code
															else @p_type_item_code
														end
								and ass.branch_code	= @p_branch_code
						union
						select	ass.code
								,ass.branch_code
								,ass.branch_name
								,ass.item_name
								,ass.division_code
								,ass.division_name
								,ass.department_code
								,ass.department_name
								,am.built_year
								,ass.type_code
								,sgs.description
								,am.engine_no
								,am.chassis_no
								,'' as 'plat_no'
								,am.colour
								,ass.net_book_value_comm
								,@rows_count 'rowcount'
						from	dbo.asset ass
								inner join dbo.sys_general_subcode sgs on (sgs.code = ass.type_code)
								inner join dbo.asset_he am on (am.asset_code		= ass.code)
						where	ass.status in
											(
												'REPLACEMENT', 'STOCK'
											)
								and	isnull(ass.agreement_no, '') <> ''
								and ass.type_code	  = case @p_type_code
															when 'ALL' then ass.type_code
															else @p_type_code
														end
								and am.merk_code	  = case @p_merk_code
															when 'ALL' then am.merk_code
															else @p_merk_code
														end
								and am.model_code	  = case @p_model_code
															when 'ALL' then am.model_code
															else @p_model_code
														end
								and am.type_item_code = case @p_type_item_code
															when 'ALL' then am.type_item_code
															else @p_type_item_code
														end
								and ass.branch_code	= @p_branch_code
						union
						select	ass.code
								,ass.branch_code
								,ass.branch_name
								,ass.item_name
								,ass.division_code
								,ass.division_name
								,ass.department_code
								,ass.department_name
								,'' 'built_year'
								,ass.type_code
								,sgs.description
								,'' as 'engine_no'
								,'' as 'chassis_no'
								,'' as 'plat_no'
								,'' as 'colour'
								,ass.net_book_value_comm
								,@rows_count 'rowcount'
						from	dbo.asset ass
								inner join dbo.sys_general_subcode sgs on (sgs.code	 = ass.type_code)
								inner join dbo.asset_electronic ae on (ae.asset_code = ass.code)
						where	ass.status in
											(
												'REPLACEMENT', 'STOCK'
											)
								and	isnull(ass.agreement_no, '') <> ''
								and ass.type_code	  = case @p_type_code
															when 'ALL' then ass.type_code
															else @p_type_code
														end
								and ae.merk_code	  = case @p_merk_code
															when 'ALL' then ae.merk_code
															else @p_merk_code
														end
								and ae.model_code	  = case @p_model_code
															when 'ALL' then ae.model_code
															else @p_model_code
														end
								and ae.type_item_code = case @p_type_item_code
															when 'ALL' then ae.type_item_code
															else @p_type_item_code
														end
								and ass.branch_code	= @p_branch_code
					) asset
		where		(
						asset.code				like '%' + @p_keywords + '%'
						or	asset.item_name		like '%' + @p_keywords + '%'
						or	asset.plat_no		like '%' + @p_keywords + '%'
					)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														 when 1 then asset.code
														 when 2 then asset.item_name
														 when 3 then asset.plat_no
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
														   when 1 then asset.code
														   when 2 then asset.item_name
														   when 3 then asset.plat_no
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
end ;
