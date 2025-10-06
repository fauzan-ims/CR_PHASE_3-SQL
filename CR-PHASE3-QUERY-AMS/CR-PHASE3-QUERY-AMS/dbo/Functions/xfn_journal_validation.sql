CREATE FUNCTION dbo.xfn_journal_validation
(@p_journal_code	nvarchar(50))
returns nvarchar(max)
as
begin
	
	declare @is_valid int = 1
			,@max_day int
			,@sys_date datetime
			,@max_date datetime
			,@mssg		nvarchar(max)
			,@sum_db	decimal(18,2)
			,@sum_cr	decimal(18,2)

	select	@sum_db = sum(base_amount_db)
			,@sum_cr = sum(base_amount_cr)
	from	dbo.efam_interface_journal_gl_link_transaction_detail
	where	gl_link_transaction_code = @p_journal_code
	
	if exists (select 1 from dbo.efam_interface_journal_gl_link_transaction_detail where gl_link_transaction_code = @p_journal_code and isnull(gl_link_code,'') = '')
		set @mssg = 'Jurnal tidak dapat terbentuk. Silakan setting COA terlebih dahulu'

	if exists (select 1 from dbo.efam_interface_journal_gl_link_transaction_detail where gl_link_transaction_code = @p_journal_code and gl_link_code not in (select code from dbo.journal_gl_link))
		set @mssg = 'Mohon cek kembali settingan jurnal anda, nomor COA yang disetting tidak terdaftar pada sistem'

	if (@sum_db <> @sum_cr)
		set @mssg = 'Jurnal tidak balance, silahkan cek kembali settingan jurnal anda'

    return @mssg;

end
