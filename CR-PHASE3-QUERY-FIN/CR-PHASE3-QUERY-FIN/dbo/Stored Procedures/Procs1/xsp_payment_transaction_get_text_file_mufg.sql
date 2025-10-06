--created by, Rian at /06/2023 

CREATE PROCEDURE dbo.xsp_payment_transaction_get_text_file_mufg
(
	@p_code nvarchar(50)
)
as
begin
	select	'"3665IDRCUA' + isnull(branch_bank_account_no, '') + '"' + ',' + '"' + convert(varchar(30), payment_transaction_date, 12) + '"' + ',' + '"' + code + '"' + ',' + '"' + 'Domestic' + '"' + ',' + '"' + payment_orig_currency_code + '"' + ',' + '"' + convert(nvarchar(30), payment_orig_amount) + '"' + ',"","","","",' + '"' + ltrim(rtrim(to_bank_name)) + '"' + ',"",' + '"' + to_bank_account_no + '"' + ',' + '"' + to_bank_account_name + '"' + ',"","99","RRCR0130+","OUR","","","","","","","","","","","",""'
	from	dbo.payment_transaction
	where	CODE = @p_code ;
end ;
