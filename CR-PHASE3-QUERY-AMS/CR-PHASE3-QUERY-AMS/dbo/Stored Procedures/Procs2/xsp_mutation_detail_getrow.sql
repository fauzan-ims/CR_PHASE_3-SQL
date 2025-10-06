CREATE PROCEDURE dbo.xsp_mutation_detail_getrow
(
	@p_id bigint
)
as
begin
	select	md.id
			,md.mutation_code
			,md.asset_code
			,md.description
			,md.receive_date
			,md.remark_unpost
			,md.remark_return
			,md.status_received
			--
			,mtn.code
			,mtn.company_code
			,mtn.mutation_date
			,mtn.requestor_code
			,mtn.requestor_name
			,mtn.branch_request_code
			,mtn.branch_request_name
			,mtn.from_branch_code
			,mtn.from_branch_name
			,mtn.from_division_code
			,mtn.from_division_name
			,mtn.from_department_code
			,mtn.from_department_name
			,mtn.from_sub_department_code
			,mtn.from_sub_department_name
			,mtn.from_units_code
			,mtn.from_units_name
			,mtn.from_location_code
			,mtn.from_pic_code
			,mtn.to_branch_code
			,mtn.to_branch_name
			,mtn.to_division_code
			,mtn.to_division_name
			,mtn.to_department_code
			,mtn.to_department_name
			,mtn.to_sub_department_code
			,mtn.to_sub_department_name
			,mtn.to_units_code
			,mtn.to_units_name
			,mtn.to_location_code
			,mtn.to_pic_code
			,mtn.status
			,mtn.remark
			,year(mtn.mutation_date) 'period_year'
			,month(mtn.mutation_date) 'month_year'
			--
			,ass.item_name
	from	mutation_detail md
			inner join dbo.asset ass on (ass.code = md.asset_code)
			inner join dbo.mutation mtn on (mtn.code = md.mutation_code)
	where	id = @p_id ;
end ;
