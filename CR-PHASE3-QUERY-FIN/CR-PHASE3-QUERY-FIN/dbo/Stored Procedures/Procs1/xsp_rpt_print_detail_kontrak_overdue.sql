--Created, Arif at 02-01-2023

CREATE PROCEDURE [dbo].[xsp_rpt_print_detail_kontrak_overdue]
(
	@p_code				  INT
	,@p_user_id			  NVARCHAR(50)
	,@p_bank_name		  NVARCHAR(4000)
	,@p_bank_account_name NVARCHAR(50)
	,@p_bank_account_no	  NVARCHAR(20)
)
AS
BEGIN
	DECLARE @msg					NVARCHAR(MAX)
			,@report_company		NVARCHAR(250)
			,@report_title			NVARCHAR(250) = 'INVOICE'
			,@report_image			NVARCHAR(250)
			,@invoice_no			NVARCHAR(50) 
			,@company_address		NVARCHAR(4000)
			,@company_phone_no		NVARCHAR(15)
			,@company_phone_area	NVARCHAR(5)
			,@getdate				DATETIME = GETDATE()

	DELETE dbo.RPT_PRINT_DETAIL_KONTRAK_OVERDUE
	WHERE	user_id = @p_user_id ;

	SELECT	@report_company = value
	FROM	dbo.SYS_GLOBAL_PARAM
	WHERE	CODE = 'COMP' ;

	SELECT	@report_image = value
	FROM	dbo.SYS_GLOBAL_PARAM
	WHERE	CODE = 'IMGRPT' ;

	SELECT	@company_address = value
	FROM	dbo.SYS_GLOBAL_PARAM
	WHERE	CODE = 'INVADD' ;

	SELECT	@company_phone_area = value
	FROM	dbo.SYS_GLOBAL_PARAM
	WHERE	CODE = 'TELPAREA' ;

	select	@company_phone_no = value
	from	dbo.SYS_GLOBAL_PARAM
	where	CODE = 'TELP' ;


	begin TRY
    
	INSERT INTO dbo.RPT_PRINT_DETAIL_KONTRAK_OVERDUE
	(
	    USER_ID,
	    AS_OF_DATE,
	    AGREEMENT_NO,
	    ASSET_NAME,
	    ASSET_COUNT,
	    INVOICE_NO,
	    PERIODE,
	    DPP_AMOUNT,
	    PPN_AMOUNT,
	    PPH_AMOUNT,
	    DPP_PPN_PPH,
	    DPP_PPN,
	    INVOICE_DUE_DATE,
	    OVD_DAYS,
	    CRE_DATE,
	    CRE_BY,
	    CRE_IP_ADDRESS,
	    MOD_DATE,
	    MOD_BY,
	    MOD_IP_ADDRESS,
		CLIENT_NO
	)

	SELECT	 @p_user_id
			,@getdate
			,INDET.AGREEMENT_NO
			,INDET.ASSET_NAME
			,INDET.ASSET_COUNT
			,INVOICE.INVOICE_NO
			,'2025-08-08' PERIODE
			,INDET.DPP_AMOUNT
			,INDET.PPN_AMOUNT
			,INDET.PPH_AMOUNT - (2 * indet.PPH_AMOUNT) --biar jadi minus
			,INDET.DPP_AMOUNT+INDET.PPN_AMOUNT-INDET.PPH_AMOUNT 'DPP_PPN_PPH'
			,INDET.DPP_AMOUNT+INDET.PPN_AMOUNT-INDET.PPH_AMOUNT 'DPP_PPN'
			,INVOICE_DUE_DATE
			,DATEDIFF(DAY, INVOICE_DUE_DATE, DBO.XFN_GET_SYSTEM_DATE()) 'OVD_DAYS'
			,DESKCOLL_INVOICE.CRE_DATE
			,DESKCOLL_INVOICE.CRE_BY
			,DESKCOLL_INVOICE.CRE_IP_ADDRESS
			,DESKCOLL_INVOICE.MOD_DATE
			,DESKCOLL_INVOICE.MOD_BY
			,DESKCOLL_INVOICE.MOD_IP_ADDRESS
			,CLIENT_NAME
	FROM DBO.deskcoll_invoice JOIN dbo.INVOICE ON INVOICE.INVOICE_NO = DESKCOLL_INVOICE.INVOICE_NO
    OUTER APPLY
(
    SELECT	INVOICE_DETAIL.AGREEMENT_NO
			,COUNT(ASSET_NAME) AS asset_count
			,ASSET_NAME
			,SUM(BILLING_AMOUNT) AS dpp_amount
			,SUM(PPN_AMOUNT) AS ppn_amount
			,SUM(PPH_AMOUNT) AS pph_amount
    FROM dbo.INVOICE_DETAIL
        JOIN dbo.AGREEMENT_ASSET
            ON AGREEMENT_ASSET.ASSET_NO = INVOICE_DETAIL.ASSET_NO
    WHERE dbo.INVOICE_DETAIL.INVOICE_NO = dbo.deskcoll_invoice.INVOICE_NO
	GROUP BY INVOICE_DETAIL.AGREEMENT_NO, ASSET_NAME
) indet
--WHERE CLIENT_NO = '00125';

WHERE deskcoll_main_id = @p_code;

SELECT SUM(DPP_PPN) SUM_DPP_PPN,SUM(DPP_PPN_PPH) SUM_DPP_PPN_PPH FROM RPT_PRINT_DETAIL_KONTRAK_OVERDUE WHERE USER_ID = @p_user_id

		
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	
end ;
