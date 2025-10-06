CREATE PROCEDURE [dbo].[xsp_document_main_for_return_lookup]
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
	declare @rows_count				  int		   = 0
			,@agreement_no			  nvarchar(50) = null
			,@branch_code			  nvarchar(50)
			,@movement_to_branch_code nvarchar(50)
			,@branch_name			  nvarchar(250)
			,@movement_location		  nvarchar(250)
			,@departement			  nvarchar(50) ;

	select	@branch_code = branch_code
			,@branch_name = branch_name
			,@movement_to_branch_code = movement_to_branch_code
			,@movement_location = movement_location
			,@departement = movement_from_dept_name
	from	dbo.document_movement
	where	code = @p_movement_code ;

	select		@rows_count = count(1)
	from		dbo.document_main dmn
				left join dbo.fixed_asset_main fam on (fam.asset_no = dmn.asset_no)
	where		dmn.locker_position		  = 'OUT LOCKER'
				and dmn.branch_code		  = @branch_code
				and dmn.mutation_location = @movement_location
				and dmn.document_status	  = 'ON BORROW'
				and not exists
	(
		select	dmd.movement_code
		from	dbo.document_movement_detail dmd
		where	dmd.document_code	  = dmn.code
				and dmd.movement_code = @p_movement_code
	) 
				and (
						dmn.document_type	like '%' + @p_keywords + '%'
						or	dmn.asset_no	like '%' + @p_keywords + '%'
						or	fam.reff_no_1	like '%' + @p_keywords + '%'
					);

	select		dmn.code
				,dmn.locker_position
				,dmn.document_status
				,dmn.document_type
				,dmn.asset_no	
				,dmn.asset_name	
				,fam.reff_no_1	
				,fam.reff_no_2	
				,fam.reff_no_3	
				,@rows_count 'rowcount'
	from		dbo.document_main dmn
				left join dbo.fixed_asset_main fam on (fam.asset_no = dmn.asset_no)
	where		dmn.locker_position		  = 'OUT LOCKER'
				and dmn.branch_code		  = @branch_code
				and dmn.mutation_location = @movement_location
				and dmn.document_status	  = 'ON BORROW'
				and not exists
	(
		select	dmd.movement_code
		from	dbo.document_movement_detail dmd
		where	dmd.document_code	  = dmn.code
				and dmd.movement_code = @p_movement_code
	) 
				and (
						dmn.document_type	like '%' + @p_keywords + '%'
						or	dmn.asset_no	like '%' + @p_keywords + '%'
						or	fam.reff_no_1	like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then dmn.document_type
													 when 2 then dmn.asset_no
													 when 3 then fam.reff_no_1
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then dmn.document_type
													   when 2 then dmn.asset_no
													   when 3 then fam.reff_no_1
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
