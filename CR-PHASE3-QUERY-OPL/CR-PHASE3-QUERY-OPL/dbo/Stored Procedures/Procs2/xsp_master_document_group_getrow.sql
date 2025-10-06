
CREATE PROCEDURE [dbo].[xsp_master_document_group_getrow]
(
	@p_code			nvarchar(50)
) as
begin

	select		mdg.code
				,mdg.description
				,dim_count
				,document_group_type_code
				,sgs.DESCRIPTION 'document_group_type_name'
				,dim_1
				,m1.description 'dimension1_name'
				,operator_1
				,dim_value_from_1
				,dim_value_to_1
				,dim_2
				,m2.description 'dimension2_name'
				,operator_2
				,dim_value_from_2
				,dim_value_to_2
				,dim_3
				,m3.description 'dimension3_name'
				,operator_3
				,dim_value_from_3
				,dim_value_to_3
				,dim_4
				,m4.description 'dimension4_name'
				,operator_4
				,dim_value_from_4
				,dim_value_to_4
				,dim_5
				,m5.description 'dimension5_name'
				,operator_5
				,dim_value_from_5
				,dim_value_to_5
				,dim_6
				,m6.description 'dimension6_name'
				,operator_6
				,dim_value_from_6
				,dim_value_to_6
				,dim_7
				,m7.description 'dimension7_name'
				,operator_7
				,dim_value_from_7
				,dim_value_to_7
				,dim_8
				,m8.description 'dimension8_name'
				,operator_8
				,dim_value_from_8
				,dim_value_to_8
				,dim_9
				,m9.description 'dimension9_name'
				,operator_9
				,dim_value_from_9
				,dim_value_to_9
				,dim_10
				,m10.description 'dimension10_name'
				,operator_10
				,dim_value_from_10
				,dim_value_to_10
				,mdg.is_active
	from	master_document_group mdg
			inner join dbo.sys_general_subcode sgs on (sgs.code = mdg.document_group_type_code)
			left join dbo.sys_dimension m1 on (m1.code			= mdg.dim_1)
			left join dbo.sys_dimension m2 on (m2.code			= mdg.dim_2)
			left join dbo.sys_dimension m3 on (m3.code			= mdg.dim_3)
			left join dbo.sys_dimension m4 on (m4.code			= mdg.dim_4)
			left join dbo.sys_dimension m5 on (m5.code			= mdg.dim_5)
			left join dbo.sys_dimension m6 on (m6.code			= mdg.dim_6)
			left join dbo.sys_dimension m7 on (m7.code			= mdg.dim_7)
			left join dbo.sys_dimension m8 on (m8.code			= mdg.dim_8)
			left join dbo.sys_dimension m9 on (m9.code			= mdg.dim_9)
			left join dbo.sys_dimension m10 on (m10.code		= mdg.dim_10)
	where	mdg.code	= @p_code
end
