CREATE procedure dbo.xsp_asset_mutation_history_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,asset_code
			,date
			,document_refference_no
			,document_refference_type
			,usage_duration
			,from_branch_code
			,from_branch_name
			,to_branch_code
			,to_branch_name
			,from_location_code
			,to_location_code
			,from_pic_code
			,to_pic_code
			,from_division_code
			,from_division_name
			,to_division_code
			,to_division_name
			,from_department_code
			,from_department_name
			,to_department_code
			,to_department_name
			,from_sub_department_code
			,from_sub_department_name
			,to_sub_department_code
			,to_sub_department_name
			,from_unit_code
			,from_unit_name
			,to_unit_code
			,to_unit_name
	from	asset_mutation_history
	where	id = @p_id ;
end ;
