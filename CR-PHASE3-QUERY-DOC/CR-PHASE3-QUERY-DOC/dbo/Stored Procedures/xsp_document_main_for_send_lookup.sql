CREATE PROCEDURE dbo.xsp_document_main_for_send_lookup
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_movement_code nvarchar(50)
)
as
begin
	declare @rows_count					int			= 0 
			,@branch_code				nvarchar(50)
			,@movement_location			nvarchar(50)

	select	@branch_code = branch_code 
			,@movement_location = movement_location
	from	dbo.document_movement
	where	code = @p_movement_code ;

	if @movement_location = 'BORROW CLIENT'
	begin
		select	@rows_count = count(1)
		from	dbo.document_main dmn
				inner join dbo.fixed_asset_main fam on (fam.asset_no = dmn.asset_no)
				left join ifinams.dbo.asset ast on ast.code = fam.asset_no
				outer apply 
					(
						select	ds.remark
						from	dbo.document_storage_detail dsd
								inner join  dbo.document_storage ds on (ds.code = dsd.document_storage_code)
						where	dsd.document_code = dmn.code and ds.mod_date in (
																					select	max(sd.MOD_DATE) 'mod_date'
																					from	dbo.document_storage_detail std
																							inner join  dbo.document_storage sd on (ds.code = dsd.document_storage_code)
																					where	std.document_code = dmn.code
																				)
					) oapdhs
		where	dmn.locker_position		  = 'OUT LOCKER'
				and dmn.branch_code		  = @branch_code
				and dmn.document_status	  = 'ON HAND'
				and isnull(dmn.mutation_location,'') <> 'CLIENT'
				and ((ast.rental_status ='IN USE') OR (ast.CODE = '2008.AST.2312.00041'))
				and not exists
		(
			select	dmd.movement_code
			from	dbo.document_movement_detail dmd
			where	dmd.document_code	  = dmn.code
					and dmd.movement_code = @p_movement_code
		)
		--		and not exists
		--(
		--	select	dm.movement_status
		--	from	dbo.document_movement_detail dmd
		--			inner join dbo.document_movement dm on (dm.code = dmd.movement_code)
		--			inner join dbo.document_main dmm on dmm.code	= dmd.document_code
		--	where	dm.code				   <> @p_movement_code
		--			and document_code	   = dmn.code
		--			and dm.movement_status = 'HOLD'
		--)
				and (
						dmn.document_type	like '%' + @p_keywords + '%'
						or	dmn.asset_no	like '%' + @p_keywords + '%'
						or	dmn.asset_name	like '%' + @p_keywords + '%'
						or	fam.reff_no_1	like '%' + @p_keywords + '%'
						or	fam.reff_no_2	like '%' + @p_keywords + '%'
						or	fam.reff_no_3	like '%' + @p_keywords + '%'
						or	oapdhs.remark	like '%' + @p_keywords + '%'
					) ;

		select		dmn.code
					,dmn.locker_position
					,dmn.document_status
					,dmn.document_type
					,dmn.asset_no	
					,dmn.asset_name	
					,fam.reff_no_1	
					,fam.reff_no_2	
					,fam.reff_no_3	
					,oapdhs.remark
					,@rows_count 'rowcount'
		from		dbo.document_main dmn
					inner join dbo.fixed_asset_main fam on (fam.asset_no = dmn.asset_no)
					left join ifinams.dbo.asset ast on ast.code = fam.asset_no
					outer apply 
					(
						select	ds.remark
						from	dbo.document_storage_detail dsd
								inner join  dbo.document_storage ds on (ds.code = dsd.document_storage_code)
						where	dsd.document_code = dmn.code and ds.mod_date in (
																					select	max(sd.MOD_DATE) 'mod_date'
																					from	dbo.document_storage_detail std
																							inner join  dbo.document_storage sd on (ds.code = dsd.document_storage_code)
																					where	std.document_code = dmn.code
																				)
					) oapdhs
		where		dmn.locker_position		  = 'OUT LOCKER'
					and dmn.branch_code		  = @branch_code
					and dmn.document_status	  = 'ON HAND'
					and isnull(dmn.mutation_location,'') <> 'CLIENT'
					and ((ast.rental_status ='IN USE') OR (ast.CODE = '2008.AST.2312.00041'))
					and not exists
					(
						select	dmd.movement_code
						from	dbo.document_movement_detail dmd
						where	dmd.document_code	  = dmn.code
								and dmd.movement_code = @p_movement_code
					)
		--			and not exists
		--(
		--	select	dm.movement_status
		--	from	dbo.document_movement_detail dmd
		--			inner join dbo.document_movement dm on (dm.code = dmd.movement_code)
		--			inner join dbo.document_main dmm on dmm.code	= dmd.document_code
		--	where	dm.code				   <> @p_movement_code
		--			and document_code	   = dmn.code
		--			and dm.movement_status = 'HOLD'
		--)
					and (
							dmn.document_type	like '%' + @p_keywords + '%'
							or	dmn.asset_no	like '%' + @p_keywords + '%'
							or	dmn.asset_name	like '%' + @p_keywords + '%'
							or	fam.reff_no_1	like '%' + @p_keywords + '%'
							or	fam.reff_no_2	like '%' + @p_keywords + '%'
							or	fam.reff_no_3	like '%' + @p_keywords + '%'
							or	oapdhs.remark	like '%' + @p_keywords + '%'
						)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														 when 1 then dmn.document_type
														 when 2 then dmn.asset_no
														 when 3 then fam.reff_no_1
														 when 4 then oapdhs.remark
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
														   when 1 then dmn.document_type
														   when 2 then dmn.asset_no
														   when 3 then fam.reff_no_1
														   when 4 then oapdhs.remark
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end
	else
	if @movement_location='CLIENT'
	begin
		select	@rows_count = count(1)
		from	dbo.document_main dmn
				inner join dbo.fixed_asset_main fam on (fam.asset_no = dmn.asset_no)
				left join ifinams.dbo.asset ast on ast.code = fam.asset_no
				outer apply 
					(
						select	ds.remark
						from	dbo.document_storage_detail dsd
								inner join  dbo.document_storage ds on (ds.code = dsd.document_storage_code)
						where	dsd.document_code = dmn.code and ds.mod_date in (
																					select	max(sd.MOD_DATE) 'mod_date'
																					from	dbo.document_storage_detail std
																							inner join  dbo.document_storage sd on (ds.code = dsd.document_storage_code)
																					where	std.document_code = dmn.code
																				)
					) oapdhs
		where	dmn.locker_position		  = 'OUT LOCKER'
				and dmn.branch_code		  = @branch_code
				and dmn.document_status	  = 'ON HAND'
				and isnull(dmn.mutation_location,'') <> 'CLIENT'
				and ast.status ='SOLD'
				and not exists
		(
			select	dmd.movement_code
			from	dbo.document_movement_detail dmd
			where	dmd.document_code	  = dmn.code
					and dmd.movement_code = @p_movement_code
		)
		--		and not exists
		--(
		--	select	dm.movement_status
		--	from	dbo.document_movement_detail dmd
		--			inner join dbo.document_movement dm on (dm.code = dmd.movement_code)
		--			inner join dbo.document_main dmm on dmm.code	= dmd.document_code
		--	where	dm.code				   <> @p_movement_code
		--			and document_code	   = dmn.code
		--			and dm.movement_status = 'HOLD'
		--)
				and (
						dmn.document_type	like '%' + @p_keywords + '%'
						or	dmn.asset_no	like '%' + @p_keywords + '%'
						or	dmn.asset_name	like '%' + @p_keywords + '%'
						or	fam.reff_no_1	like '%' + @p_keywords + '%'
						or	fam.reff_no_2	like '%' + @p_keywords + '%'
						or	fam.reff_no_3	like '%' + @p_keywords + '%'
						or	oapdhs.remark	like '%' + @p_keywords + '%'
					) ;

		select		dmn.code
					,dmn.locker_position
					,dmn.document_status
					,dmn.document_type
					,dmn.asset_no	
					,dmn.asset_name	
					,fam.reff_no_1	
					,fam.reff_no_2	
					,fam.reff_no_3	
					,oapdhs.remark
					,@rows_count 'rowcount'
		from		dbo.document_main dmn
					inner join dbo.fixed_asset_main fam on (fam.asset_no = dmn.asset_no)
					left join ifinams.dbo.asset ast on ast.code = fam.asset_no
					outer apply 
					(
						select	ds.remark
						from	dbo.document_storage_detail dsd
								inner join  dbo.document_storage ds on (ds.code = dsd.document_storage_code)
						where	dsd.document_code = dmn.code and ds.mod_date in (
																					select	max(sd.MOD_DATE) 'mod_date'
																					from	dbo.document_storage_detail std
																							inner join  dbo.document_storage sd on (ds.code = dsd.document_storage_code)
																					where	std.document_code = dmn.code
																				)
					) oapdhs
		where		dmn.locker_position		  = 'OUT LOCKER'
					and dmn.branch_code		  = @branch_code
					and dmn.document_status	  = 'ON HAND'
					and isnull(dmn.mutation_location,'') <> 'CLIENT'
					and ast.status ='SOLD'
					and not exists
					(
						select	dmd.movement_code
						from	dbo.document_movement_detail dmd
						where	dmd.document_code	  = dmn.code
								and dmd.movement_code = @p_movement_code
					)
		--			and not exists
		--(
		--	select	dm.movement_status
		--	from	dbo.document_movement_detail dmd
		--			inner join dbo.document_movement dm on (dm.code = dmd.movement_code)
		--			inner join dbo.document_main dmm on dmm.code	= dmd.document_code
		--	where	dm.code				   <> @p_movement_code
		--			and document_code	   = dmn.code
		--			and dm.movement_status = 'HOLD'
		--)
					and (
							dmn.document_type	like '%' + @p_keywords + '%'
							or	dmn.asset_no	like '%' + @p_keywords + '%'
							or	dmn.asset_name	like '%' + @p_keywords + '%'
							or	fam.reff_no_1	like '%' + @p_keywords + '%'
							or	fam.reff_no_2	like '%' + @p_keywords + '%'
							or	fam.reff_no_3	like '%' + @p_keywords + '%'
							or	oapdhs.remark	like '%' + @p_keywords + '%'
						)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														 when 1 then dmn.document_type
														 when 2 then dmn.asset_no
														 when 3 then fam.reff_no_1
														 when 4 then oapdhs.remark
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
														   when 1 then dmn.document_type
														   when 2 then dmn.asset_no
														   when 3 then fam.reff_no_1
														   when 4 then oapdhs.remark
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;		
	end
	else
		select	@rows_count = count(1)
		from	dbo.document_main dmn
				inner join dbo.fixed_asset_main fam on (fam.asset_no = dmn.asset_no)
				left join ifinams.dbo.asset ast on ast.code = fam.asset_no
				outer apply 
					(
						select	ds.remark
						from	dbo.document_storage_detail dsd
								inner join  dbo.document_storage ds on (ds.code = dsd.document_storage_code)
						where	dsd.document_code = dmn.code and ds.mod_date in (
																					select	max(sd.MOD_DATE) 'mod_date'
																					from	dbo.document_storage_detail std
																							inner join  dbo.document_storage sd on (ds.code = dsd.document_storage_code)
																					where	std.document_code = dmn.code
																				)
					) oapdhs
		where	dmn.locker_position		  = 'OUT LOCKER'
				and dmn.branch_code		  = @branch_code
				and dmn.document_status	  = 'ON HAND'
				and isnull(dmn.mutation_location,'') <> 'CLIENT'
				and not exists
		(
			select	dmd.movement_code
			from	dbo.document_movement_detail dmd
			where	dmd.document_code	  = dmn.code
					and dmd.movement_code = @p_movement_code
		)
		--		and not exists
		--(
		--	select	dm.movement_status
		--	from	dbo.document_movement_detail dmd
		--			inner join dbo.document_movement dm on (dm.code = dmd.movement_code)
		--			inner join dbo.document_main dmm on dmm.code	= dmd.document_code
		--	where	dm.code				   <> @p_movement_code
		--			and document_code	   = dmn.code
		--			and dm.movement_status = 'HOLD'
		--)
				and (
						dmn.document_type	like '%' + @p_keywords + '%'
						or	dmn.asset_no	like '%' + @p_keywords + '%'
						or	dmn.asset_name	like '%' + @p_keywords + '%'
						or	fam.reff_no_1	like '%' + @p_keywords + '%'
						or	fam.reff_no_2	like '%' + @p_keywords + '%'
						or	fam.reff_no_3	like '%' + @p_keywords + '%'
						or	oapdhs.remark	like '%' + @p_keywords + '%'
					) ;

		select		dmn.code
					,dmn.locker_position
					,dmn.document_status
					,dmn.document_type
					,dmn.asset_no	
					,dmn.asset_name	
					,fam.reff_no_1	
					,fam.reff_no_2	
					,fam.reff_no_3	
					,oapdhs.remark
					,@rows_count 'rowcount'
		from		dbo.document_main dmn
					inner join dbo.fixed_asset_main fam on (fam.asset_no = dmn.asset_no)
					left join ifinams.dbo.asset ast on ast.code = fam.asset_no
					outer apply 
					(
						select	ds.remark
						from	dbo.document_storage_detail dsd
								inner join  dbo.document_storage ds on (ds.code = dsd.document_storage_code)
						where	dsd.document_code = dmn.code and ds.mod_date in (
																					select	max(sd.MOD_DATE) 'mod_date'
																					from	dbo.document_storage_detail std
																							inner join  dbo.document_storage sd on (ds.code = dsd.document_storage_code)
																					where	std.document_code = dmn.code
																				)
					) oapdhs
		where		dmn.locker_position		  = 'OUT LOCKER'
					and dmn.branch_code		  = @branch_code
					and dmn.document_status	  = 'ON HAND'
					and isnull(dmn.mutation_location,'') <> 'CLIENT'
					and not exists
					(
						select	dmd.movement_code
						from	dbo.document_movement_detail dmd
						where	dmd.document_code	  = dmn.code
								and dmd.movement_code = @p_movement_code
					)
		--			and not exists
		--(
		--	select	dm.movement_status
		--	from	dbo.document_movement_detail dmd
		--			inner join dbo.document_movement dm on (dm.code = dmd.movement_code)
		--			inner join dbo.document_main dmm on dmm.code	= dmd.document_code
		--	where	dm.code				   <> @p_movement_code
		--			and document_code	   = dmn.code
		--			and dm.movement_status = 'HOLD'
		--)
					and (
							dmn.document_type	like '%' + @p_keywords + '%'
							or	dmn.asset_no	like '%' + @p_keywords + '%'
							or	dmn.asset_name	like '%' + @p_keywords + '%'
							or	fam.reff_no_1	like '%' + @p_keywords + '%'
							or	fam.reff_no_2	like '%' + @p_keywords + '%'
							or	fam.reff_no_3	like '%' + @p_keywords + '%'
							or	oapdhs.remark	like '%' + @p_keywords + '%'
						)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														 when 1 then dmn.document_type
														 when 2 then dmn.asset_no
														 when 3 then fam.reff_no_1
														 when 4 then oapdhs.remark
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
														   when 1 then dmn.document_type
														   when 2 then dmn.asset_no
														   when 3 then fam.reff_no_1
														   when 4 then oapdhs.remark
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
	end;

