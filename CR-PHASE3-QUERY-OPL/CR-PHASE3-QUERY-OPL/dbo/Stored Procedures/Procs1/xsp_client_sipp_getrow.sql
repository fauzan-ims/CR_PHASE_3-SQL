CREATE PROCEDURE [dbo].[xsp_client_sipp_getrow]
(
	@p_client_code nvarchar(50)
)
as
begin
	select	cs.client_code
			,cs.sipp_kelompok_debtor_code
			,cs.sipp_kategori_debtor_code
			,cs.sipp_golongan_debtor_code
			,cs.sipp_hub_debtor_dg_pp_code
			,cs.sipp_sektor_ekonomi_debtor_code
			,cs.sipp_kelompok_debtor_ojk_code
			,cs.sipp_kategori_debtor_ojk_code
			,cs.sipp_golongan_debtor_ojk_code
			,cs.sipp_hub_debtor_dg_pp_ojk_code
			,cs.sipp_sektor_ekonomi_debtor_ojk_code
			,cs.sipp_kelompok_debtor_name				
			,cs.sipp_kategori_debtor_name				
			,cs.sipp_golongan_debtor_name				
			,cs.sipp_hub_debtor_dg_pp_name				
			,cs.sipp_sektor_ekonomi_debtor_name			
	from	client_sipp cs
	where	cs.client_code = @p_client_code ;
end ;

