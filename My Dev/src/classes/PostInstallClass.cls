global class PostInstallClass implements InstallHandler {
  global void onInstall(InstallContext context) {
    if(context.previousVersion() == null) {
      Account a = new Account(name='Newco');
      insert(a);
      
      Gateway__c obj = new Gateway__c(name='Authorize.net');
      insert obj;
               
      User u = [Select Id, Email from User where Id =:context.installerID()];   
      String toAddress= u.Email;
      String[] toAddresses = new String[]{toAddress};
      Messaging.SingleEmailMessage mail = 
        new Messaging.SingleEmailMessage();
      mail.setToAddresses(toAddresses);
      mail.setReplyTo('support@package.dev');
      mail.setSenderDisplayName('My Package Support');
      mail.setSubject('Package install successful');
      mail.setPlainTextBody('Thanks for installing the package.');
      Messaging.sendEmail(new Messaging.Email[] { mail });
      }
    else
      if(context.previousVersion().compareTo(new Version(1,0)) == 0) {
      Gateway__c obj = new Gateway__c(name='Authorize.net 1.0');
      insert(obj);
      }
    if(context.isUpgrade()) {
      Gateway__c obj = new Gateway__c(name='Authorize.net');
      insert obj;
      }
    if(context.isPush()) {
      Gateway__c obj = new Gateway__c(name='Authorize.net');
      insert obj;
      }
    }
  }