CREATE PROCEDURE [dbo].[xsp_rpt_invoice_penagihan_group]
(
	@p_user_id		   nvarchar(50)
	--,@p_no_invoice	   nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @invoice_no nvarchar(50) ;

	delete dbo.rpt_invoice_penagihan
	where	user_id = @p_user_id ;

	delete dbo.rpt_invoice_penagihan_detail_asset
	where	user_id = @p_user_id ;

	delete dbo.rpt_invoice_pembatalan_kontrak_detail
	where	user_id = @p_user_id ;

	delete dbo.rpt_invoice_penagihan_detail
	where	user_id = @p_user_id ;

	delete dbo.rpt_invoice_kwitansi
	where	user_id = @p_user_id;

	delete dbo.rpt_invoice_kwitansi_detail
	where	user_id = @p_user_id;

	declare cur_invoice_group cursor local fast_forward read_only for
	select	invoice_no
	from	dbo.rpt_invoice_penagihan_group with (nolock)
	where	user_id = @p_user_id ;

	open cur_invoice_group ;

	fetch next from cur_invoice_group
	into @invoice_no ;

	while @@fetch_status = 0
	begin
		exec dbo.xsp_rpt_invoice_penagihan @p_user_id = @p_user_id -- nvarchar(50)
										   ,@p_no_invoice = @invoice_no -- nvarchar(50)
										   ,@p_cre_date = @p_cre_date -- datetime
										   ,@p_cre_by = @p_cre_by -- nvarchar(15)
										   ,@p_cre_ip_address = @p_cre_ip_address -- nvarchar(15)
										   ,@p_mod_date = @p_cre_date -- datetime
										   ,@p_mod_by = @p_mod_by -- nvarchar(15)
										   ,@p_mod_ip_address = @p_mod_ip_address
										   ,@p_group_print = '1'; -- nvarchar(15)

		fetch next from cur_invoice_group
		into @invoice_no ;
	end ;

	close cur_invoice_group ;
	deallocate cur_invoice_group ;

end ;
