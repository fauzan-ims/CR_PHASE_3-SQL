CREATE PROCEDURE dbo.xsp_invoice_delivery_getrow
(
	@p_code nvarchar(50)
)
as
begin
	SELECT	invd.code
			,invd.branch_code
			,invd.branch_name
			,invd.status
			,invd.date
			,invd.method
			,invd.employee_code
			,invd.employee_name
			,invd.external_pic_name
			,invd.email
			,invd.remark
			-- Louis Rabu, 02 Juli 2025 10.16.42 -- 
			,invd.delivery_result
			,invd.delivery_received_date
			,invd.delivery_received_by
			,invd.delivery_doc_reff_no
			,invd.delivery_reject_date
			,invd.delivery_reason_code
			--
			,invd.client_no
			,invd.client_address

			,inv.client_name 'billing_to_name'
			,inv.client_name
			,inv.client_area_phone_no 
			,inv.client_phone_no 
			,inv.client_npwp
			,inv.email 'client_email'
			,sgs.description 'delivery_reason_desc'
			,CASE 
					WHEN invd.STATUS IN ('ON PROCESS', 'DONE') THEN DATEDIFF(DAY, invd.DATE, invd.PROCEED_DATE)
					WHEN invd.STATUS = 'HOLD' THEN DATEDIFF(DAY, invd.DATE, dbo.xfn_get_system_date())
					WHEN invd.STATUS = 'CANCEL' THEN 0
					ELSE NULL 
				END AS 'aging'
	-- Louis Rabu, 02 Juli 2025 10.16.42 --  
	FROM	invoice_delivery invd
			left join dbo.sys_general_subcode sgs on (sgs.code = invd.delivery_reason_code)
			outer apply
			(
			select		top 1 
						inv.client_address
						,inv.client_no
						,inv.client_name
						,inv.client_area_phone_no
						,inv.client_phone_no
						,inv.client_npwp
						,ind.email
			from		dbo.invoice_delivery_detail invdd
						inner join dbo.invoice inv on inv.invoice_no = invdd.invoice_no
						outer apply
						(
							select	top 1 aa.email
							from	dbo.invoice_detail ind
									inner join dbo.agreement_asset aa on (aa.asset_no = ind.asset_no)
							where	inv.invoice_no = ind.invoice_no
							group by aa.email
					) ind
				where		invdd.delivery_code = invd.code
			) inv
	where	invd.code = @p_code ;
	
	
	--select	invd.code
	--		,invd.branch_code
	--		,invd.branch_name
	--		,invd.status
	--		,invd.date
	--		,invd.method
	--		,invd.employee_code
	--		,invd.employee_name
	--		,invd.external_pic_name
	--		,invd.email
	--		,invd.remark
	--		-- Louis Rabu, 02 Juli 2025 10.16.42 -- 
	--		,invd.delivery_result
	--		,invd.delivery_received_date
	--		,invd.delivery_received_by
	--		,invd.delivery_doc_reff_no
	--		,invd.delivery_reject_date
	--		,invd.delivery_reason_code
	--		,inv.client_address
	--		,inv.client_no
	--		,inv.client_name 'billing_to_name'
	--		,inv.client_name
	--		,inv.client_area_phone_no 
	--		,inv.client_phone_no 
	--		,inv.client_npwp
	--		,inv.email 'client_email'
	--		,sgs.description 'delivery_reason_desc'
	--		,CASE 
	--				WHEN invd.STATUS IN ('ON PROCESS', 'DONE') THEN DATEDIFF(DAY, invd.DATE, invd.PROCEED_DATE)
	--				WHEN invd.STATUS = 'HOLD' THEN DATEDIFF(DAY, invd.DATE, dbo.xfn_get_system_date())
	--				WHEN invd.STATUS = 'CANCEL' THEN 0
	--				ELSE NULL 
	--			END AS 'aging'
	---- Louis Rabu, 02 Juli 2025 10.16.42 --  
	--from	invoice_delivery invd
	--		left join dbo.sys_general_subcode sgs on (sgs.code = invd.delivery_reason_code)
	--		outer apply
	--(
	--	select		inv.client_address
	--				,inv.client_no
	--				,inv.client_name
	--				,inv.client_area_phone_no
	--				,inv.client_phone_no
	--				,inv.client_npwp
	--				,ind.email
	--	from		dbo.invoice inv
	--				outer apply
	--	(
	--		select	aa.email
	--		from	dbo.invoice_detail ind
	--				inner join dbo.agreement_asset aa on (aa.asset_no = ind.asset_no)
	--		where	inv.invoice_no = ind.invoice_no
	--		group by aa.email
	--	) ind
	--	where		inv.deliver_code = invd.code
	--	group by	inv.client_address
	--				,inv.client_no
	--				,inv.client_name
	--				,inv.client_area_phone_no
	--				,inv.client_phone_no
	--				,inv.client_npwp
	--				,ind.email
	--) inv
	--where	invd.code = @p_code ;
end ;