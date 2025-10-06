CREATE PROCEDURE [dbo].[xsp_waived_obligation_detail_update]
(
	@p_id					   bigint
	,@p_waived_obligation_code nvarchar(50)
	--,@p_obligation_type		   nvarchar(10)
	--,@p_installment_no		   int
	--,@p_obligation_amount	   decimal(18, 2)
	,@p_waived_amount		   decimal(18, 2)
	--
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin

	declare @msg						nvarchar(max) 
			,@obligation_amount			decimal(18,2)
			,@waived_amount				decimal(18,2);

	begin try
		
		SELECT	@obligation_amount = ISNULL(obligation_amount,0) 
		FROM	dbo.waived_obligation_detail
		WHERE	id = @p_id

		IF(ISNULL(@p_waived_amount,0) < 0)
		BEGIN
			
			SET @msg =  dbo.xfn_get_msg_err_must_be_greater_or_equal_than ('Waived Amount','0');

			RAISERROR(@msg, 16, -1) ;
        END
        
		IF (ISNULL(@p_waived_amount,0) > @obligation_amount)
		BEGIN
			SET @msg = 'Waived Amount must be less or Equal than Obligation Amount';
			RAISERROR(@msg, 16, -1) ;
		END

		UPDATE	waived_obligation_detail
		set		waived_obligation_code	= @p_waived_obligation_code
				--,obligation_type		= @p_obligation_type
				--,installment_no			= @p_installment_no
				--,obligation_amount		= @p_obligation_amount
				,waived_amount			= @p_waived_amount
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;

		select	@obligation_amount = sum(isnull(obligation_amount,0)) 
				,@waived_amount		= sum(isnull(waived_amount,0))
		from	waived_obligation_detail
		where	waived_obligation_code = @p_waived_obligation_code

		update	waived_obligation
		set		obligation_amount	= isnull(@obligation_amount,0)
				,waived_amount		= isnull(@waived_amount,0)  
		where	code = @p_waived_obligation_code

		if exists --raffy 2025/08/11 cr fase 3
		(
			select 1 
			from dbo.waived_obligation_detail
			where	id = @p_id
					and	obligation_type = 'LRAP'
		)
		begin

			update	dbo.agreement_asset_late_return
			set		waive_amount	= @p_waived_amount					
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address	= @p_mod_ip_address
			from	dbo.agreement_asset_late_return aalr
			inner join dbo.waived_obligation_detail wod on wod.asset_no = aalr.asset_no
			where	wod.id = @p_id 
					and wod.obligation_type = 'LRAP'

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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;
	
		raiserror(@msg, 16, -1) ;
	
		return ;
	end catch ;
end ;

