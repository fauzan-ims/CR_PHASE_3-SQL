CREATE PROCEDURE [dbo].[xsp_invoice_pph_download_template_excel]
(
	@p_overdue_days nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		select	inv.invoice_external_no
				,inv.invoice_date
				,inv.faktur_no
				,inv.invoice_name 'description'
				,invp.total_pph_amount
				,invd.billing_to_npwp 'npwp_no'
				,invd.npwp_name
				,payment_reff_no
				,payment_reff_date
				--fauzan
				,inv.DPP_NILAI_LAIN
		from	dbo.invoice_pph invp
				inner join dbo.invoice inv on (inv.invoice_no = invp.invoice_no)
				outer apply
		(
			select	top 1
					aa.billing_to_npwp
					,aa.npwp_name -- (+) Louis 2023-19-02 ket : add npwp name
			from	dbo.invoice_detail invd
					left join dbo.agreement_main am on (am.agreement_no		= invd.agreement_no)
					left join dbo.agreement_asset aa on (
															aa.agreement_no = invd.agreement_no
															and aa.asset_no = invd.asset_no
														)
			where	invd.invoice_no = inv.invoice_no
		) invd
		where	settlement_status		 = 'HOLD'
				and invp.settlement_type = 'PKP'
				and inv.invoice_status	 = 'PAID'
				and case
						when @p_overdue_days = 'ALL' then 'ALL'
						when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())
							 < 1 then 'LESS THAN 1'
						when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())
							 between 1 and 30 then '1-30'
						when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())
							 between 31 and 60 then '31-60'
						when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())
							 between 61 and 90 then '61-90'
						when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date()) > 90 then 'MORE THAN 90'
					end					 = @p_overdue_days ;
	end try
	begin catch
		set @msg = error_message() ;

		raiserror(@msg, 16, -1) ;

		return @msg ;
	end catch ;
end ;
