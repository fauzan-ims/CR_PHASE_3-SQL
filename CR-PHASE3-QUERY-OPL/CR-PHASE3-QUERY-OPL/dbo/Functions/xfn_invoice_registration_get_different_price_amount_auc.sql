
-- User Defined Function

-- User Defined Function

CREATE FUNCTION [dbo].[xfn_invoice_registration_get_different_price_amount_auc]  
(  
 @p_id bigint  
)returns decimal(18, 2)  
as  
begin  

 declare	@return_amount   decimal(18,2)  
		   ,@price_amount   decimal(18, 2)  
		   ,@amount_invoice  decimal(18, 2)  
		   ,@amount_grn   decimal(18, 2)  
		   ,@category_type   nvarchar(50)  


 select @category_type = pri.category_type  
		,@amount_grn = isnull(grnd.price_amount,0)  - isnull(grnd.discount_amount,0)
 from dbo.ap_invoice_registration_detail    invd  
   inner join dbo.good_receipt_note_detail   grnd on grnd.id = invd.grn_detail_id  
   inner join dbo.good_receipt_note    grn on (grn.code         = grnd.good_receipt_note_code)  
   inner join dbo.purchase_order     po on (po.code          = grn.purchase_order_code)  
   inner join dbo.purchase_order_detail   pod on (  
                  pod.po_code        = po.code  
                  and pod.id        = grnd.purchase_order_detail_id  
                 )  
   left join dbo.purchase_order_detail_object_info podoi on (  
                   podoi.purchase_order_detail_id   = pod.id  
                   and   grnd.id       = podoi.good_receipt_note_detail_id  
                  )  
   inner join dbo.supplier_selection_detail  ssd on (ssd.id          = pod.supplier_selection_detail_id)  
   left join dbo.quotation_review_detail   qrd on (qrd.id          = ssd.quotation_detail_id)  
   inner join dbo.procurement      prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))  
   inner join dbo.procurement_request    pr on (prc.procurement_request_code     = pr.code)  
   inner join dbo.procurement_request_item   pri on (  
                  pr.code         = pri.procurement_request_code  
                  and pri.item_code      = grnd.item_code  
                 )  
  where invd.id = @p_id  


 --if(@category_type = 'ASSET')  
 --begin  
 -- select @amount_grn = grnd.price_amount  
 -- from dbo.ap_invoice_registration_detail    ard  
 --   inner join dbo.ap_invoice_registration   air on ard.invoice_register_code     = air.code  
 --   inner join dbo.good_receipt_note_detail   grnd on grnd.id = ard.grn_detail_id  
 --   inner join dbo.final_grn_request_detail fgrnd on fgrnd.grn_detail_id_asset = grnd.id  and fgrnd.status = 'POST' -- ambil yang sudah post/sudah tau asset nya  
 -- where ard.id = @p_id  
 --end  
 --else if(@category_type = 'KAROSERI')  
 --   begin   
 -- select @amount_grn = grnd.price_amount  
 -- from dbo.ap_invoice_registration_detail    ard  
 --   inner join dbo.ap_invoice_registration   air on ard.invoice_register_code     = air.code  
 --   inner join dbo.good_receipt_note_detail   grnd on grnd.id = ard.grn_detail_id  
 --   inner join dbo.final_grn_request_detail_karoseri_lookup fgrnl on fgrnl.grn_detail_id = grnd.id  
 --   inner join dbo.final_grn_request_detail_karoseri fgrnk on fgrnk.final_grn_request_detail_karoseri_id = fgrnl.id  
 --   inner join dbo.final_grn_request_detail fgrnd on fgrnd.id = fgrnk.final_grn_request_detail_id  and fgrnd.status = 'POST' -- ambil yang sudah post/sudah tau asset nya  
 -- where ard.id = @p_id  
 --   end  
 --else  
 --   begin  
 --       select @amount_grn = grnd.price_amount  
 -- from dbo.ap_invoice_registration_detail    ard  
 --   inner join dbo.ap_invoice_registration   air on ard.invoice_register_code     = air.code  
 --   inner join dbo.good_receipt_note_detail   grnd on grnd.id = ard.grn_detail_id  
 --   inner join dbo.final_grn_request_detail_accesories_lookup fgrnl on fgrnl.grn_detail_id = grnd.id  
 --   inner join dbo.final_grn_request_detail_accesories fgrnk on fgrnk.final_grn_request_detail_accesories_id = fgrnl.id  
 --   inner join dbo.final_grn_request_detail fgrnd on fgrnd.id = fgrnk.final_grn_request_detail_id  and fgrnd.status = 'POST' -- ambil yang sudah post/sudah tau asset nya  
 -- where ard.id = @p_id  
 --   end  

 if (isnull(@amount_grn,0) <> 0)  
 begin  

  select @amount_invoice = (ISNULL(purchase_amount,0) - ISNULL(discount,0))
  from dbo.ap_invoice_registration_detail  
  where id = @p_id ;  

  set @return_amount = isnull(@amount_grn,0) - isnull(@amount_invoice,0)
 end  

 return @return_amount
end  
