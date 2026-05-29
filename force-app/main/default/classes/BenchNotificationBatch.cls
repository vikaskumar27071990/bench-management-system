global class BenchNotificationBatch implements Database.Batchable<sObject>, Schedulable {
    
    // Step 1: Schedulable Execute Method
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BenchNotificationBatch(), 200);
    }
    
    // Step 2: Query Setup (Find unconfirmed bench resources)
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Sirf wahi contacts jinki bench date set hai aur confirmed nahi kiya
        String query = 'SELECT Id, Name, Email, Expected_Bench_Date__c FROM Contact ' +
                       'WHERE Expected_Bench_Date__c != null ' +
                       'AND Bench_Status_Confirmed__c = false';
        return Database.getQueryLocator(query);
    }
    
    // Step 3: Logic Execution
    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Date today = Date.today();
        
        // Find current day of the week ('Mon', 'Tue', 'Fri' etc.)
        String currentDay = Datetime.now().format('EEE'); 
        
        for (Contact emp : scope) {
            Integer daysLeft = today.daysBetween(emp.Expected_Bench_Date__c);
            
            // Condition A: Exactly 30 days left (Initial Email)
            if (daysLeft == 30) {
                emailsToSend.add(buildEmail(emp, 'Initial'));
            } 
            // Condition B: Less than 30 days left AND today is Monday or Friday (Reminder Email)
            else if (daysLeft > 0 && daysLeft < 30 && (currentDay == 'Mon' || currentDay == 'Fri')) {
                emailsToSend.add(buildEmail(emp, 'Reminder'));
            }
        }
        
        // Step 4: Bulk Email Dispatch
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        // Optional: Audit log creation can happen here
    }
    
    // Step 5: Helper method to construct emails
    private Messaging.SingleEmailMessage buildEmail(Contact emp, String type) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { emp.Email != null ? emp.Email : 'dummy@test.com' });
        
        if (type == 'Initial') {
            mail.setSubject('Action Required: Upcoming Bench Transition on ' + emp.Expected_Bench_Date__c.format());
            mail.setPlainTextBody('Hi ' + emp.Name + ',\n\nYou are scheduled to move to the bench on ' + emp.Expected_Bench_Date__c.format() + 
                                  '. Please log into Salesforce and check the "Bench Status Confirmed" box to trigger your automatic internal project search via AI.');
        } else {
            mail.setSubject('Reminder: Please Confirm Your Bench Status');
            mail.setPlainTextBody('Hi ' + emp.Name + ',\n\nThis is a reminder to confirm your upcoming bench status. ' +
                                  'Your AI Agentforce matching will NOT begin until you check the confirmation box in Salesforce.');
        }
        return mail;
    }
}