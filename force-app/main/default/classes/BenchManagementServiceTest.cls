@isTest
private class BenchManagementServiceTest {
    
    // Step 10: @testSetup automatically dummy data create karta hai before testing
    @testSetup
    static void setupTestData() {
        List<Contact> testContacts = new List<Contact>();
        
        // 30 days exactly left
        testContacts.add(new Contact(
            LastName = 'Test_30Days',
            Email = 'test30@dummy.com',
            Expected_Bench_Date__c = Date.today().addDays(30),
            Bench_Status_Confirmed__c = false
        ));
        
        // 15 days left (Mid-way reminder)
        testContacts.add(new Contact(
            LastName = 'Test_15Days',
            Email = 'test15@dummy.com',
            Expected_Bench_Date__c = Date.today().addDays(15),
            Bench_Status_Confirmed__c = false
        ));
        
        insert testContacts;
    }

    // Step 30: Automatically test the Batch Class
    @isTest
    static void testBatchExecutionAutomated() {
        // Test.startTest() aur stopTest() ke beech mein Asynchronous code synchronous ban jata hai
        Test.startTest();
        
        // Batch ko apne aap fire karega
        BenchNotificationBatch batchObj = new BenchNotificationBatch();
        Database.executeBatch(batchObj, 200);
        
        Test.stopTest(); // Yahan process complete hogi
        
        // Step 40: Assertion (AI System check karega ki koi error toh nahi aayi)
        // Check if contacts are still there (Simple sanity check)
        Integer count = [SELECT COUNT() FROM Contact WHERE Bench_Status_Confirmed__c = false];
        System.assertEquals(2, count, 'Dummy contacts should still exist and be unconfirmed.');
    }
    
    // Step 50: Automatically test the Scheduler
    @isTest
    static void testSchedulerAutomated() {
        Test.startTest();
        String cronExp = '0 0 0 * * ?';
        String jobId = System.schedule('Test Daily Bench Scheduler', cronExp, new BenchNotificationBatch());
        Test.stopTest();
        
        System.assertNotEquals(null, jobId, 'Job ID should not be null, scheduler failed!');
    }
}