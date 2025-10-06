/*
	alterd : Nia, 26 Mei 2020
*/
CREATE PROCEDURE [dbo].[xsp_sppa_main_send] 
(
	@p_code				nvarchar(50)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)

	begin TRY
		IF EXISTS (SELECT 1 FROM dbo.sppa_detail WHERE sppa_code = @p_code AND result_status = 'ON PROCESS')
		BEGIN
			SET @msg = 'Please update result status APPROVED or REJECT';
			RAISERROR(@msg, 16, -1);
		END
        
		if exists
		(
			select	1 
			from	dbo.sppa_detail sde
			inner join dbo.sale_detail sd ON sd.asset_code = sde.fa_code
			inner join dbo.sale s on s.code = sd.sale_code
			where	s.status NOT IN ('REJECT','CANCEL')		
					AND sde.sppa_code = @p_code
		)
		begin
			select	@msg = 'Assets Are In Sale Request Process For Plat No: ' + STRING_AGG(av.plat_no, ', ')
			from	dbo.sppa_detail sde
			inner join dbo.sale_detail sd on sd.asset_code = sde.fa_code
			inner join dbo.sale s on s.code = sd.sale_code
			inner join dbo.asset_vehicle av on av.asset_code = sde.fa_code
			where	s.status not in ('REJECT','CANCEL')		
					and sde.sppa_code = @p_code
			raiserror (@msg, 16, -1);

		END
        

		if exists
		(
			select	1 
			from	dbo.SPPA_MAIN sm
			INNER JOIN dbo.SPPA_DETAIL sd ON sd.SPPA_CODE = sm.CODE
			INNER JOIN dbo.SPPA_DETAIL_ASSET_COVERAGE sdac ON sdac.SPPA_DETAIL_ID = sd.ID
			where	sm.code  = @p_code
					AND (RIGHT(initial_buy_amount, 2) <> '00'
					or right(initial_discount_amount, 2) <> '00'
					or right(initial_admin_fee_amount, 2) <> '00'
					or right(initial_stamp_fee_amount, 2) <> '00'
					or right(buy_amount, 2) <> '00')
					
		)
		begin
			set @msg = 'The Comma at the end cannot be anything other than 0' 
			raiserror(@msg, 16, -1);
		end

		IF EXISTS (SELECT 1 FROM dbo.sppa_main WHERE code = @p_code AND sppa_status = 'HOLD')
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM dbo.sppa_detail WHERE sppa_code = @p_code)
			BEGIN
				RAISERROR('SPPA detail is empty',16,1)
			END
			ELSE
			BEGIN	
			   UPDATE	dbo.sppa_main
			   SET		sppa_status = 'ON PROCESS'
			   		    --
			   		    ,mod_date		= @p_mod_date		
			   		    ,mod_by			= @p_mod_by			
			   		    ,mod_ip_address	= @p_mod_ip_address
			   WHERE	code			= @p_code
			      
			end
         end
		else
		begin
			raiserror('data already proceed',16,1)
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

