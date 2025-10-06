
CREATE procedure [dbo].[xsp_master_fintech_silaras_client_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_fintech_silaras_client
	where	(
				fintech_code								like '%' + @p_keywords + '%'
				or	sipp_kelompok_debtor_code				like '%' + @p_keywords + '%'
				or	sipp_kelompok_debtor_ojk_code			like '%' + @p_keywords + '%'
				or	sipp_kelompok_debtor_name				like '%' + @p_keywords + '%'
				or	sipp_kategori_debtor_code				like '%' + @p_keywords + '%'
				or	sipp_kategori_debtor_ojk_code			like '%' + @p_keywords + '%'
				or	sipp_kategori_debtor_name				like '%' + @p_keywords + '%'
				or	sipp_golongan_debtor_code				like '%' + @p_keywords + '%'
				or	sipp_golongan_debtor_ojk_code			like '%' + @p_keywords + '%'
				or	sipp_golongan_debtor_name				like '%' + @p_keywords + '%'
				or	sipp_hub_debtor_dg_pp_code				like '%' + @p_keywords + '%'
				or	sipp_hub_debtor_dg_pp_ojk_code			like '%' + @p_keywords + '%'
				or	sipp_hub_debtor_dg_pp_name				like '%' + @p_keywords + '%'
				or	sipp_sektor_ekonomi_debtor_code			like '%' + @p_keywords + '%'
				or	sipp_sektor_ekonomi_debtor_ojk_code		like '%' + @p_keywords + '%'
				or	sipp_sektor_ekonomi_debtor_name			like '%' + @p_keywords + '%'
			) ;

	select		fintech_code
				,sipp_kelompok_debtor_code
				,sipp_kelompok_debtor_ojk_code
				,sipp_kelompok_debtor_name
				,sipp_kategori_debtor_code
				,sipp_kategori_debtor_ojk_code
				,sipp_kategori_debtor_name
				,sipp_golongan_debtor_code
				,sipp_golongan_debtor_ojk_code
				,sipp_golongan_debtor_name
				,sipp_hub_debtor_dg_pp_code
				,sipp_hub_debtor_dg_pp_ojk_code
				,sipp_hub_debtor_dg_pp_name
				,sipp_sektor_ekonomi_debtor_code
				,sipp_sektor_ekonomi_debtor_ojk_code
				,sipp_sektor_ekonomi_debtor_name
				,@rows_count 'rowcount'
	from		master_fintech_silaras_client
	where		(
					fintech_code								like '%' + @p_keywords + '%'
					or	sipp_kelompok_debtor_code				like '%' + @p_keywords + '%'
					or	sipp_kelompok_debtor_ojk_code			like '%' + @p_keywords + '%'
					or	sipp_kelompok_debtor_name				like '%' + @p_keywords + '%'
					or	sipp_kategori_debtor_code				like '%' + @p_keywords + '%'
					or	sipp_kategori_debtor_ojk_code			like '%' + @p_keywords + '%'
					or	sipp_kategori_debtor_name				like '%' + @p_keywords + '%'
					or	sipp_golongan_debtor_code				like '%' + @p_keywords + '%'
					or	sipp_golongan_debtor_ojk_code			like '%' + @p_keywords + '%'
					or	sipp_golongan_debtor_name				like '%' + @p_keywords + '%'
					or	sipp_hub_debtor_dg_pp_code				like '%' + @p_keywords + '%'
					or	sipp_hub_debtor_dg_pp_ojk_code			like '%' + @p_keywords + '%'
					or	sipp_hub_debtor_dg_pp_name				like '%' + @p_keywords + '%'
					or	sipp_sektor_ekonomi_debtor_code			like '%' + @p_keywords + '%'
					or	sipp_sektor_ekonomi_debtor_ojk_code		like '%' + @p_keywords + '%'
					or	sipp_sektor_ekonomi_debtor_name			like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then fintech_code
													 when 2 then sipp_kelompok_debtor_code
													 when 3 then sipp_kelompok_debtor_ojk_code
													 when 4 then sipp_kelompok_debtor_name
													 when 5 then sipp_kategori_debtor_code
													 when 6 then sipp_kategori_debtor_ojk_code
													 when 7 then sipp_kategori_debtor_name
													 when 8 then sipp_golongan_debtor_code
													 when 9 then sipp_golongan_debtor_ojk_code
													 when 10 then sipp_golongan_debtor_name
													 when 11 then sipp_hub_debtor_dg_pp_code
													 when 12 then sipp_hub_debtor_dg_pp_ojk_code
													 when 13 then sipp_hub_debtor_dg_pp_name
													 when 14 then sipp_sektor_ekonomi_debtor_code
													 when 15 then sipp_sektor_ekonomi_debtor_ojk_code
													 when 16 then sipp_sektor_ekonomi_debtor_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then fintech_code
													   when 2 then sipp_kelompok_debtor_code
													   when 3 then sipp_kelompok_debtor_ojk_code
													   when 4 then sipp_kelompok_debtor_name
													   when 5 then sipp_kategori_debtor_code
													   when 6 then sipp_kategori_debtor_ojk_code
													   when 7 then sipp_kategori_debtor_name
													   when 8 then sipp_golongan_debtor_code
													   when 9 then sipp_golongan_debtor_ojk_code
													   when 10 then sipp_golongan_debtor_name
													   when 11 then sipp_hub_debtor_dg_pp_code
													   when 12 then sipp_hub_debtor_dg_pp_ojk_code
													   when 13 then sipp_hub_debtor_dg_pp_name
													   when 14 then sipp_sektor_ekonomi_debtor_code
													   when 15 then sipp_sektor_ekonomi_debtor_ojk_code
													   when 16 then sipp_sektor_ekonomi_debtor_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

