trigger ContactAutoCreation on Account (after insert, before insert) 
{
  if(Trigger.isInsert)
  {
     List<Contact> lstcon = new List<Contact>();
     for(Account acc : Trigger.new)
      {
         if( acc.Name == 'Baji' || acc.Name == 'Ameen')
         {
           lstcon.add(new Contact(LastName = acc.Name, AccountId = acc.id));
         }
      }
     insert lstcon;
  } 

}