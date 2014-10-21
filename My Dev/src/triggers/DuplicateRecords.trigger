trigger DuplicateRecords on Contact (before insert, before update) 
 {
   List<Contact> lstcon = new List<Contact>();
   lstcon = [select id,Name,Email,FirstName,LastName from Contact];
   
    For(Contact newcon : Trigger.new)
     {
        for(Contact oldcon : lstcon)
         {
            if(oldcon.Email == newcon.Email)
            {
            //   newcon.Email.addError('duplicate Email id\'s found.  ' +newcon.Email);
                
                oldcon.FirstName = newcon.FirstName;
                oldcon.LastName = newcon.LastName;
               lstcon.add(oldcon);         
            }
         }update lstcon;
     }
 }