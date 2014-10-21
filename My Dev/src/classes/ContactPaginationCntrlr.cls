public class ContactPaginationCntrlr 
 {
    List<ContactWrapper> conlst {get;set;}
    
    
    public ApexPages.StandardSetController con 
     {
        get 
         {
            if(con == null) 
             {
                con = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id, Name FROM contact Order By Name ]));
                // sets the number of records in each page set
                con.setPageSize(1000);
             }
            return con;
         }
        set;
     }

    
    public List<ContactWrapper> getconlst() 
     {
        conlst = new List<ContactWrapper>();
        for (contact cntct : (List<contact >)con.getRecords())
            conlst .add(new ContactWrapper(cntct));

        return conlst ;
     }

   
     

    
    public Boolean hasNext 
     {
        get 
         {
            return con.getHasNext();
         }
        set;
     }

    
    public Boolean hasPrevious 
     {
        get 
         {
            return con.getHasPrevious();
         }
        set;
     }

    
    public Integer pageNumber
     {
        get
         {
            return con.getPageNumber();
         }
        set;
     }

    
     public void first()
      {
         con.first();
      }

    
     public void last()
      {
         con.last();
      }

     
     public void previous()
      {
         con.previous();
      }

     
     public void next()
      {
         con.next();
      }
      
      
 }