
CREATE procedure [dbo].[xsp_master_fintech_silaras_client_getrow]
(
	@p_fintech_code nvarchar(50)
)
as
begin
	select	fintech_code
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
	from	master_fintech_silaras_client
	where	fintech_code = @p_fintech_code ;
end ;

