/*trigger JobApplicationTrigger on Job_Application__c (before insert) {

}*/

trigger JobApplicationTrigger on Job_Application__c (before insert, after insert) {
    
    // Step 20: Synchronous Before Insert - Grade limit check
    if (Trigger.isBefore && Trigger.isInsert) {
       //====> BenchManagementService.validateGrades(Trigger.new);
    }
    
    // Step 30: Asynchronous After Insert - Skill Match & Email
    if (Trigger.isAfter && Trigger.isInsert) {
        Set<Id> applicationIds = Trigger.newMap.keySet();
        // Passing IDs to @future method because we can't pass sObjects directly
     //====>   BenchManagementService.processSkillMatchingAndEmails(applicationIds); 
    }
}