CREATE PROCEDURE dbo.xsp_order_main_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	om.code
			,om.branch_code
			,om.order_no
			,om.branch_name
			,om.order_date
			,om.order_status
			,om.order_amount
			,om.order_remarks
			,om.public_service_code
			,mps.public_service_name
			,isnull(cek_stnk.ada,0) 'stnk_ada'
			,om.asset
	from	order_main om
			inner join dbo.master_public_service mps on (mps.code = om.public_service_code)
			outer apply (
				select	top 1
						1 'ada'
				from	dbo.register_main rm
						inner join dbo.register_detail rd on rd.register_code = rm.code
						left join dbo.order_detail od on od.register_code	  = rm.code
				where	(rd.service_code	  = 'PBSPSTN' or rd.service_code like '%STNK%')
						and od.order_code = om.code
			) cek_stnk
	where	om.code = @p_code ;
end ;
