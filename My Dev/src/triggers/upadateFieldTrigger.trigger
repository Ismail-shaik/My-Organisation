trigger upadateFieldTrigger on Account (before insert, before update) 
{
   if(Trigger.isUpdate)
    { 
    }
    
       for(Account acc : Trigger.new)
         {
           if(acc.Name.contains('kumar'))
            {
               acc.Description = 'This Account is probably left over from testing. It should probably be deleted.';
            }
         } 
    
   
}