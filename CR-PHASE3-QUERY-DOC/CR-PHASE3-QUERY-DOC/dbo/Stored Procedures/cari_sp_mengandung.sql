create PROCEDURE dbo.cari_sp_mengandung  (@keyword varchar(500))    
as    
begin    
select distinct o.name     
from sysobjects o, syscomments c    
where o.id=c.id    
and c.text like '%'+@keyword+'%'
order by o.name
end
