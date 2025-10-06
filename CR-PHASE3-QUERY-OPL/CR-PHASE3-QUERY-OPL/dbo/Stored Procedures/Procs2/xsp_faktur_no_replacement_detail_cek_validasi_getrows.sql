


CREATE PROCEDURE dbo.xsp_faktur_no_replacement_detail_cek_validasi_getrows
(
	@p_code		   nvarchar(50)
)
as
begin
	select 
		    id
           ,id_upload_data
           ,faktur_no_replacement_code
           ,user_id
           ,upload_date
           ,validasi
           ,cre_date
           ,cre_by
           ,cre_ip_address
           ,mod_date
           ,mod_by
           ,mod_ip_address 
	FROM   dbo.faktur_no_replacement_detail_upload_validasi_1
	WHERE  faktur_no_replacement_code = @p_code
end ;
