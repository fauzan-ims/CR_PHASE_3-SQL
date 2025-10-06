--Created, Rian 19/12/2022

CREATE PROCEDURE [dbo].[xsp_maturity_detail_update]
(
	@p_id						bigint
	,@p_remark					nvarchar(4000)=''
	--,@p_additional_periode		int
	--,@p_pickup_date				datetime = ''
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg			  nvarchar(max)
			,@maturity_code	  nvarchar(50)
			,@asset_no		  nvarchar(50)
			,@schedule		  int
			,@result		  nvarchar(10)
			,@maturity_date	  datetime
			,@maturity_remark nvarchar(4000)
			,@periode		  int 
			,@additional_periode int
	
	begin try

		select	@asset_no = asset_no
				,@result = md.result
				,@schedule = bt.multiplier
				,@maturity_date = m.date
				,@maturity_remark = m.remark
				,@periode = m.additional_periode
				,@maturity_code = m.code
				,@additional_periode = m.additional_periode
		from	dbo.maturity_detail md
				inner join dbo.maturity m on (m.code			  = md.maturity_code)
				left join dbo.master_billing_type bt on (bt.code = m.new_billing_type)
		where	id = @p_id ;

		if @result = 'CONTINUE'
			set @result = 'STOP' ;
		else
			set @result = 'CONTINUE' ;
			
		
		--hapus terlebih dahulu data yang staus nya new di tabel maturity amontization history
		delete	dbo.maturity_amortization_history
		where	maturity_code  = @maturity_code
				and asset_no   = @asset_no
				and old_or_new = 'NEW' ;

		if exists (
					select	1
					from	dbo.maturity_detail
					where	id					= @p_id
					and		@result				= 'CONTINUE'
					and		@additional_periode	= 0
					
				)
		begin
			set	@msg = 'Additional Periode must be greater then 0'
			raiserror(@msg, 16, -1) ;
		end
    
		if	(@additional_periode % @schedule <> 0)
		begin
			set	@msg = 'Invalid combination Additional Periode and Biling Type, aset no: ' + @asset_no
			raiserror(@msg, 16, -1) ;
		end

		update	dbo.maturity_detail
		set		
				--additional_periode	= @p_additional_periode
				--,remark				= @p_remark
				--,pickup_date		= @p_pickup_date
				result				= @result
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id
		
		if (@result = 'CONTINUE')
		begin
			exec dbo.xsp_maturity_calculate @p_asset_no			= @asset_no
											,@p_periode			= @periode
											,@p_maturity_code	= @maturity_code
											,@p_maturity_remark = @maturity_remark
											,@p_maturity_date	= @maturity_date
											,@p_cre_date		= @p_mod_date
											,@p_cre_by			= @p_mod_by
											,@p_cre_ip_address	= @p_mod_ip_address
											,@p_mod_date		= @p_mod_date
											,@p_mod_by			= @p_mod_by
											,@p_mod_ip_address	= @p_mod_ip_address
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
end
