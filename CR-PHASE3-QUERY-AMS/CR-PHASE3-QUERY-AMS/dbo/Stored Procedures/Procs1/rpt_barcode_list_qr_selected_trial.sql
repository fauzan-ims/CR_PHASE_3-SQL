CREATE PROCEDURE dbo.rpt_barcode_list_qr_selected_trial
(
	@p_user_id				nvarchar(50)
	,@p_code				nvarchar(50)
    --
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin

	delete dbo.rpt_barcode_list_qr_selected
	where asset_code = @p_code

	declare @report_title				nvarchar(250) 
			,@asset_name				nvarchar(250)
			,@barcode_no				varchar(50)
			---
			,@system_date				datetime
            ,@type_code					nvarchar(10)
			,@asset_code				nvarchar(50)		
	

			declare curr_barcode cursor fast_forward read_only for
			select	barcode
					,item_name 
			from dbo.asset
			where code = @p_code

			OPEN curr_barcode
			
			FETCH NEXT FROM curr_barcode 
			into @barcode_no
				,@asset_name
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
				--insert into barcode image
				insert into dbo.rpt_barcode_list_qr_selected
				(
					user_id
					,asset_code
					,asset_name
					,barcode
					,barcode_image
				)
				values
				(	
					@p_user_id
					,@p_code
					,@asset_name
					,@barcode_no
					,''
				) 
			
			    FETCH NEXT FROM curr_barcode 
				into @barcode_no
					,@asset_name
			END
			
			close curr_barcode
			deallocate curr_barcode
end
