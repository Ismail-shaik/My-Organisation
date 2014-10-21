trigger addDrTrigger on Account (before insert) 
{
    for(Account acc: Trigger.new)
     {
        acc.Name = 'Dr.'+acc.Name;
     }

}