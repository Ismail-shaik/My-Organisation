trigger sendEmail on Contact (after insert, after update)
{  
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    for(Contact e : trigger.new)
    {
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setContentType('application/pdf');
        attach.setFileName('Contact.pdf');
     
        String body;
     
        body = '<html><h1 style=\"text-align:center;\">Contact Information</h1><br/><br/><table align=\"center\"><tr><td>Contact FirstName</td><td>' + e.FirstName + '</td></tr><tr><td>Phone</td><td>' + e.Phone + '</td></tr><tr><td>LastName</td><td>' + e.LastName + '</td></tr><tr><td>City</td><td>' + e.City__c + '</td></tr></table></html>';
        System.debug('HTML is ' + body);
     
        attach.Body = Blob.toPDF(body);
             
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { e.Email });
        mail.setSubject('PDF Generation');
        mail.setHtmlBody('PFA');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });  
     
        mails.add(mail);
    }
    if(!mails.isEmpty())
    {
        Messaging.SendEmail(mails);
    }
}