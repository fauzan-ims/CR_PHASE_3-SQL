--created by, Rian at 22/05/2023	

CREATE PROCEDURE [dbo].[xsp_application_extention_getrows_for_lookup]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	--
	,@p_client_no		nvarchar(50)
	,@p_level_status	nvarchar(50)
	,@p_application_no  nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;


	-- (+) Ari 2024-01-29 ket : distinct dengan table temp
	declare @table_main_contract	table
	(
		main_contract_no		nvarchar(50)
		,client_no				nvarchar(50)
	)

	declare @table_application_latest	table
	(
		id							bigint
		,application_no				nvarchar(50)
		,main_contract_no			nvarchar(50)
		,main_contract_status		nvarchar(50)
		,main_contract_file_name	nvarchar(250)
		,main_contract_file_path	nvarchar(250)
		,remarks					nvarchar(4000)
	)
	-- (+) Ari 2024-01-29 ket



	--select	@rows_count = count(1)
	--from	dbo.application_extention ae
	--left join	dbo.application_main am on (am.application_no = ae.application_no)
	--where	ae.client_no = @p_client_no
	----and		am.level_status	= @p_level_status
	--and		ae.application_no <> @p_application_no
	--and		isnull(ae.main_contract_file_name, '') <> ''
	--and		(
	--			ae.application_no				like '%' + @p_keywords + '%'
	--			or	ae.main_contract_status		like '%' + @p_keywords + '%'
	--			or	ae.main_contract_no			like '%' + @p_keywords + '%'
	--			or	ae.remarks					like '%' + @p_keywords + '%'
	--		) 

	--select		ae.id
	--		   ,ae.application_no
	--		   ,ae.main_contract_status
	--		   ,ae.main_contract_no
	--		   ,ae.main_contract_file_name
	--		   ,ae.main_contract_file_path
	--		   ,ae.remarks
	--		   ,ae.client_no
	--		   ,@rows_count 'rowcount'
	--from		dbo.application_extention ae
	--left join	dbo.application_main am on (am.application_no = ae.application_no)
	--where		ae.client_no = @p_client_no
	----and			am.level_status	= @p_level_status -- 15112023: (sepria) di tutup karna kalo dari migrasi ngak ada data app_main, dan ini kondisi ini buat apa?
	--and			ae.application_no <> @p_application_no
	--and			isnull(ae.main_contract_file_name, '') <> ''
	--and			(
	--				ae.application_no				like '%' + @p_keywords + '%'
	--				or	ae.main_contract_status		like '%' + @p_keywords + '%'
	--				or	ae.main_contract_no			like '%' + @p_keywords + '%'
	--				or	ae.remarks					like '%' + @p_keywords + '%'
	--			)
	--order by	case
	--				when @p_sort_by = 'asc' then case @p_order_by
	--													when 1 then ae.application_no
	--													when 2 then ae.remarks
	--													when 3 then ae.main_contract_no
	--													when 4 then ae.main_contract_status
	--												end
	--			end asc
	--			,case
	--				 when @p_sort_by = 'desc' then case @p_order_by
	--													when 1 then ae.application_no
	--													when 2 then ae.remarks
	--													when 3 then ae.main_contract_no
	--													when 4 then ae.main_contract_status
	--											   end
	--			 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;



	-- (+) Ari 2024-01-29 ket : get only maincontract (kondisi distinct ini membutuhkan waktu sedikit lebih lama dari query diatas, namun untuk kebutuhan distinct sehingga pakai saja dahulu)
	insert into @table_main_contract
	(
		main_contract_no
		,client_no
	)
	select		distinct
				ae.main_contract_no
			   ,ae.client_no
	from		dbo.application_extention ae
	left join	dbo.application_main am on (am.application_no = ae.application_no)
	where		ae.client_no = @p_client_no
	--and			am.level_status	= @p_level_status -- 15112023: (sepria) di tutup karna kalo dari migrasi ngak ada data app_main, dan ini kondisi ini buat apa?
	and			ae.application_no <> @p_application_no
	and			isnull(ae.main_contract_file_name, '') <> ''
	and			ae.is_valid = '1'
	and			(
					ae.application_no				like '%' + @p_keywords + '%'
					or	ae.main_contract_status		like '%' + @p_keywords + '%'
					or	ae.main_contract_no			like '%' + @p_keywords + '%'
					or	ae.remarks					like '%' + @p_keywords + '%'
				)

	-- (+) Ari 2024-01-29 ket : get application
	insert into @table_application_latest
	(
		id
		,application_no
		,main_contract_no
		,main_contract_status
		,main_contract_file_name
		,main_contract_file_path
		,remarks
	)
	select		ae.id
			   ,ae.application_no
			   ,ae.main_contract_no
			   ,ae.main_contract_status
			   ,ae.main_contract_file_name
			   ,ae.main_contract_file_path
			   ,ae.remarks
	from		dbo.application_extention ae
	left join	dbo.application_main am on (am.application_no = ae.application_no)
	where		ae.client_no = @p_client_no
	--and			am.level_status	= @p_level_status -- 15112023: (sepria) di tutup karna kalo dari migrasi ngak ada data app_main, dan ini kondisi ini buat apa?
	and			ae.application_no <> @p_application_no
	and			isnull(ae.main_contract_file_name, '') <> ''
	and			ae.is_valid = '1'
	and			(
					ae.application_no				like '%' + @p_keywords + '%'
					or	ae.main_contract_status		like '%' + @p_keywords + '%'
					or	ae.main_contract_no			like '%' + @p_keywords + '%'
					or	ae.remarks					like '%' + @p_keywords + '%'
				)

	-- (+) Ari 2024-01-29 ket : get row count
	select	@rows_count = count(1)
	from	@table_main_contract mc
	outer	apply 
	(
			select	top 1
					ml.id
					,ml.application_no
					,ml.main_contract_status
					,ml.main_contract_file_name
					,ml.main_contract_file_path
					,ml.remarks 
			from	@table_application_latest ml
			where	ml.main_contract_no = mc.main_contract_no
			order	by ml.id desc
	) ml

	-- (+) Ari 2024-01-29 ket : show all after distinct
	select	ml.id
			,ml.application_no
			,ml.main_contract_status
			,mc.main_contract_no
			,ml.main_contract_file_name
			,ml.main_contract_file_path
			,ml.remarks
			,mc.client_no
			,@rows_count 'rowcount'
	from	@table_main_contract mc
	outer	apply 
	(
			select	top 1
					ml.id
					,ml.application_no
					,ml.main_contract_status
					,ml.main_contract_file_name
					,ml.main_contract_file_path
					,ml.remarks 
			from	@table_application_latest ml
			where	ml.main_contract_no = mc.main_contract_no
			order	by ml.id desc
	) ml
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then ml.application_no
														when 2 then ml.remarks
														when 3 then mc.main_contract_no
														when 4 then ml.main_contract_status
													end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then ml.application_no
														when 2 then ml.remarks
														when 3 then mc.main_contract_no
														when 4 then ml.main_contract_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	

end ;
