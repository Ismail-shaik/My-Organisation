/**
*An apex page controller that set a new iCalendarOptions__c and default date
*@LastModify Force.com Labs smunoz
*@Date : 06/15/2010
*/
public with sharing class iCalendarUIController {
  
  	/**
	*Sets a New instance of iCalendarOptions__c and then, return it
	*@return c
	*/
	public iCalendarOptions__c getRange() {
		iCalendarOptions__c c 	= new iCalendarOptions__c();
		c.StartDate__c 			= Date.today();
		c.EndDate__c 			= Date.today();
		return c;
	}
  
  	/**
	*Return Sample Date
	*@Date.newInstance(2009, 11, 12).format();
	*/
	public String getSampleDate(){
		return Date.newInstance(2009, 11, 12).format();
	}
  
	/**
	* Unit Test Method
	*/
	static testMethod void Test(){
		Test.startTest();
			iCalendarUIController c = new iCalendarUIController();
			c.getRange();
			c.getSampleDate();
			System.assert( Date.today() == c.getRange().StartDate__c );
			System.assert( Date.today() == c.getRange().EndDate__c );
		Test.stopTest();
	}
}