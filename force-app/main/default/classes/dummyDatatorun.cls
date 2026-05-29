public class dummyDatatorun {


    public static void batchFired(){
        // Running the batch manually with a scope size of 50
Database.executeBatch(new BenchNotificationBatch(), 50);
System.debug('Batch Job Fired!');
    }

    public static void justToTest(){
// Contact 1: Exactly 30 days left (Initial Email Trigger)
Contact c1 = new Contact(
    LastName = 'Kumar_30DaysTest',
    Email = 'auralwc2021@gmail.com', // Apna actual email id yahan daal
    Expected_Bench_Date__c = Date.today().addDays(30),
    Bench_Status_Confirmed__c = false
);

// Contact 2: Less than 30 days left (Reminder Email Trigger - Will fire because today is Friday)
Contact c2 = new Contact(
    LastName = 'Sharma_ReminderTest',
    Email = 'theprojectj27@gmail.com', // Apna actual email id yahan daal
    Expected_Bench_Date__c = Date.today().addDays(15), 
    Bench_Status_Confirmed__c = false
);

insert new List<Contact>{c1, c2};
System.debug('Dummy Contacts Inserted Successfully!');

    }

public static void schedulefire(){
// Cron Expression for Daily at Midnight
String cronExp = '0 0 0 * * ?';
System.schedule('Daily Bench Notification Check', cronExp, new BenchNotificationBatch());

}
    public static void getDummyData(){

Job_Posting__c job = new Job_Posting__c(
    Name = 'Integration Specialist',
    Required_Grade__c = 'B2',
    Required_Skills__c = 'Apex, LWC, OmniStudio, REST API'
);
insert job;


Contact cand = new Contact(
    LastName = 'Kumar',
    Email = 'test@dummy.com',
    Grade__c = 'B1',
    Primary_Skills__c = 'Apex, LWC, REST API' // OmniStudio is missing
);
insert cand;


Job_Application__c app = new Job_Application__c(
    Candidate__c = cand.Id,
    Job_Posting__c = job.Id
);
insert app;

}
}