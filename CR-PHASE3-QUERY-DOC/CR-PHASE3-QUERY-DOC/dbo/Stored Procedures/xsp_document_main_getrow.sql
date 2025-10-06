CREATE PROCEDURE dbo.xsp_document_main_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	dm.code 
			,dm.branch_code
			,dm.branch_name
			,dm.custody_branch_code
			,dm.custody_branch_name
			,dm.document_type 
			,dm.asset_no
			,dm.asset_name
			,dm.locker_position
			,dm.locker_code
			,dm.drawer_code
			,dm.row_code
			,dm.document_status
			,dm.mutation_type
			,dm.mutation_location
			,dm.mutation_from
			,dm.mutation_to
			,dm.mutation_by
			,dm.mutation_date
			,dm.mutation_return_date
			,dm.last_mutation_type
			,dm.last_mutation_date
			,dm.last_locker_position
			,dm.last_locker_code
			,dm.last_drawer_code
			,dm.last_row_code
			,dm.borrow_thirdparty_type
			,cast(dm.first_receive_date as date) 'first_receive_date'
			,dm.release_customer_date
			,ml.locker_name
			,md.drawer_name
			,mr.row_name
			,ml2.locker_name 'last_locker_name'
			,md2.drawer_name 'last_drawer_name'
			,mr2.row_name	 'last_row_name'
			,dm.is_sold
			,dm.sold_date
			,fam.asset_name
			--,fam.reff_no_1
			--,fam.reff_no_2
			--,fam.reff_no_3
			,isnull(av.plat_no, fam.REFF_NO_1)		'reff_no_1'
			,isnull(av.chassis_no,fam.REFF_NO_2)	'reff_no_2'
			,isnull(av.engine_no,fam.REFF_NO_3)		'reff_no_3'
			,dm.estimate_return_date
	from	document_main dm
			inner join dbo.fixed_asset_main fam on (fam.asset_no = dm.asset_no)
			inner join ifinams.dbo.asset_vehicle av on (dm.asset_no = av.asset_code)
			left join dbo.master_locker ml on ml.code = dm.locker_code
			left join dbo.master_drawer md on md.code = dm.drawer_code
			left join dbo.master_row mr on mr.code = dm.row_code
			left join dbo.master_locker ml2 on ml2.code = dm.last_locker_code
			left join dbo.master_drawer md2 on md2.code = dm.last_drawer_code
			left join dbo.master_row mr2 on mr2.code = dm.last_row_code
	where	dm.code = @p_code ;
end ;
