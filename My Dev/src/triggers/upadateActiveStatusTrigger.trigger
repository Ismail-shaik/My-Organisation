trigger upadateActiveStatusTrigger on Account (before insert, before update) 
{
    for(Account acc : trigger.new)
     {
        if(acc.Active__c == 'Yes')
         {
            acc.Active_Status__c = 'You Are In Active Status';
         }
        else
         {
            acc.Active_Status__c = 'You Are Not In Active Status';
         }
     }

}