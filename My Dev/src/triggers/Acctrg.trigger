trigger Acctrg on Account (before insert, before update, after insert) 
{

  //  list<Account> lstacc = new list<Account>();
 
    for(Account acc : trigger.new)
     {
       if(acc.Active__c == null || acc.Active__c == '')
       {
          acc.Active__c.addError('Active cant be null');
       }
     }
   
 /*
  if(Trigger.isInsert)
   {
     List<Contact> lstcon = new List<Contact>
     for (Account a : Trigger.new)
     {
        if( a.Name == 'Contact')
         {
           lstcon.add(new Contact (LastName = a.Name, AccountId = a.id));
         }
     }
    inset lstcon;  
   }
  
   */
  if (Trigger.isInsert) 
   {
        List<Contact> contacts = new List<Contact>();
        for (Account a : Trigger.new) 
        {        
         if(a.Name == 'makeContact') 
          {
           contacts.add(new Contact (LastName = a.Name, AccountId = a.Id));
          }
        } 
      insert contacts;
    }
 
  if(Trigger.isDelete)
   {
      for(Account acc : Trigger.old)
       {
         if(acc.Name == 'jainu')
          {
           acc.addError('you cant delete jainu\'s record');
          }
       }
   }
 
   
   
 /*   
  if(Trigger.isUpdate)
   {
     list<Account> lstacc = new list<Account>();
     for(Account acc : Trigger.new)
      {
        if(acc.Name == 'jainu')
         {
            acc.Name = acc.Name+'Dr.';
         }
        lstacc.add(acc);
      }
     insert lstacc;
   }  
 */
}