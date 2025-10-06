CREATE PROCEDURE dbo.xsp_faktur_no_replacement_msg_validasi
(
	@p_faktur_no_replacement_code			nvarchar(50)
)
as
begin
				
				declare @msg nvarchar(max)
				if exists(select 1 from dbo.FAKTUR_NO_REPLACEMENT where CODE = @p_faktur_no_replacement_code and isnull(validasi, '') = '1')
				BEGIN
				    set @msg = 'There Is an Error For Upload Data, Please Click Button Check Validation For Details'
					raiserror(@msg, 16, 1)
				END

end ;
