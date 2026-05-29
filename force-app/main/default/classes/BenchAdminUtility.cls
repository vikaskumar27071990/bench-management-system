public class BenchAdminUtility {
    
    // Step 30: Exposing the method to Flow
    @InvocableMethod(label='Run Bench AI Sync Batch' description='Manually fires the BenchNotificationBatch from a Flow')
    public static void executeBenchBatchManually() {
        // Safe check: Ensure batch is not already running to avoid Flex Queue limits
        Integer activeJobs = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status IN ('Queued', 'Processing', 'Preparing')];
        
        if(activeJobs < 5) {
            Database.executeBatch(new BenchNotificationBatch(), 50);
            System.debug('Manual Batch Execution Triggered via Flow');
        } else {
            System.debug('System is busy. Too many batches running.');
        }
    }
}