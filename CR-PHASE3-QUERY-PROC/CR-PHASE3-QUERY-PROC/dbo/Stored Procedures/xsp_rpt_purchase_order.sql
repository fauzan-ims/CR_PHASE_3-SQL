--created, arif at 30-01-2023

CREATE PROCEDURE dbo.xsp_rpt_purchase_order
(
	@p_code			   nvarchar(50)
	,@p_user_id		   nvarchar(50)
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(50)
	,@p_cre_ip_address nvarchar(50)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(50)
	,@p_mod_ip_address nvarchar(50)
)
as
begin
	declare @msg			 nvarchar(max)
			,@report_company nvarchar(250)
			,@report_title	 nvarchar(250) = 'PURCHASE ORDER'
			,@report_image	 nvarchar(250) ;

	delete dbo.rpt_purchase_order
	where	user_id = @p_user_id ;

	delete dbo.rpt_purchase_order_detail
	where	user_id = @p_user_id ;

	select	@report_company = value
	from	dbo.sys_global_param
	where	code = 'COMP2' ;

	select	@report_image = value
	from	dbo.sys_global_param
	where	code = 'IMGDSF' ;

	begin try
		insert into dbo.rpt_purchase_order
		(
			user_id
			,report_company
			,report_title
			,report_image
			,code
			,order_date
			,supplier_name
			,supplier_address
			,shipping_address
			,currency
			,ppn
			,pph
			,total_amount
			,remark
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,po.code
				,po.order_date
				,po.supplier_name
				,po.supplier_address
				,sb.address
				,po.currency_code
				,po.ppn_amount
				,po.pph_amount
				,po.total_amount
				,po.remark
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address 
		from	purchase_order po with (nolock)
				left join ifinsys.dbo.sys_branch sb with (nolock) on (sb.code = po.branch_code)
		where	po.code = @p_code ;

		insert	dbo.rpt_purchase_order_detail
		(
			user_id
			,report_company
			,report_title
			,report_image
			,code
			,item_name
			,uom_name
			,quantity
			,ppn
			,pph
			,price_amount
			,total_amount
			,discount
			,currency
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,po_code
				,item_name
				,uom_name
				,pod.order_quantity
				,pod.ppn_amount
				,pod.pph_amount
				,pod.price_amount
				,(pod.price_amount - pod.discount_amount) * pod.order_quantity 
				,pod.discount_amount
				,po.currency_code
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	purchase_order_detail pod with (nolock)
				inner join purchase_order po with (nolock) on (pod.po_code = po.code)
		where	pod.po_code = @p_code 
		--group by	
		--		pod.po_code
		--		,pod.item_name
		--		,pod.uom_name
		--		,pod.order_quantity
		--		,pod.price_amount
		--		,pod.ppn_amount
		--		,pod.pph_amount
		--		,po.currency_code
		--		,pod.discount_amount

				

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
			set @msg = 'v' + ';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%v;%'
				   or	error_message() like '%e;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'e;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
