CREATE PROCEDURE dbo.xsp_master_email_notification_broadcast
(
	@p_code					nvarchar(15)
	,@p_doc_code			nvarchar(100)
	,@p_attachment_flag		int = 0
	,@p_attachment_file		nvarchar(4000) = ''
	,@p_attachment_path		nvarchar(4000) = ''
	,@p_company_code		nvarchar(50)
	,@p_trx_no				nvarchar(50)
	,@p_trx_type			nvarchar(50)
) as
begin

 print '1'
	
end
