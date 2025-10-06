CREATE PROCEDURE [dbo].[xsp_register_delivery_detail_getrow]
(
    @p_id BIGINT
)
AS
BEGIN
    SELECT
         id
        ,delivery_code
        ,register_code
		--
        ,cre_date
        ,cre_by
        ,cre_ip_address
        ,mod_date
        ,mod_by
        ,mod_ip_address
    FROM dbo.register_delivery_detail
    WHERE id = @p_id;
END;
