
create PROCEDURE dbo.xsp_master_application_flow_getrow
(
	@p_code			nvarchar(50)
) as
begin

	select		maf.code
				,maf.description
				,flow_type
				,maf.is_active
				,dim_count
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

	from	master_application_flow maf
			left join dbo.sys_dimension m1 on (m1.code			= maf.dim_1)
			left join dbo.sys_dimension m2 on (m2.code			= maf.dim_2)
			left join dbo.sys_dimension m3 on (m3.code			= maf.dim_3)
			left join dbo.sys_dimension m4 on (m4.code			= maf.dim_4)
			left join dbo.sys_dimension m5 on (m5.code			= maf.dim_5)
			left join dbo.sys_dimension m6 on (m6.code			= maf.dim_6)
			left join dbo.sys_dimension m7 on (m7.code			= maf.dim_7)
			left join dbo.sys_dimension m8 on (m8.code			= maf.dim_8)
			left join dbo.sys_dimension m9 on (m9.code			= maf.dim_9)
			left join dbo.sys_dimension m10 on (m10.code		= maf.dim_10)
	where	maf.code	= @p_code
end
