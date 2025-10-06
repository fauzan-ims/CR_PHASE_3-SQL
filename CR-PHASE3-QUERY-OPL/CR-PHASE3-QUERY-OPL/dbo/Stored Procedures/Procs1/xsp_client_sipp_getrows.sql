CREATE PROCEDURE dbo.xsp_client_sipp_getrows
(
	@p_keywords	    nvarchar(50)
	,@p_pagenumber  int
	,@p_rowspage    int
	,@p_order_by    int
	,@p_sort_by	    nvarchar(5)
	,@p_client_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	client_sipp cs
	where	client_code = @p_client_code
			and (
					sipp_kelompok_debtor_name			like '%' + @p_keywords + '%'
					or	sipp_kategori_debtor_name		like '%' + @p_keywords + '%'
					or	sipp_golongan_debtor_name		like '%' + @p_keywords + '%'
					or	sipp_hub_debtor_dg_pp_name		like '%' + @p_keywords + '%'
					or	sipp_sektor_ekonomi_debtor_name	like '%' + @p_keywords + '%'
				) ;
			 
		select		client_code
					,sipp_kelompok_debtor_name 'sipp_kelompok_debtor_desc'		
					,sipp_kategori_debtor_name 'sipp_kategori_debtor_desc'		
					,sipp_golongan_debtor_name 'sipp_golongan_debtor_desc'		
					,sipp_hub_debtor_dg_pp_name 'sipp_hub_debtor_dg_pp_desc'	
					,sipp_sektor_ekonomi_debtor_name 'sipp_sektor_ekonomi_debtor_desc'
					,@rows_count 'rowcount'
		from		client_sipp cs
		where		client_code = @p_client_code
					and (
							sipp_kelompok_debtor_name			like '%' + @p_keywords + '%'
							or	sipp_kategori_debtor_name		like '%' + @p_keywords + '%'
							or	sipp_golongan_debtor_name		like '%' + @p_keywords + '%'
							or	sipp_hub_debtor_dg_pp_name		like '%' + @p_keywords + '%'
							or	sipp_sektor_ekonomi_debtor_name	like '%' + @p_keywords + '%'
						)  
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
												when 1 then sipp_kelompok_debtor_name
												when 2 then sipp_kategori_debtor_name
												when 3 then sipp_golongan_debtor_name
												when 4 then sipp_hub_debtor_dg_pp_name
												when 5 then sipp_sektor_ekonomi_debtor_name
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
												when 1 then sipp_kelompok_debtor_name
												when 2 then sipp_kategori_debtor_name
												when 3 then sipp_golongan_debtor_name
												when 4 then sipp_hub_debtor_dg_pp_name
												when 5 then sipp_sektor_ekonomi_debtor_name
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

