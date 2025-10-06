--created, arif at 27-01-2023

CREATE PROCEDURE dbo.xsp_rpt_good_receipt_note
(
	@p_code			   NVARCHAR(50) --maturity_code
	,@p_user_id		   NVARCHAR(50)
	,@p_cre_date	   DATETIME
	,@p_cre_by		   NVARCHAR(50)
	,@p_cre_ip_address NVARCHAR(50)
	,@p_mod_date	   DATETIME
	,@p_mod_by		   NVARCHAR(50)
	,@p_mod_ip_address NVARCHAR(50)
)
AS
BEGIN
	declare @msg			 nvarchar(max)
			,@report_company nvarchar(250)
			,@report_title	 nvarchar(250) = 'GOODS RECEIPT NOTE'
			,@report_image	 nvarchar(250) ;

	delete dbo.rpt_good_receipt_note
	where	user_id = @p_user_id ;

	delete dbo.rpt_good_receipt_note_detail
	where	user_id = @p_user_id ;

	select	@report_company = value
	from	dbo.sys_global_param
	where	code = 'COMP' ;

	select	@report_image = value
	from	dbo.sys_global_param
	where	code = 'IMGDSF' ;

	BEGIN TRY
		INSERT INTO dbo.rpt_good_receipt_note
		(
			user_id
			,report_company
			,report_title
			,report_image
			,grn_code
			,purchase_order_code
			,supplier_name
			,receive_date
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		SELECT	@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,code
				,purchase_order_code
				,supplier_name
				,receive_date
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		FROM	dbo.good_receipt_note
		WHERE	code = @p_code ;

		INSERT	dbo.rpt_good_receipt_note_detail
		(
			user_id
			,report_company
			,report_title
			,report_image
			,good_receipt_note_code
			,item_code
			,item_name
			,uom_name
			,price_amount
			,po_quantity
			,receive_quantity
			,chassis_no
			,engine_no
			,plat_no
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
				,good_receipt_note_code
				,item_code
				,item_name
				,uom_name
				,price_amount
				,po_quantity
				,receive_quantity
				,podo.chassis_no
				,podo.engine_no
				,podo.plat_no
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.good_receipt_note_detail grnd
		left join dbo.purchase_order_detail_object_info podo on podo.good_receipt_note_detail_id = grnd.id
		where	good_receipt_note_code = @p_code ;


		IF NOT EXISTS (SELECT * FROM dbo.RPT_GOOD_RECEIPT_NOTE WHERE USER_ID = @p_user_id)
		BEGIN
        INSERT INTO dbo.RPT_GOOD_RECEIPT_NOTE
        (
            USER_ID,
            REPORT_COMPANY,
            REPORT_TITLE,
            REPORT_IMAGE,
            GRN_CODE,
            PURCHASE_ORDER_CODE,
            SUPPLIER_NAME,
            RECEIVE_DATE,
            CRE_DATE,
            CRE_BY,
            CRE_IP_ADDRESS,
            MOD_DATE,
            MOD_BY,
            MOD_IP_ADDRESS
        )
        VALUES
        (   @p_user_id, -- USER_ID - nvarchar(50)
            @report_company, -- REPORT_COMPANY - nvarchar(250)
            @report_image, -- REPORT_TITLE - nvarchar(250)
            @report_title, -- REPORT_IMAGE - nvarchar(250)
            NULL, -- GRN_CODE - nvarchar(50)
            NULL, -- PURCHASE_ORDER_CODE - nvarchar(50)
            NULL, -- SUPPLIER_NAME - nvarchar(50)
            NULL, -- RECEIVE_DATE - datetime
            NULL, -- CRE_DATE - datetime
            NULL, -- CRE_BY - nvarchar(15)
            NULL, -- CRE_IP_ADDRESS - nvarchar(15)
            @p_mod_date, -- MOD_DATE - datetime
            @p_mod_by, -- MOD_BY - nvarchar(15)
            @p_mod_ip_address  -- MOD_IP_ADDRESS - nvarchar(15)
            )

		END

		IF NOT EXISTS (SELECT * FROM dbo.RPT_GOOD_RECEIPT_NOTE_DETAIL WHERE USER_ID = @p_user_id)
		BEGIN	
		INSERT INTO dbo.RPT_GOOD_RECEIPT_NOTE_DETAIL
		(
		    USER_ID,
		    REPORT_COMPANY,
		    REPORT_TITLE,
		    REPORT_IMAGE,
		    GOOD_RECEIPT_NOTE_CODE,
		    ITEM_CODE,
		    ITEM_NAME,
		    UOM_NAME,
		    PRICE_AMOUNT,
		    PO_QUANTITY,
		    RECEIVE_QUANTITY,
		    CRE_DATE,
		    CRE_BY,
		    CRE_IP_ADDRESS,
		    MOD_DATE,
		    MOD_BY,
		    MOD_IP_ADDRESS
		)
		VALUES
		(   @p_user_id, -- USER_ID - nvarchar(50)
		    @report_company, -- REPORT_COMPANY - nvarchar(250)
		    @report_title, -- REPORT_TITLE - nvarchar(250)
		    @report_company, -- REPORT_IMAGE - nvarchar(250)
		    NULL, -- GOOD_RECEIPT_NOTE_CODE - nvarchar(50)
		    NULL, -- ITEM_CODE - nvarchar(50)
		    NULL, -- ITEM_NAME - nvarchar(250)
		    NULL, -- UOM_NAME - nvarchar(250)
		    NULL, -- PRICE_AMOUNT - decimal(18, 2)
		    NULL, -- PO_QUANTITY - decimal(18, 2)
		    NULL, -- RECEIVE_QUANTITY - decimal(18, 2)
		    @p_cre_date, -- CRE_DATE - datetime
		    @p_cre_by, -- CRE_BY - nvarchar(15)
		    @p_cre_ip_address, -- CRE_IP_ADDRESS - nvarchar(15)
		    @p_mod_date, -- MOD_DATE - datetime
		    @p_mod_by, -- MOD_BY - nvarchar(15)
		    @p_mod_ip_address  -- MOD_IP_ADDRESS - nvarchar(15)
		    )
			end
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
