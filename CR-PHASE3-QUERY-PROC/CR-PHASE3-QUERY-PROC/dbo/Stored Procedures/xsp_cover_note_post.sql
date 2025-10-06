CREATE PROCEDURE [dbo].[xsp_cover_note_post]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max)
			,@asset_code		nvarchar(50)
			,@cover_note		nvarchar(50)
			,@cover_note_date	datetime
			,@exp_date			datetime
			,@file_name			nvarchar(250)
			,@file_path			nvarchar(4000)

	begin TRY
    
	if exists --Validasi untuk tidak bisa di proses jika dalam GRN tersebut masih ada asset yang belum kebentuk
		(
			select	1
			from	dbo.good_receipt_note grn
			left join dbo.good_receipt_note_detail grnd on (grnd.good_receipt_note_code = grn.code)
			left join dbo.purchase_order_detail_object_info podoi on (podoi.good_receipt_note_detail_id = grnd.id)
			inner join ifinbam.dbo.master_item mi on grnd.item_code = mi.code
			where	grn.code = @p_code
			and		grnd.receive_quantity <> 0
			and		mi.category_type = 'ASSET'
			and		isnull(podoi.asset_code,'')=''
		)
		begin
			set @msg = 'Cannot proceed this data, because there are assets that have not been created'
			raiserror (@msg, 16, -1)
		end
			

		if exists
		(
			select	1
			from	dbo.good_receipt_note
			where	code		= @p_code
					and cover_note_status	= 'HOLD'
		)
		begin
			update	dbo.good_receipt_note
			set		cover_note_status	= 'POST'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code ;

			declare cursor_name cursor fast_forward read_only for
			select podoi.asset_code
					,podoi.cover_note
					,podoi.cover_note_date
					,podoi.exp_date
					,podoi.file_name
					,podoi.file_path
			from dbo.good_receipt_note grn
			left join dbo.good_receipt_note_detail grnd on (grnd.good_receipt_note_code = grn.code)
			left join dbo.purchase_order_detail_object_info podoi on (podoi.good_receipt_note_detail_id = grnd.id)
			inner join ifinbam.dbo.master_item mi on grnd.item_code = mi.code
			where grn.code = @p_code
			and grnd.receive_quantity <> 0
			and mi.category_type = 'ASSET'
			
			open cursor_name
			
			fetch next from cursor_name 
			into @asset_code
				,@cover_note
				,@cover_note_date
				,@exp_date
				,@file_name
				,@file_path
			
			while @@fetch_status = 0
			begin
            
			    -- push ke document
				exec ifinams.dbo.xsp_asset_to_interface_insert @p_asset_code			= @asset_code
															   ,@p_cover_note			= @cover_note
															   ,@p_cover_note_date		= @cover_note_date
															   ,@p_cover_exp_date		= @exp_date
															   ,@p_cover_file_name		= @file_name
															   ,@p_cover_file_path		= @file_path
															   ,@p_cre_date				= @p_mod_date	  
															   ,@p_cre_by				= @p_mod_by		  
															   ,@p_cre_ip_address		= @p_mod_ip_address
															   ,@p_mod_date				= @p_mod_date	  
															   ,@p_mod_by				= @p_mod_by		  
															   ,@p_mod_ip_address		= @p_mod_ip_address
			
			    fetch next from cursor_name 
				into @asset_code
					,@cover_note
					,@cover_note_date
					,@exp_date
					,@file_name
					,@file_path
			end
			
			close cursor_name
			deallocate cursor_name
		end ;
		else
		begin
			set @msg = 'Data already process' ;
			raiserror(@msg, 16, 1) ;
		end ;
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
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
end ;
