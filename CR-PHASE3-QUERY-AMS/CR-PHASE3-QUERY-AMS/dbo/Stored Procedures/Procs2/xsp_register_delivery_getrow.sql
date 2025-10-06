CREATE PROCEDURE [dbo].[xsp_register_delivery_getrow]
(
    @p_code            NVARCHAR(50)
)
AS
BEGIN
    SELECT
         code
        ,branch_code
        ,branch_name
        ,date
        ,status
        ,delivery_date
        ,deliver_by
        ,delivery_to_name
        ,delivery_to_area_no
        ,delivery_to_phone_no
        ,delivery_to_address
        ,remark
        ,result
        ,received_date
        ,received_by
        ,resi_no
        ,reject_date
        ,reason_code
        ,reason_desc
		,result_remark
        ,cre_date
        ,cre_by
        ,cre_ip_address
        ,mod_date
        ,mod_by
        ,mod_ip_address
    FROM dbo.REGISTER_DELIVERY
    WHERE CODE = @p_code;
END;
