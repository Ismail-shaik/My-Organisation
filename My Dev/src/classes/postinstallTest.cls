@isTest(Seealldata =true)
public Class postinstallTest
{

static void testInstallScript() 
 {
    Account obj =new Account();
    obj.Name='test';
    insert obj;
    
    Gateway__c objgate =new Gateway__c();
      objgate.Name ='test2';
      insert objgate;
  PostInstallClass postinstall = new PostInstallClass();
    Test.testInstall(postinstall, null);
    Test.testInstall(postinstall, new Version(1,0), true);
    List<Account> a = [Select id, name from Account where name ='Newco'];
    System.assertEquals(a.size(), 1, 'Account not found');
  }
}