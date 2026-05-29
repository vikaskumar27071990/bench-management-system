public class ContactBenchHandler {
    
    public static void handleBenchConfirmation(List<Contact> newContacts, Map<Id, Contact> oldContacts) {
        Set<Id> confirmedBenchIds = new Set<Id>();
        
        for (Contact con : newContacts) {
            Contact oldCon = oldContacts.get(con.Id);
            
            // Check if status just changed to true and hasn't been triggered yet
            if (con.Bench_Status_Confirmed__c == true && 
                oldCon.Bench_Status_Confirmed__c == false && 
                con.Agentforce_Triggered__c == false) {
                
                confirmedBenchIds.add(con.Id);
            }
        }
        
        if (!confirmedBenchIds.isEmpty()) {
            // Step: Call your Agentforce / AI Job Matching @future method here
            // BenchManagementService.startAIAgentforceSearch(confirmedBenchIds);
            
            // Mark as triggered so it doesn't fire again
            markAgentforceTriggered(confirmedBenchIds);
        }
    }
    
    @future
    private static void markAgentforceTriggered(Set<Id> contactIds) {
        List<Contact> consToUpdate = new List<Contact>();
        for(Id cid : contactIds) {
            consToUpdate.add(new Contact(Id = cid, Agentforce_Triggered__c = true));
        }
        update consToUpdate;
    }
}