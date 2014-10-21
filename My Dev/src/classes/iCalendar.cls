/**
* iCalendar Class, get de Events and supports iCal
* @LastModify : Force.com Labs ( smunoz@timbasoftware.com )
* @Date : 06/15/2010
*/
global with sharing class iCalendar {
 
  /**
  *	Attributes
  */
  private Datetime startDateTime;
  private Datetime endDateTime;
  private Datetime startDateTimeGMT;
  private Datetime endDateTimeGMT;
  static String CRLF = '\r\n';
  
  /**
  *	Constructor
  */
  global iCalendar() {
    UserId 		= UserInfo.getUserId();
    StartDate 	= Date.today().toStartOfMonth();
    EndDate  	= Date.today().toStartOfMonth().addMonths(2).addDays(-1);
  }
  
  global String UserId { get; set; }
  
  /**
  * StartDate, set the value for startDateTime, startDateTimeGMT and it self 
  */
  global Date StartDate {
    set {
      startDateTime 	= Datetime.newInstance(value.year(), value.month(), value.day());
      startDateTimeGMT 	= Datetime.newInstanceGmt(value.year(), value.month(), value.day());
      StartDate 		= value;
    }
  }
  
  /**
  * End Date, set the value for endDateTime, endDateTimeGMT and it self 
  */
  global Date EndDate {
    set {
      Date endDateInclusive = value.addDays(1);
      endDateTime 			= Datetime.newInstance(endDateInclusive.year(), endDateInclusive.month(), endDateInclusive.day());
      endDateTimeGMT 		= Datetime.newInstanceGmt(endDateInclusive.year(), endDateInclusive.month(), endDateInclusive.day());
	  EndDate				= value;
    }
  }
  
  /**
  * Initialize the FormUI, and if startDateParam, endDateParam are'nt empty, changes the values for global attr
  */
  public void InitFromUI() {
    String startDateParam 	= ApexPages.currentPage().getParameters().get('s');
    String endDateParam 	= ApexPages.currentPage().getParameters().get('e');
    if (startDateParam != null) {
      StartDate = Date.valueOf( startDateParam );
    }
    if (endDateParam != null) {
      EndDate = Date.valueOf( endDateParam );
    }
  }
  
  /**
  * Read the Events Object and return a well-formed iCal String.
  * @return String Wrap(result, 75);
  */
  global String getVCALENDAR() {
    List<Event> events = LoadEvents();
    String dtstamp = 'DTSTAMP:' + Datetime.Now().formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'') + CRLF;
    String result = 'BEGIN:VCALENDAR' + CRLF + 'PRODID:-//Force.com Labs//iCalendar Export//EN' + CRLF + 'VERSION:2.0' + CRLF;
    result += 'METHOD:PUBLISH' + CRLF;
    result += 'X-WR-CALNAME:Salesforce Calendar' + CRLF;
    result += 'X-WR-RELCALID:' + UserInfo.getUserId() + CRLF;
    for (Event event : events) {
      result += 'BEGIN:VEVENT' + CRLF;
      result += Uid(event.Id, event.RecurrenceActivityId);
      result += dtstamp;
      result += Schedule(event.IsAllDayEvent, event.StartDateTime, event.EndDateTime);
      result += SetField('SUMMARY:', event.Subject);
      result += SetField('LOCATION:', event.Location);
      if (event.IsPrivate) result += 'CLASS:PRIVATE' + CRLF;
      result += BusyStatus(event.ShowAs);
      if (!event.IsAllDayEvent) {
        result += Reminder( event.ReminderDateTime, event.StartDateTime );
      }
      result += SetField('DESCRIPTION:', AddWhoWhat(event.Description, event.WhoId, event.Who.Type, event.WhatId, event.What.Type));
      result += Attendees(event);
      result += 'END:VEVENT' + CRLF;
    }
    result += 'END:VCALENDAR' + CRLF;
    return Wrap(result, 75);
  }
  
  /**
  * Load the actuals Events for the UserId
  * @retun events;
  */
  private List<Event> LoadEvents() {
    List<EventAttendee> ea = [
      SELECT EventId,Event.RecurrenceActivityId,Event.IsRecurrence,Event.IsAllDayEvent,Event.EndDateTime,Event.StartDateTime
      FROM EventAttendee
      WHERE AttendeeId = :UserId 
      AND (Event.RecurrenceActivityId=null OR Event.IsRecurrence=false)
      AND (Event.RecurrenceActivityId=null OR Event.IsRecurrence=false)
      AND ((Event.IsAllDayEvent = false AND Event.EndDateTime >= :startDateTime AND Event.StartDateTime < :endDateTime)
        OR (Event.IsAllDayEvent = true AND Event.EndDateTime > :startDateTimeGMT AND Event.StartDateTime < :endDateTimeGMT))
      ];
      
    List<String> attendingEventIds = new List<String>();
    for ( EventAttendee e : ea ) {
      attendingEventIds.add( e.EventId );
    }
    
    List<Event> events = [
      SELECT Id , OwnerId , StartDateTime , EndDateTime, IsAllDayEvent,Subject,Location,ShowAs,IsPrivate,ReminderDateTime,
        Description,WhoId,Who.Type,WhatId,What.Type,RecurrenceActivityId,IsRecurrence,IsGroupEvent,IsChild,
        (SELECT Id,AttendeeID,Status,RespondedDate,Response,Attendee.Name,Attendee.Email,Attendee.Type FROM EventAttendees)
      FROM Event
      WHERE (RecurrenceActivityId = null OR IsRecurrence = false)
      AND ((OwnerId = :userId AND IsChild = false) OR (Id IN :attendingEventIds))
      AND ((IsAllDayEvent = false AND EndDateTime >= :startDateTime AND StartDateTime < :endDateTime)
        OR (IsAllDayEvent = true AND EndDateTime > :startDateTimeGMT AND StartDateTime < :endDateTimeGMT))
      ];
    
    return events;
  }
  
  
  /**
  * Sets the escape format for the recived field
  * @params fieldName, fieldValue
  * @return fieldName+fieldValue
  */
  private String SetField(String fieldName, String fieldValue) {
    if (fieldValue != null && fieldValue != '') {
      return fieldName + Escape(fieldValue) + CRLF;
    }
    return '';
  }
  
  /**
  * Sets the escape format for the recived description field
  * @params fieldName, fieldValue
  * @return fieldName+fieldValue
  */
  private String SetDescriptionField(String fieldName, String fieldValue) {
    if (fieldValue != null && fieldValue != '') {
      return fieldName + Escape(fieldValue) + '\\n';
    }
    return '';
  }
  
  /**
  * Sets the UID value and return it
  * @params Id, RecurrenceActivityId
  * @return 'UID:' + Id + CRLF;
  */
  private String Uid(String Id, String RecurrenceActivityId) {
      return 'UID:' + Id + CRLF;
  }
  
  /**
  * Set the Schedule and return result
  * @params IsAllDayEvent, StartDateTime, EndDateTime
  * @return result;
  */
  private String Schedule(Boolean IsAllDayEvent, Datetime StartDateTime, Datetime EndDateTime) {
    String result;
    if (IsAllDayEvent) {
      result = 'DTSTART;VALUE=DATE:' + StartDateTime.formatGmt('yyyyMMdd') + CRLF;
      result += 'DTEND;VALUE=DATE:' + EndDateTime.AddDays(1).formatGmt('yyyyMMdd') + CRLF;
    }
    else {
      result = 'DTSTART:' + StartDateTime.formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'') + CRLF;
      result += 'DTEND:' + EndDateTime.formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'') + CRLF;
    }
    return result;
  }
  
  /**
  * Check if the Event.WhoId is a Contact or Lead and return object type
  * @params whoId, whoId
  * @return sObject o;
  */
  private sObject WhoProperties( String whoId, String whoType ) {
    if (whoType == 'Contact' || whoType == 'Lead') {
      sObject o = Database.query('SELECT Name,Phone,Email FROM ' + whoType + ' WHERE Id=\'' + whoId + '\'')[0];
      return o;
    }
    return null; 
  }
  
  /**
  * Check if the Event.WhatId is seted and return the object
  * @params whatId, whatType
  * @return sObject o;
  */
  private sObject WhatProperties(String whatId, String whatType) {
    if (whatType != null) {
      sObject o = Database.query('SELECT Name FROM ' + whatType + ' WHERE Id=\'' + whatId + '\'')[0];
      return o;
    }
    return null;
  }
  
  /**
  * Add the Information about WhatId / WhoId
  * @params description, whoId, whoType, whatId, whatType
  * @return addInfo + description
  */
  private String AddWhoWhat(String description, String whoId, String whoType, String whatId, String whatType) {
    if (description == null) {
      description = '';
    }
    sObject o = WhoProperties(whoId, whoType);
    String addInfo = '';
    if (o != null) {
      addInfo += SetDescriptionField(whoType + ': ', (String) o.get('Name'));
      addInfo += SetDescriptionField('Phone: ', (String) o.get('Phone'));
      addInfo += SetDescriptionField('Email: ', (String) o.get('Email'));
      addInfo += '\\n';
    }
    o = WhatProperties(whatId, whatType);
    if (o != null) {
      if (whatType == 'Product2') {
        whatType = 'Product';
      }
      addInfo += SetDescriptionField('Related to ' + whatType + ': ', (String) o.get('Name'));
      addInfo += '\\n';
    }
    return addInfo + description;
  }
  
  /**
  * Check the Event.ShowAs and set Busy Status
  * @params ShowAs
  * @return 'TRANSP:OPAQUE' + CRLF;
  */
  private String BusyStatus(String ShowAs) {
    if ( ShowAs == 'Free' ) {
      return 'TRANSP:TRANSPARENT' + CRLF + 'X-MICROSOFT-CDO-BUSYSTATUS:FREE' + CRLF;
    }
    else if (ShowAs == 'OutOfOffice') {
      return 'TRANSP:OPAQUE' + CRLF + 'X-MICROSOFT-CDO-BUSYSTATUS:OOF' + CRLF;
    }
    return 'TRANSP:OPAQUE' + CRLF;
  }
  
  /**
  * Sets the reminder alerts
  * @params ReminderDateTime, StartDateTime
  * @return string
  */
  private String Reminder(Datetime ReminderDateTime, Datetime StartDateTime) {
    if ( ReminderDateTime != null ) {
      return 'BEGIN:VALARM' + CRLF + 'TRIGGER:-PT' + ((StartDateTime.getTime() - ReminderDateTime.getTime()) / 1000) + 'S' + CRLF + 'ACTION:DISPLAY' + CRLF + 'DESCRIPTION:Reminder' + CRLF + 'END:VALARM' + CRLF;
    }
    return '';
  }
  
  /**
  * If the Event is a Group Event, return all Attendee
  * @params event
  * @return result
  */
  private String Attendees(Event event) {
    String result = '';
    if (event.IsGroupEvent) {
      List<EventAttendee> attendees = event.EventAttendees;
      for (EventAttendee attendee : attendees) {
        String attendeeEmail = attendee.Attendee.Email; 
        if (attendeeEmail == null && (attendee.Attendee.Type == 'Contact' || attendee.Attendee.Type == 'Lead')) {
          sObject o = WhoProperties(attendee.AttendeeId, attendee.Attendee.Type);
          attendeeEmail = (String) o.get('Email');
        }
        result += 'ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=TENTATIVE;CN="' + attendee.Attendee.Name + '":MAILTO:' + attendeeEmail + CRLF;
      }
      
      if ( event.OwnerId != UserId ) {
        User organizer = [SELECT Name,Email FROM User WHERE Id = :event.OwnerId][0];
        result += 'ORGANIZER;CN="' + organizer.Name + '":MAILTO:' + organizer.Email + CRLF;
      }
    }
    return result;
  }
  
  
  /**
  * Get a string and return this as eascaped string
  * @params original
  * @return original escaped
  */
  private String Escape(String original) {
    return original.replace('\n','\\n').replace('\r','');
  }
 
  /**
  *
  */
  private String Wrap(String original, Integer width) {
    return original;
  }
  
  /**
  * Unit Test Method
  */
  static testMethod void Test() {
    ApexPages.currentPage().getParameters().put( 's', String.valueOf( Date.today().addDays(-1) ) );
    ApexPages.currentPage().getParameters().put( 'e' , String.valueOf( Date.today().addDays(1) ) );
	iCalendar_TestUtilities testUtils = new iCalendar_TestUtilities();
	testUtils.createEvents(10);
	
    Test.startTest(); 
    
    	iCalendar ics 	= new iCalendar();
    	ics.StartDate 	= Date.today().addDays(-1);
    	ics.EndDate 	= Date.today().addDays(1);
    	ics.InitFromUI();
	    System.assert( ics.getVCALENDAR() != null );

    Test.stopTest();
    
  }
}