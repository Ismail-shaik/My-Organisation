public class ContactWrapper 
 {

    
    public Contact cat { get; set;}

    public ContactWrapper()
     {
        cat = new Contact();
       
     }

    public ContactWrapper(Contact c)
     {
        cat = c;
       
     }

 }