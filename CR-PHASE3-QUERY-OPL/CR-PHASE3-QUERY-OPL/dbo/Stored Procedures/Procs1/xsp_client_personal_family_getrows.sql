CREATE PROCEDURE dbo.xsp_client_personal_family_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_client_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	client_personal_family cpf
			inner join dbo.sys_general_subcode sgs on (sgs.code = cpf.family_type_code)
			inner join dbo.client_main cm on (cm.code			= cpf.family_client_code)
	where	client_code = @p_client_code
			and (
					sgs.description						like '%' + @p_keywords + '%'
					or	cm.client_name					like '%' + @p_keywords + '%'
					or	case cpf.is_emergency_contact
							when '1' then 'Yes'
							else 'No'
						end								like '%' + @p_keywords + '%'
				) ;

		select		cpf.id
					,sgs.description 'family_type_desc'
					,cm.client_name
					,case is_emergency_contact
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_emergency_contact'
					,@rows_count 'rowcount'
		from		client_personal_family cpf
					inner join dbo.sys_general_subcode sgs on (sgs.code = cpf.family_type_code)
					inner join dbo.client_main cm on (cm.code			= cpf.family_client_code)
		where		client_code = @p_client_code
					and (
							sgs.description						like '%' + @p_keywords + '%'
							or	cm.client_name					like '%' + @p_keywords + '%'
							or	case cpf.is_emergency_contact
									when '1' then 'Yes'
									else 'No'
								end								like '%' + @p_keywords + '%'
						)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then sgs.description	
													when 2 then cm.client_name	
													when 3 then cpf.is_emergency_contact
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then sgs.description	
														when 2 then cm.client_name	
														when 3 then cpf.is_emergency_contact
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

