-- Louis Selasa, 20 Juni 2023 10.54.12 -- 
-- sp ini digunakan intergrasi
CREATE PROCEDURE dbo.xsp_get_application_or_agreement_info_for_external
(
	@p_data_type	nvarchar(50)
	,@p_customer_no nvarchar(50) = null
)
as
begin
	if (@p_data_type = 'AGREEMENT')
	begin
		select	am.agreement_external_no 'AgreementNo'
				,am.agreement_status 'Status'
				,am.client_no 'CustomerNo'
				,isnull(aaa.billing_amount, 0) + isnull(inv.total_billing_amount, 0) 'OutstandingAR' --dbo.xfn_agreement_get_invoice_ar_amount(am.agreement_no, getdate()) 'OutstandingAR'
				,isnull(ass.net_book, 0) + isnull(aa2.asset_amount, 0) 'OutstandingNI' --isnull(aa.OutstandingNI, 0) 'OutstandingNI'
				,am.periode 'Tenor'
				,aa.lease_amount 'Installment'
				,ass.purchase_price 'ntf'
				,aa.asset_type
				,ai.ovd_days 'CurrentOverdue'
				,ai.max_ovd_days 'MaxOverdue'
				,ai.current_installment_no 'CurrentInstallmentNo'
				,ai.maturity_date 'MaturityDate'
				,aa.count_asset 'NumOfAsset'
		from	agreement_main am
				inner join dbo.agreement_information ai on (ai.agreement_no = am.agreement_no) 
				outer apply
		(
			select	count(1) 'count_asset'
					,sum(aa.lease_rounded_amount) 'lease_amount'
					,sum(aa.asset_amount) 'asset_amount'
					,stuff((
							   select	',' + aa.asset_name
							   from		dbo.agreement_asset aa
							   where	aa.agreement_no = am.agreement_no
							   for xml path('')
						   ), 1, 1, ''
						  ) 'asset_type'
			from	dbo.agreement_asset aa
			where	aa.agreement_no = am.agreement_no
					and aa.asset_status = 'RENTED'
		) aa
				outer apply
		(
			select	sum(aa.asset_amount) 'asset_amount'
			from	dbo.agreement_asset aa
			where	aa.agreement_no = am.agreement_no
					and aa.asset_status = 'RENTED'
					and isnull(aa.fa_code, '') = ''
		) aa2
				outer apply
		(
			select	sum(ass.net_book_value_comm) 'net_book'
					,sum(ass.purchase_price) 'purchase_price'
			from	ifinams.dbo.asset ass
			where	ass.agreement_no = am.agreement_no
					and ass.status = 'STOCK'
		) ass
		outer apply (
 			select	sum(billing_amount) billing_amount
 			from	agreement_asset_amortization aaa
					left join dbo.invoice inv on inv.invoice_no = aaa.invoice_no
 			where	agreement_no = am.agreement_no
 			and		(isnull(aaa.invoice_no, '') = '' or isnull(inv.invoice_status,'') <> 'PAID')
		) osRent
				outer apply
		(
			select	sum(aaa.billing_amount) 'billing_amount'
			from	dbo.agreement_asset_amortization aaa
					inner join dbo.agreement_asset aa on (aa.asset_no = aaa.asset_no)
			where	aaa.agreement_no			   = am.agreement_no
					and isnull(aaa.invoice_no, '') = ''
					and aa.asset_status = 'RENTED'
		) aaa
				outer apply
		(
			select	sum(inv.total_billing_amount) 'total_billing_amount'
			from	dbo.invoice_detail invd
					inner join dbo.invoice inv on (inv.invoice_no = invd.invoice_no)
			where	invd.agreement_no = am.agreement_no
					and inv.invoice_status not in
		(
			'PAID', 'CANCEL'
		)
		) inv
		where	am.client_no = isnull(@p_customer_no, am.client_no)
				and am.agreement_status in
		(
			'GO LIVE', 'TERMINATE'
		) ;
	end ;
	else if (@p_data_type = 'APPLICATION')
	begin
		select	am.application_external_no 'ApplicationNo'
				,am.application_status 'Status'
				,cm.client_no 'CustomerNo'
				,aa.lease_amount 'OutstandingAR' --dbo.xfn_agreement_get_invoice_ar_amount(am.agreement_no, getdate()) 'OutstandingAR'
				,isnull(aa.OutstandingNI, 0) + isnull(aa2.asset_amount, 0) 'OutstandingNI'
				,am.periode 'Tenor'
				,aa.lease_amount 'Installment'
				,isnull(aa.OutstandingNI, 0) + isnull(aa2.asset_amount, 0) 'ntf'
				,aa.asset_type
				,aa.count_asset 'NumOfAsset'
		from	dbo.application_main am
				inner join dbo.client_main cm on (cm.code = am.client_code)
				outer apply
		(
			select	sum(ass.purchase_price) 'OutstandingNI'
					,count(1) 'count_asset'
					,sum(aa.lease_rounded_amount) 'lease_amount'
					,sum(aa.asset_amount) 'asset_amount'
					,stuff((
							   select	',' + aa.asset_name
							   from		dbo.application_asset aa
							   where	aa.application_no = am.application_no
							   for xml path('')
						   ), 1, 1, ''
						  ) 'asset_type'
			from	dbo.application_asset aa
					outer apply
					(
						select	sum(ass.net_book_value_comm) 'net_book'
								,sum(ass.purchase_price) 'purchase_price'
						from	ifinams.dbo.asset ass
						where	ass.code = aa.fa_code
								and ass.status = 'STOCK'
					) ass
			where	aa.application_no = am.application_no
		) aa
		outer apply
		(
			select	sum(aa.asset_amount) 'asset_amount'
			from	dbo.application_asset aa
			where	aa.application_no = am.application_no 
					and isnull(aa.fa_code, '') = ''
		) aa2
		where	cm.client_no			  = isnull(@p_customer_no, cm.client_no)
				--and am.application_status = 'GO LIVE'
				--and am.level_status		  = 'ALLOCATION'
				and am.application_status in
				(
					N'ON PROCESS', N'APPROVE', N'GO LIVE'
				)
				and am.is_simulation	  = '0' 
				and am.application_no not in (select application_no from dbo.agreement_main with (nolock))
	end ;
end ;
