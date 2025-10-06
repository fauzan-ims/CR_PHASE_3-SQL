
CREATE procedure [dbo].[xsp_sys_client_sipp_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,client_code
			,sipp_kelompok_debtor
			,sipp_kategori_debtor
			,sipp_golongan_debtor
			,sipp_hub_debtor_dg_pp
			,sipp_sektor_ekonomi_debtor
	from	sys_client_sipp
	where	code = @p_code ;
end ;

