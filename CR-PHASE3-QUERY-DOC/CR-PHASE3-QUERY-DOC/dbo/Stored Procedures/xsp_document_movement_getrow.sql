CREATE PROCEDURE [dbo].[xsp_document_movement_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	dm.code
			,dm.branch_code
			,dm.branch_name
			,dm.movement_status
			,dm.movement_date
			,dm.movement_type
			,dm.movement_location
			,dm.movement_from 
			,dm.movement_to 
			,dm.movement_to_agreement_no
			,dm.movement_to_client_name
			,dm.movement_to_branch_code
			,dm.movement_to_branch_name
			,dm.movement_from_dept_code
			,dm.movement_from_dept_name
			,dm.movement_to_dept_code
			,dm.movement_to_dept_name
			,dm.movement_by_emp_code
			,dm.movement_by_emp_name
			,dm.movement_courier_code
			,dm.movement_remarks
			,dm.receive_date
			,dm.receive_status
			,dm.receive_remark
			,dm.estimate_return_date
			,dm.received_by 'received_by'
			,dm.received_id_no 'received_id_no'
			,dm.received_name 'received_name'
			,dm.file_name
			,dm.paths
			,sgs1.description 'movement_courier_description'
			,sgs2.description 'movement_to_thirdparty_desc'
			,dm.movement_to_thirdparty_type
			,case
				when dm.MOVEMENT_LOCATION='BORROW CLIENT' then '1'
				else '0'
			end 'print_tanda_terima_jaminan'
	from	document_movement dm
			left join dbo.sys_general_subcode sgs1 on (dm.movement_courier_code = sgs1.code)
			left join dbo.sys_general_subcode sgs2 on (dm.movement_to_thirdparty_type = sgs2.code)
	where	dm.code = @p_code ;
end ;
