trigger Deletetrigger on Contact (before delete) 
 {
   
   List<contact> lstcon = new List<contact>();
   lstcon = [select id,Name from Contact where name =: 'jainu'];
    if(trigger.isDelete)
     { 
     for(contact con : Trigger.old)
      {
      
         if(lstcon.size() > 0)
          {
             con.addError('cant delete jainu\'s record');
          }
         
      }
    }
 }