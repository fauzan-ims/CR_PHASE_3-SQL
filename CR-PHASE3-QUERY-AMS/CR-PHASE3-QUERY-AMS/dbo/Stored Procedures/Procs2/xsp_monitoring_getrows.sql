CREATE PROCEDURE [dbo].[xsp_monitoring_getrows]
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_document_type nvarchar(25)
	,@p_aging		  int = ''
)
as
begin
	declare @rows_count int = 0
			,@doc		NVARCHAR(10) ;

	IF (@p_document_type = 'STNK')
	BEGIN
		SELECT	@rows_count = COUNT(1)
		FROM	dbo.asset					 ass
				INNER JOIN dbo.asset_vehicle av ON (ass.code = av.asset_code)
				OUTER APPLY (SELECT budget_registration_amount FROM ifinopl.dbo.agreement_asset agra WHERE agra.asset_no = ass.asset_no) agreement_asset
		WHERE	ass.code NOT IN
				(
					SELECT	rm.fa_code
					FROM	dbo.register_main rm
					where	rm.register_status NOT IN ('CANCEL', 'DONE')
				)
				--ass.code not in ( 
				--						select	rm.fa_code from dbo.register_main rm 
				--						where	rm.register_status not in ('PAID','CANCEL')

				--					)
				AND ass.status NOT IN
		(
			'SOLD', 'DISPOSED'
		)
				AND (ISNULL(DATEDIFF(DAY, av.stnk_tax_date, (dbo.xfn_get_system_date())), 0) <= CASE @p_aging * -1
																									WHEN '' THEN @p_aging --ISNULL(datediff(day,av.stnk_tax_date,(dbo.xfn_get_system_date())),0)
																									else @p_aging
																								end
					)
				and isnull(av.stnk_tax_date, '') <> ''
				AND (ISNULL(ass.rental_status,'') = '' OR agreement_asset.budget_registration_amount > 0)
				AND
				(
					code																LIKE '%' + @p_keywords + '%'
					OR	ass.item_name													LIKE '%' + @p_keywords + '%'
					OR	av.engine_no													LIKE '%' + @p_keywords + '%'
					OR	av.chassis_no													LIKE '%' + @p_keywords + '%'
					OR	av.plat_no														LIKE '%' + @p_keywords + '%'
					OR	ass.rental_status												LIKE '%' + @p_keywords + '%'
					OR	CONVERT(VARCHAR(50), av.stnk_tax_date, 103)						LIKE '%' + @p_keywords + '%'
					OR	DATEDIFF(DAY, av.stnk_tax_date, (dbo.xfn_get_system_date()))	LIKE '%' + @p_keywords + '%'
				) ;

		set @doc = N'STNK' ;

		select		ass.code
					,ass.item_name
					,av.plat_no
					,av.engine_no
					,av.chassis_no
					,ass.rental_status
					,@doc																	 'document_type'
					,convert(varchar(50), av.stnk_tax_date, 103)							 'expired_date'
					,isnull(datediff(day, av.stnk_tax_date, (dbo.xfn_get_system_date())), 0) 'aging'
					,@rows_count															 'rowcount'
		from		dbo.asset					 ass
					inner join dbo.asset_vehicle av on (ass.code = av.asset_code)
					outer apply (select budget_registration_amount from ifinopl.dbo.agreement_asset agra where agra.asset_no = ass.asset_no) agreement_asset
		where		ass.code not in
					(
						select	rm.fa_code
						from	dbo.register_main rm
						where	rm.register_status NOT IN ('CANCEL', 'DONE')
					)
					--ass.code not in
					--(
					--	select	rm.fa_code
					--	from	dbo.register_main rm
					--	where	rm.register_status not in
					--(
					--	'PAID', 'CANCEL'
					--)
					--		)
					and ass.status not in
		(
			'SOLD', 'DISPOSED'
		)
					and (isnull(datediff(day, av.stnk_tax_date, (dbo.xfn_get_system_date())), 0) <= case @p_aging * -1
																										when '' then @p_aging --ISNULL(datediff(day,av.stnk_tax_date,(dbo.xfn_get_system_date())),0)
																										else @p_aging
																									end
						--OR isnull(av.stnk_tax_date, '')	 < dbo.xfn_get_system_date()
						)
					and isnull(av.stnk_tax_date, '') <> ''
					and (isnull(ass.rental_status,'') = '' or agreement_asset.budget_registration_amount > 0)
					and
					(
						code																like '%' + @p_keywords + '%'
						or	ass.item_name													like '%' + @p_keywords + '%'
						or	av.engine_no													like '%' + @p_keywords + '%'
						or	av.chassis_no													like '%' + @p_keywords + '%'
						or	av.plat_no														like '%' + @p_keywords + '%'
						or	ass.rental_status												like '%' + @p_keywords + '%'
						or	convert(varchar(50), av.stnk_tax_date, 103)						like '%' + @p_keywords + '%'
						or	datediff(day, av.stnk_tax_date, (dbo.xfn_get_system_date()))	like '%' + @p_keywords + '%'
					)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														 when 1 then code
														 when 2 then ass.item_name
														 when 3 then av.plat_no
														 when 4 then @doc
														 when 5 then cast(av.stnk_tax_date as sql_variant)
														 when 6 then ass.rental_status
														 when 7 then cast(datediff(day, av.stnk_tax_date, (dbo.xfn_get_system_date())) as sql_variant)
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
														   when 1 then code
														   when 2 then ass.item_name
														   when 3 then av.plat_no
														   when 4 then @doc
														   when 5 then cast(av.stnk_tax_date as sql_variant)
														   when 6 then ass.rental_status
														   when 7 then cast(datediff(day, av.stnk_tax_date, (dbo.xfn_get_system_date())) as sql_variant)
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
	else
	begin
		select	@rows_count = count(1)
		from	dbo.asset					 ass
				inner join dbo.asset_vehicle av on (ass.code = av.asset_code)
				outer apply (select budget_registration_amount from ifinopl.dbo.agreement_asset agra where agra.asset_no = ass.asset_no) agreement_asset
		where	ass.code not in
				(
					select	rm.fa_code
					from	dbo.register_main rm
					where	rm.register_status NOT IN ('CANCEL', 'DONE')
				)
				--ass.code not in ( 
				--						select	rm.fa_code from dbo.register_main rm 
				--						where	rm.register_status not in ('PAID','CANCEL')

				--					)
				and ass.status not in
		(
			'SOLD', 'DISPOSED'
		)
				and isnull(datediff(day, av.keur_expired_date, (dbo.xfn_get_system_date())), 0) <= case @p_aging * -1
																							   when '' then @p_aging
																							   else @p_aging
																						   end
				and isnull(av.keur_expired_date, '') <> ''
				and (isnull(ass.rental_status,'') = '' or agreement_asset.budget_registration_amount > 0)
				and
				(
					code																like '%' + @p_keywords + '%'
					or	ass.item_name													like '%' + @p_keywords + '%'
					or	av.engine_no													like '%' + @p_keywords + '%'
					or	av.chassis_no													like '%' + @p_keywords + '%'
					or	av.plat_no														like '%' + @p_keywords + '%'
					or	ass.rental_status												like '%' + @p_keywords + '%'
					or	convert(varchar(50), av.keur_expired_date, 103)						like '%' + @p_keywords + '%'
					or	datediff(day, av.keur_expired_date, (dbo.xfn_get_system_date()))	like '%' + @p_keywords + '%'
				) ;

		set @doc = N'KEUR' ;

		select		ass.code
					,ass.item_name
					,av.plat_no
					,av.engine_no
					,av.chassis_no
					,ass.rental_status
					,@doc																 'document_type'
					,convert(varchar(50), av.keur_expired_date, 103)							 'expired_date'
					,isnull(datediff(day, av.keur_expired_date, (dbo.xfn_get_system_date())), 0) 'aging'
					,@rows_count														 'rowcount'
		from		dbo.asset					 ass
					inner join dbo.asset_vehicle av on (ass.code = av.asset_code)
					outer apply (select budget_registration_amount from ifinopl.dbo.agreement_asset agra where agra.asset_no = ass.asset_no) agreement_asset
		where		ass.code not in
					(
						select	rm.fa_code
						from	dbo.register_main rm
						where	rm.register_status NOT IN ('CANCEL', 'DONE')
					)
					--ass.code not in ( 
					--						select	rm.fa_code from dbo.register_main rm 
					--						where	rm.register_status not in ('PAID','CANCEL')

					--					)
					and ass.status not in
		(
			'SOLD', 'DISPOSED'
		)
					and isnull(av.keur_expired_date, '') <> ''
					and (isnull(ass.rental_status,'') = '' or agreement_asset.budget_registration_amount > 0)
					and isnull(datediff(day, av.keur_expired_date, (dbo.xfn_get_system_date())), 0) <= case @p_aging * -1
																								   when '' then @p_aging
																								   else @p_aging
																							   end
					and
					(
						code																like '%' + @p_keywords + '%'
						or	ass.item_name													like '%' + @p_keywords + '%'
						or	av.engine_no													like '%' + @p_keywords + '%'
						or	av.chassis_no													like '%' + @p_keywords + '%'
						or	av.plat_no														like '%' + @p_keywords + '%'
						or	ass.rental_status												like '%' + @p_keywords + '%'
						or	convert(varchar(50), av.keur_expired_date, 103)						like '%' + @p_keywords + '%'
						or	datediff(day, av.keur_expired_date, (dbo.xfn_get_system_date()))	like '%' + @p_keywords + '%'
					)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														 when 1 then code
														 when 2 then ass.item_name
														 when 3 then av.plat_no
														 when 4 then @doc
														 when 5 then cast(av.keur_expired_date as SQL_VARIANT)
														 when 6 then ass.rental_status
														 when 7 then cast(datediff(day, av.keur_expired_date, (dbo.xfn_get_system_date())) as sql_variant)
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
														   when 1 then code
														   when 2 then ass.item_name
														   when 3 then av.plat_no
														   when 4 then @doc
														   when 5 then cast(av.keur_expired_date as sql_variant)
														   when 6 then ass.rental_status
														   when 7 then cast(datediff(day, av.keur_expired_date, (dbo.xfn_get_system_date())) as sql_variant)
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
end ;
