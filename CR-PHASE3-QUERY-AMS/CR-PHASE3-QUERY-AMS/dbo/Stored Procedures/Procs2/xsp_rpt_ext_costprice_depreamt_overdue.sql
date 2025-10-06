CREATE PROCEDURE dbo.xsp_rpt_ext_costprice_depreamt_overdue
AS
BEGIN

	declare @msg			   nvarchar(max)
			,@p_cre_date	   datetime = dbo.xfn_get_system_date()
			,@p_cre_by		   nvarchar(15) = N'JOB'
			,@p_cre_ip_address nvarchar(15) = N'JOB'
			,@system_date	   datetime = dbo.xfn_get_system_date()

	if(@p_cre_date < eomonth(@p_cre_date)) -- (+) Ari 2024-02-05 ket : get last eom
	begin
		set @p_cre_date = dateadd(month, -1, @p_cre_date)
		set @p_cre_date = eomonth(@p_cre_date)
	end
    
	begin try
	
	delete rpt_ext_costprice_depreamt_overdue

	--CREATE TABLE RPT_EXT_COSTPRICE_DEPREAMT_OVERDUE
	--(
	--    EOM						DATETIME
	--	,AGRMNTNO				NVARCHAR(50)
	--	,ASSETCONDITIONID		NVARCHAR(10)
	--	,ASSETMODELID			NVARCHAR(50)
	--	,COSTPRICE				DECIMAL(18,2)
	--	,DEPREAMT				DECIMAL(18,2)
	--	,PAYMENTBALANCE			DECIMAL(18,2)
	--	,CRE_BY					NVARCHAR(15)
	--	,CRE_DATE				DATETIME
	--	,CRE_IP_ADDRESS			NVARCHAR(15)
	--	,MOD_BY					NVARCHAR(15)
	--	,MOD_DATE				DATETIME
	--	,MOD_IP_ADDRESS			NVARCHAR(15)
	--)

	insert into dbo.rpt_ext_costprice_depreamt_overdue
	(
	    eom,
	    agrmntno,
	    assetconditionid,
	    assetmodelid,
	    costprice,
	    depreamt,
	    paymentbalance,
		---- raffy (+) 2025/08/06 imon 2508000017
		fa_code,
		registration_class_type,
		asset_name,
	    cre_by,
	    cre_date,
	    cre_ip_address,
	    mod_by,
	    mod_date,
	    mod_ip_address
	)
 --   SELECT	@p_cre_date
	--		,ISNULL(ovd.agrmntno,cost.assetno) 'AGRMNTNO'
	--		,cost.assetconditionid
	--		,cost.assetmodelid
	--		,ISNULL(cost.costprice,0)
	--		,ISNULL(depre.amt,0) 'DEPREAMT'
	--		,ISNULL(ovd.paymentbalance,0)
	--		,@p_cre_by
	--		,@system_date
	--		,@p_cre_ip_address
	--		,@p_cre_by
	--		,@system_date
	--		,@p_cre_ip_address
	--FROM	ifinams.dbo.rpt_ext_net_asset_cost_price cost
	--left	join ifinams.dbo.rpt_ext_net_asset_depre depre on (depre.assetno = cost.assetno)
	--inner	join ifinams.dbo.asset ast on (ast.code = cost.assetno)
	--outer	apply (
	--				select	ovd.agrmntno
	--						,ovd.paymentbalance 
	--						,aas.fa_code
	--				from	ifinopl.dbo.rpt_ext_overdue ovd 
	--				inner	join ifinopl.dbo.agreement_asset aas on (aas.asset_no = ovd.assetbrandtypeid)
	--				where	ovd.agrmntno = ast.agreement_external_no
	--				and		aas.fa_code = ast.code
	--			  ) ovd
	
	select	@p_cre_date
			,isnull(ast.agreement_external_no,ast.code) 'AGRMNTNO'
			,cost.assetconditionid
			,cost.assetmodelid
			,isnull(cost.costprice,0)
			,isnull(depre.amt,0) 'DEPREAMT'
			,isnull(ovd.paymentbalance,0)
			,ast.code
			,cost.registration_class_type
			,ast.item_name
			,@p_cre_by
			,@system_date
			,@p_cre_ip_address
			,@p_cre_by
			,@system_date
			,@p_cre_ip_address
	from	ifinams.dbo.asset ast 
	left	join ifinams.dbo.rpt_ext_net_asset_cost_price cost on  (ast.code = cost.assetno)
	left	join ifinams.dbo.rpt_ext_net_asset_depre depre on (depre.assetno = cost.assetno)
	left	join (

					select	--agrmntno
							sum(paymentbalance) 'paymentbalance'
							,isnull(isnull(ass.fa_code,ass.replacement_fa_code),'') 'fa_code'
					from	ifinopl.dbo.rpt_ext_overdue ovd
					inner	join ifinopl.dbo.agreement_asset ass on (ass.asset_no = ovd.assetbrandtypeid)
					group by isnull(isnull(ass.fa_code,ass.replacement_fa_code),'')
							 --,ovd.agrmntno
					) ovd on ovd.fa_code  = ast.code

	end try
	begin catch
		if (len(@msg) <> 0)
			begin
				set @msg = N'v' + N';' + @msg;
			end;
		else
			begin
				set @msg = N'e;there is an error.' + N';' + error_message();
			end;

		raiserror(@msg, 16, -1);

		return;
	end catch;
end

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_rpt_ext_costprice_depreamt_overdue] TO [ims-raffyanda]
    AS [dbo];

