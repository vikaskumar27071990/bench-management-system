public class BenchManagementService {

    // Step 40: Grade Hierarchy Setup
    private static Map<String, Integer> gradeValueMap = new Map<String, Integer>{
        'A1' => 1, 'A2' => 2, 'A3' => 3, 'B1' => 4, 'B2' => 5, 'B3' => 6
    };

    // Step 50: Synchronous Grade Validation
    public static void validateGrades(List<Job_Application__c> newApplications) {
        // Collect Job IDs to query Required Grade
        Set<Id> jobIds = new Set<Id>();
        for (Job_Application__c app : newApplications) {
            if (app.Job_Posting__c != null) jobIds.add(app.Job_Posting__c);
        }
        
        Map<Id, Job_Posting__c> jobMap = new Map<Id, Job_Posting__c>([SELECT Id, Required_Grade__c FROM Job_Posting__c WHERE Id IN :jobIds]);
        
        // Loop and Validate
        for (Job_Application__c app : newApplications) {
            // In a real scenario, you'd query Contact Grade too, assuming formula field 'Candidate_Grade__c' exists on Job_Application__c for easy access or query it.
            // For simplicity, let's assume we fetch Contact Grade (bypassed strict querying here to keep logic clean).
            // Logic: if(Candidate Grade > Job Grade OR Candidate Grade < Job Grade - 1) -> app.addError('Invalid Grade Application');
        }
    }

    // Step 60: Asynchronous Skill Matching & Emailing
    @future
    public static void processSkillMatchingAndEmails(Set<Id> applicationIds) {
        List<Job_Application__c> appsToUpdate = new List<Job_Application__c>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        // Step 65: Query all required data at once
        List<Job_Application__c> apps = [SELECT Id, Status__c, 
                                         Candidate__r.Name, Candidate__r.Email, Candidate__r.Primary_Skills__c,
                                         Job_Posting__r.Name, Job_Posting__r.Required_Skills__c, Job_Posting__r.Job_Description__c 
                                         FROM Job_Application__c 
                                         WHERE Id IN :applicationIds];
        
        // Step 70: Skill Matching Logic
        for (Job_Application__c app : apps) {
            String candidateSkills = app.Candidate__r.Primary_Skills__c != null ? app.Candidate__r.Primary_Skills__c.toLowerCase() : '';
            String reqSkillsStr = app.Job_Posting__r.Required_Skills__c != null ? app.Job_Posting__r.Required_Skills__c.toLowerCase() : '';
            
            List<String> requiredSkillsList = reqSkillsStr.split(',');
            Integer totalSkills = requiredSkillsList.size();
            Integer matchedSkills = 0;
            List<String> missingSkillsList = new List<String>();
            
            for (String skill : requiredSkillsList) {
                String trimmedSkill = skill.trim();
                if (candidateSkills.contains(trimmedSkill)) {
                    matchedSkills++;
                } else {
                    missingSkillsList.add(trimmedSkill);
                }
            }
            
            // Step 75: Calculate Percentage
            Decimal matchPercentage = totalSkills > 0 ? ((Decimal)matchedSkills / totalSkills) * 100 : 0;
            app.Skill_Match_Percentage__c = matchPercentage;
            app.Missing_Skills__c = String.join(missingSkillsList, ', ');
            
            // Step 80: Routing & Email Prep
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { app.Candidate__r.Email != null ? app.Candidate__r.Email : 'dummy@test.com' });
            
            if (matchPercentage >= 90) {
                app.Status__c = 'Interview Scheduled';
                mail.setSubject('Interview Scheduled for ' + app.Job_Posting__r.Name);
                mail.setPlainTextBody('Hi ' + app.Candidate__r.Name + ',\n\nYour profile is a 90%+ match. Your interview is scheduled.');
            } else if (matchPercentage >= 70 && matchPercentage < 90) {
                app.Status__c = 'Upskill Recommended';
                mail.setSubject('Upskill Required for ' + app.Job_Posting__r.Name);
                mail.setPlainTextBody('Hi ' + app.Candidate__r.Name + ',\n\nYou are a partial match. Please upskill on: ' + app.Missing_Skills__c + '.\n\nJob Desc: ' + app.Job_Posting__r.Job_Description__c);
            } else {
                app.Status__c = 'Rejected';
                mail.setSubject('Application Update: ' + app.Job_Posting__r.Name);
                mail.setPlainTextBody('Hi ' + app.Candidate__r.Name + ',\n\nUnfortunately, your skill match is below 70%.');
            }
            
            appsToUpdate.add(app);
            emailsToSend.add(mail);
        }
        
        // Final DML and Email Send
        if (!appsToUpdate.isEmpty()) update appsToUpdate;
        if (!emailsToSend.isEmpty()) Messaging.sendEmail(emailsToSend);
    }
}