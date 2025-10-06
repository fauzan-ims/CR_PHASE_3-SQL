
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_final_grn_request_detail_check_complete]
(
	@p_id				INT
	,@p_mod_date		DATETIME	
	,@p_mod_by			NVARCHAR(15)
	,@p_mod_ip_address	NVARCHAR(15)
)
AS
BEGIN
	DECLARE @msg	NVARCHAR(MAX)
			,@count INT 
			,@final_grn_request_no		NVARCHAR(50)
			,@id_final_grn_req			INT
			,@procurement_req_code		NVARCHAR(50)
			,@procurement_req_code2		NVARCHAR(50)
			,@category_type				NVARCHAR(50)
			,@grn_id					INT
			,@exist1					INT	= 0
			,@exist2					INT	= 0
			,@exist3					INT	= 0
			,@total_post_final_grn		INT = 0
			,@total_item_procurement	INT = 0;	

	BEGIN TRY

	DECLARE @temptable TABLE
	(
		procurement_request_code	NVARCHAR(100)
		,total_post_final_grn		INT
		,total_item_procurement		INT
        --,grn_id					NVARCHAR(50)
	)

		DECLARE curr_check_procurement CURSOR FAST_FORWArd read_only for
		select	distinct pr.code, d.final_grn_request_no
		FROM	dbo.good_receipt_note_detail					grnd
		LEFT JOIN dbo.good_receipt_note					grn ON (grn.code							  = grnd.good_receipt_note_code)
		LEFT JOIN dbo.purchase_order					po ON (po.code								  = grn.purchase_order_code)
		LEFT JOIN dbo.purchase_order_detail				pod ON (
																   pod.po_code						  = po.code
																   AND pod.id						  = grnd.purchase_order_detail_id
															   )
		LEFT JOIN dbo.purchase_order_detail_object_info podoi ON podoi.good_receipt_note_detail_id	  = grnd.id
																 AND   pod.id						  = podoi.purchase_order_detail_id
		LEFT JOIN dbo.supplier_selection_detail			ssd ON (ssd.id								  = pod.supplier_selection_detail_id)
		LEFT JOIN dbo.quotation_review_detail			qrd ON (qrd.id								  = ssd.quotation_detail_id)
		LEFT JOIN dbo.procurement						prc ON (prc.code COLLATE latin1_general_ci_as = ISNULL(qrd.reff_no, ssd.reff_no))
		LEFT JOIN dbo.procurement_request				pr ON (pr.code								  = prc.procurement_request_code)
		LEFT JOIN dbo.procurement_request_item			pri ON (
																   pr.code							  = pri.procurement_request_code
																   AND	grnd.item_code				  = pri.item_code
															   )
		LEFT JOIN dbo.FINAL_GRN_REQUEST_DETAIL_KAROSERI_LOOKUP kl ON kl.GRN_DETAIL_ID = grnd.ID
		LEFT JOIN dbo.FINAL_GRN_REQUEST_DETAIL_KAROSERI k ON k.FINAL_GRN_REQUEST_DETAIL_KAROSERI_ID = kl.ID
		LEFT JOIN dbo.FINAL_GRN_REQUEST_DETAIL d ON d.ID = k.FINAL_GRN_REQUEST_DETAIL_ID
		WHERE d.ID = @p_id
		UNION
		select	distinct pr.code, d.final_grn_request_no
		FROM	dbo.good_receipt_note_detail					grnd
		LEFT JOIN dbo.good_receipt_note					grn ON (grn.code							  = grnd.good_receipt_note_code)
		LEFT JOIN dbo.purchase_order					po ON (po.code								  = grn.purchase_order_code)
		LEFT JOIN dbo.purchase_order_detail				pod ON (
																   pod.po_code						  = po.code
																   AND pod.id						  = grnd.purchase_order_detail_id
															   )
		LEFT JOIN dbo.purchase_order_detail_object_info podoi ON podoi.good_receipt_note_detail_id	  = grnd.id
																 AND   pod.id						  = podoi.purchase_order_detail_id
		LEFT JOIN dbo.supplier_selection_detail			ssd ON (ssd.id								  = pod.supplier_selection_detail_id)
		LEFT JOIN dbo.quotation_review_detail			qrd ON (qrd.id								  = ssd.quotation_detail_id)
		LEFT JOIN dbo.procurement						prc ON (prc.code COLLATE latin1_general_ci_as = ISNULL(qrd.reff_no, ssd.reff_no))
		LEFT JOIN dbo.procurement_request				pr ON (pr.code								  = prc.procurement_request_code)
		LEFT JOIN dbo.procurement_request_item			pri ON (
																   pr.code							  = pri.procurement_request_code
																   AND	grnd.item_code				  = pri.item_code
															   )
		LEFT JOIN dbo.FINAL_GRN_REQUEST_DETAIL_ACCESORIES_LOOKUP al ON al.GRN_DETAIL_ID = grnd.ID
		LEFT JOIN dbo.FINAL_GRN_REQUEST_DETAIL_ACCESORIES a ON a.FINAL_GRN_REQUEST_DETAIL_ACCESORIES_ID = al.ID
		LEFT JOIN dbo.FINAL_GRN_REQUEST_DETAIL d ON d.ID = a.FINAL_GRN_REQUEST_DETAIL_ID
		WHERE d.ID = @p_id
		UNION
		select	distinct pr.code, d.final_grn_request_no
		FROM	dbo.good_receipt_note_detail					grnd
		LEFT JOIN dbo.good_receipt_note					grn ON (grn.code							  = grnd.good_receipt_note_code)
		LEFT JOIN dbo.purchase_order					po ON (po.code								  = grn.purchase_order_code)
		LEFT JOIN dbo.purchase_order_detail				pod ON (
																   pod.po_code						  = po.code
																   AND pod.id						  = grnd.purchase_order_detail_id
															   )
		LEFT JOIN dbo.purchase_order_detail_object_info podoi ON podoi.good_receipt_note_detail_id	  = grnd.id
																 AND   pod.id						  = podoi.purchase_order_detail_id
		LEFT JOIN dbo.supplier_selection_detail			ssd ON (ssd.id								  = pod.supplier_selection_detail_id)
		LEFT JOIN dbo.quotation_review_detail			qrd ON (qrd.id								  = ssd.quotation_detail_id)
		LEFT JOIN dbo.procurement						prc ON (prc.code COLLATE latin1_general_ci_as = ISNULL(qrd.reff_no, ssd.reff_no))
		LEFT JOIN dbo.procurement_request				pr ON (pr.code								  = prc.procurement_request_code)
		LEFT JOIN dbo.procurement_request_item			pri ON (
																   pr.code							  = pri.procurement_request_code
																   AND	grnd.item_code				  = pri.item_code
															   )
		LEFT JOIN dbo.FINAL_GRN_REQUEST_DETAIL d ON d.GRN_DETAIL_ID_ASSET = grnd.id
		WHERE d.ID = @p_id

        OPEN curr_check_procurement ;

		FETCH NEXT FROM curr_check_procurement
		INTO @procurement_req_code, @final_grn_request_no

		WHILE @@fetch_status = 0
		BEGIN
		--SELECT @final_grn_request_no'@final_grn_request_no'
			DECLARE curr_check_total CURSOR FAST_FORWARD READ_ONLY FOR
			SELECT DISTINCT	grnd.id
					,pri.category_type
					,pr.CODE
			FROM	dbo.good_receipt_note_detail					grnd
			LEFT JOIN dbo.good_receipt_note					grn ON (grn.code							  = grnd.good_receipt_note_code)
			LEFT JOIN dbo.purchase_order					po ON (po.code								  = grn.purchase_order_code)
			LEFT JOIN dbo.purchase_order_detail				pod ON (
																	   pod.po_code						  = po.code
																	   AND pod.id						  = grnd.purchase_order_detail_id
																   )
			LEFT JOIN dbo.purchase_order_detail_object_info podoi ON podoi.good_receipt_note_detail_id	  = grnd.id
																	 AND   pod.id						  = podoi.purchase_order_detail_id
			LEFT JOIN dbo.supplier_selection_detail			ssd ON (ssd.id								  = pod.supplier_selection_detail_id)
			LEFT JOIN dbo.quotation_review_detail			qrd ON (qrd.id								  = ssd.quotation_detail_id)
			LEFT JOIN dbo.procurement						prc ON (prc.code COLLATE latin1_general_ci_as = ISNULL(qrd.reff_no, ssd.reff_no))
			LEFT JOIN dbo.procurement_request				pr ON (pr.code								  = prc.procurement_request_code)
			LEFT JOIN dbo.procurement_request_item			pri ON (
																	   pr.code							  = pri.procurement_request_code
																	   AND	grnd.item_code				  = pri.item_code
																   )
			WHERE pr.CODE = @procurement_req_code

			OPEN curr_check_total ;

			fetch next from curr_check_total
			INTO @grn_id
				,@category_type
				,@procurement_req_code2

			while @@fetch_status = 0
			BEGin

				set @exist1 = 0

				if exists 
					(				
						select	1 
						from	dbo.final_grn_request_detail_accesories_lookup a
						inner join dbo.final_grn_request_detail_accesories b on a.id = b.final_grn_request_detail_accesories_id
						inner join dbo.final_grn_request_detail c on c.id = b.final_grn_request_detail_id
						INNER JOIN dbo.FINAL_GRN_REQUEST d ON d.FINAL_GRN_REQUEST_NO = c.FINAL_GRN_REQUEST_NO
						where	a.grn_detail_id		= @grn_id 
								AND @category_type	= 'ACCESSORIES'
								and	c.status		= 'POST'
					)
				begin
					select	@exist1 = COUNT(1) 
					from	dbo.final_grn_request_detail_accesories_lookup a
					inner join dbo.final_grn_request_detail_accesories b on a.id = b.final_grn_request_detail_accesories_id
					inner join dbo.final_grn_request_detail c on c.id = b.final_grn_request_detail_id
					INNER JOIN dbo.FINAL_GRN_REQUEST d ON d.FINAL_GRN_REQUEST_NO = c.FINAL_GRN_REQUEST_NO
					where	a.grn_detail_id		= @grn_id 
							AND @category_type	= 'ACCESSORIES'
							and	c.status		= 'POST'
				end

				if exists 
					(				
						select	1 
						from	dbo.final_grn_request_detail_karoseri_lookup a
						inner join dbo.final_grn_request_detail_karoseri b on a.id = b.final_grn_request_detail_karoseri_id
						inner join dbo.final_grn_request_detail c on c.id = b.final_grn_request_detail_id
						INNER JOIN dbo.FINAL_GRN_REQUEST d ON d.FINAL_GRN_REQUEST_NO = c.FINAL_GRN_REQUEST_NO
						WHERE	a.grn_detail_id		= @grn_id 
								and	c.status		= 'POST'
								and @category_type	= 'KAROSERI'
					)
				begin
					select	@exist1	=  COUNT(1) 
					from	dbo.final_grn_request_detail_karoseri_lookup a
					inner join dbo.final_grn_request_detail_karoseri b on a.id = b.final_grn_request_detail_karoseri_id
					inner join dbo.final_grn_request_detail c on c.id = b.final_grn_request_detail_id
					INNER JOIN dbo.FINAL_GRN_REQUEST d ON d.FINAL_GRN_REQUEST_NO = c.FINAL_GRN_REQUEST_NO
					where	a.grn_detail_id		= @grn_id 
							and	c.status		= 'POST'
							and @category_type	= 'KAROSERI'
				end

				IF EXISTS 
					(				
						SELECT	1 
						FROM	dbo.final_grn_request_detail a
						INNER JOIN dbo.FINAL_GRN_REQUEST b ON b.FINAL_GRN_REQUEST_NO = a.FINAL_GRN_REQUEST_NO
						WHERE	a.GRN_DETAIL_ID_ASSET = @grn_id
								AND	a.status			= 'POST'
								AND @category_type	= 'ASSET'
					)
				BEGIN
					SELECT	@exist1 =  COUNT(1) 
					FROM	dbo.final_grn_request_detail a
					INNER JOIN dbo.FINAL_GRN_REQUEST b ON b.FINAL_GRN_REQUEST_NO = a.FINAL_GRN_REQUEST_NO
					WHERE	a.GRN_DETAIL_ID_ASSET	= @grn_id
							AND	a.status			= 'POST'
							AND @category_type		= 'ASSET'
				END

					INSERT INTO @temptable
					(
					    procurement_request_code,
					    total_post_final_grn,
					    total_item_procurement
					)
					VALUES
					(   @procurement_req_code2, -- procurement_request_code - nvarchar(50)
					    @exist1, -- total_post_final_grn - int
					    0 -- total_item_procurement - int
					    )


				FETCH NEXT FROM curr_check_total
				INTO @grn_id
					,@category_type 
					,@procurement_req_code2;
			END
			CLOSE curr_check_total ;
			DEALLOCATE curr_check_total ;

			UPDATE	@temptable
			SET		total_item_procurement = b.QUANTITY_REQUEST
			FROM	@temptable a
			OUTER APPLY(
					SELECT  SUM(pri.QUANTITY_REQUEST) 'QUANTITY_REQUEST'
					FROM  dbo.PROCUREMENT_REQUEST_ITEM pri 
					WHERE pri.PROCUREMENT_REQUEST_CODE = a.procurement_request_code
					)b
			WHERE	a.procurement_request_code = @procurement_req_code


			SELECT	@total_post_final_grn		= SUM(total_post_final_grn)
					,@total_item_procurement	= MAX(total_item_procurement)
			FROM	@temptable
			WHERE	procurement_request_code	= @procurement_req_code

			--SELECT @total_post_final_grn,@total_item_procurement
			IF (@total_post_final_grn = @total_item_procurement)
			BEGIN
				UPDATE	dbo.final_grn_request
				SET		status						= 'COMPLETE'
						,mod_date					= @p_mod_date
						,mod_by						= @p_mod_by
						,mod_ip_address				= @p_mod_ip_address
				WHERE	PROCUREMENT_REQUEST_CODE	= @procurement_req_code ;

				UPDATE dbo.FINAL_GRN_REQUEST_DETAIL
				SET		STATUS					= 'COMPLETE'
						,mod_date				= @p_mod_date
						,mod_by					= @p_mod_by
						,mod_ip_address			= @p_mod_ip_address
				WHERE	FINAL_GRN_REQUEST_NO	= @final_grn_request_no
				AND		ASSET_NO				=''
				AND		DELIVERY_TO				=''
				AND		isnull(BBN_NAME,'')		=''
				AND		isnull(BBN_LOCATION,'')	=''
				AND		isnull(BBN_ADDRESS,'')	=''
				AND		YEAR					=''
				AND		COLOUR					=''
				AND		PO_CODE_ASSET			=''
				AND		GRN_CODE_ASSET			=''
				AND		GRN_DETAIL_ID_ASSET		='0'
				AND		SUPPLIER_NAME_ASSET		=''
				AND		GRN_RECEIVE_DATE		IS NULL
				AND		PLAT_NO					=''
				AND		ENGINE_NO				=''
				AND		CHASIS_NO				=''
				AND		STATUS					='HOLD'
				and		(id not in (select final_grn_request_detail_id from dbo.final_grn_request_detail_accesories) or id not in (select final_grn_request_detail_id from dbo.final_grn_request_detail_karoseri))

			END

			FETCH NEXT FROM curr_check_procurement
			INTO @procurement_req_code, @final_grn_request_no

		END

		CLOSE curr_check_procurement ;
		DEALLOCATE curr_check_procurement ;


	end try
	begin catch
		DECLARE @error INT ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = @msg ;
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
				set @msg = N'e;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
