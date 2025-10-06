CREATE PROCEDURE dbo.xsp_rpt_pengembalian_asset
(
	@p_user_id		nvarchar(50)
	,@p_code			nvarchar(50)
)as
begin
	declare  @item_name							nvarchar(250) 
			,@barcode							nvarchar(50)  
			,@imei								nvarchar(100) 
			,@condition							nvarchar(50)  
			,@remarks							nvarchar(4000)
			,@type_name							nvarchar(250) 
			,@plat_no							nvarchar(20)  
			,@colour							nvarchar(50)  

	delete dbo.rpt_pengembalian_asset
	where user_id = @p_user_id
	
	declare c_asset cursor fast_forward read_only for
    
	select a.code
		   ,a.item_name	
           ,a.barcode	
           ,ae.imei		
           ,a.condition	
           ,a.remarks	
           ,av.type_item_name	
		   ,av.plat_no	
		   ,av.colour	
	from dbo.asset a
		left join dbo.asset_electronic ae on (a.code = ae.asset_code)
		left join dbo.asset_vehicle av on (a.code = av.asset_code)
	where a.code = @p_code

	open c_asset
	fetch next from c_asset
	
	into  @p_code
		  ,@item_name		
		  ,@barcode		
		  ,@imei			
		  ,@condition		
		  ,@remarks		
		  ,@type_name		
		  ,@plat_no		
		  ,@colour		

	while @@fetch_status = 0
	begin
		insert into dbo.rpt_pengembalian_asset
		(
		    user_id,
		    code,
		    item_name,
		    barcode,
		    imei,
		    condition,
		    remarks,
		    type_name,
		    plat_no,
		    colour
		)
		values
		(  @p_user_id	
			,@p_code
			,@item_name	
			,@barcode	
			,@imei		
			,@condition	
			,@remarks	
			,@type_name	
			,@plat_no	
			,@colour	
		)

	    fetch next from c_asset
		
		into	@p_code
			    ,@item_name		
				,@barcode	
				,@imei			
				,@condition	
				,@remarks			
				,@type_name	
				,@plat_no	
				,@colour	

	end
	
	close c_asset
	deallocate c_asset

end
