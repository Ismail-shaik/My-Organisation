/**
* Generate the enviroment for the Unit Tests
* @author Sebastian Muñoz - Force.com Labs
* @createddate 06/14/2010
*/
public with sharing class iCalendar_TestUtilities {
	
	//Lists
 	public List<Event>	 testEventList  { get; set; }

	
	
  	/**
  	* Check over all object field if the loged User has right over Object
  	* @parms sObject , CRUD check ( isCreateable, isDeleteable, isUpdateable ) 
  	* @return Boolean
  	*/
  	public Boolean checkObjectCrud( String objName, Set<String> fieldsToCheck, String crudType ){  		
  		
  		// Get the global describe
        Schema.DescribeSObjectResult objectResult = Schema.getGlobalDescribe().get( objName ).getDescribe();

  		for( String fieldToCheck : objectResult.fields.getMap().keySet() ){	
  			
  			Schema.DescribeFieldResult current_field = objectResult.fields.getMap().get( fieldToCheck ).getDescribe();
  			
  			if( fieldsToCheck.contains( current_field.getName() ) ) {
  			
	  			if( 'create'.equalsIgnoreCase( crudType ) && !current_field.isCreateable()){
		  			return false;
		  		}
		  		else if( 'update'.equalsIgnoreCase( crudType ) && !current_field.isUpdateable() ){
		  			return false;
		  		}
  			}
  		}
  		
  		return true;
  	}
  	
  	/**
  	* Create Event's
  	* @params createEvents ( the total amount of events )
  	*/
  	public void createEvents( Integer ToCreate ){
		Set<String> fieldsToCheck 	= new Set<String>{'IsPrivate', 'IsAllDayEvent','IsRecurrence','EndDateTime','StartDateTime'};
  		List<Event> auxList 		= new List<Event>();
  		Date EndDate 				= Date.today().addDays(1);
  		Date StartDate 				= Date.today().addDays(-1);
  		String LeadId				= this.getLeadId();
		String whatId				= [Select Id from Product2 limit 1 ].Id;
  		for( Integer i = 1; i <= ToCreate; i++ ){
  			
  			Event eAux 				= new Event();
  			eAux.IsPrivate 			= (i < 2);
  			eAux.IsAllDayEvent		= false;
  			eAux.IsRecurrence		= false;
  			eAux.EndDateTime		= Datetime.newInstance(EndDate.year(), EndDate.month(), EndDate.day());
			eAux.StartDateTime		= Datetime.newInstance(StartDate.year(), StartDate.month(), StartDate.day());
			eAux.Subject			= 'Other';
			eAux.IsAllDayEvent		= (i < 2);
			eAux.ShowAs  			= (i < 2) ? 'Free' : 'OutOfOffice';
			eAux.ReminderDateTime	= Datetime.newInstance(EndDate.year(), EndDate.month(), EndDate.day());
			eAux.WhoId				= (i > 2) ? LeadId : null;
			eAux.WhatId				= (i == 2) ? whatId : null;
			
			auxList.add( eAux );
  		}

  		if ( this.checkObjectCrud('Event', fieldsToCheck, 'create') ){
  			try{
  				insert auxList;
  			}
  			catch( Exception ex ){
 				//System.assert( false ,'Pre deploy test failed, This may be because of custom validation rules in your Org. You can check ignore apex errors or temporarily deactivate your validation rules for Events and try again.');
 				System.assert(false, ex.getMessage());
 			}
 			this.testEventList = new List<Event>();
 			this.testEventList.addAll( auxList );
 			//
  		}
  		else{
  			System.Assert(false , 'You need right over Event Object');
  		}
  	}
  	
  	/**
    * Create a New Lead just for event
    * @return LeadId
    */
  	private String getLeadId(){
  		Lead nLead = new Lead();
  		nLead.FirstName = 'Test';
  		nLead.LastName 	= 'Test';
  		nLead.Email		= 'test@unit.test';
  		nLead.Company 	= 'Force.com Labs';
		nLead.OwnerId	= UserInfo.getUserId();
		nLead.Status 	= 'Open';
  		Set<String> fieldsToCheck 	= new Set<String>{'FirstName', 'LastName','Email', 'Company', 'OwnerId', 'Status'};
  		if ( this.checkObjectCrud('Lead', fieldsToCheck, 'create') ){
  			try{
  				insert nLead;
  				return nLead.Id;
  			}
  			catch( Exception ex ){
 				System.assert( false ,'Pre deploy test failed, This may be because of custom validation rules in your Org. You can check ignore apex errors or temporarily deactivate your validation rules for Events and try again.');
 			}
  		}
  		else{
  			System.assert(false , 'You need right over Lead Object');
  		}
  		return null;
  	}
}