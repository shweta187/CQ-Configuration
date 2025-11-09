@IsTest
private class PartProductSyncBatchTest {
     private static User makeUser(String alias, String email, String profileName, String lastName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        return new User(
            Alias = alias,
            Email = email,
            EmailEncodingKey = 'UTF-8',
            FirstName = 'Test',
            LastName = lastName,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = email,
            ProfileId = p.Id
        );
    }

    @IsTest
    static void partProductSyncBatchTestmethod1() {
        User std = makeUser('admusr1', 'admtest1@user.com', 'System Administrator', 'User1');
        System.runAs(std) {
            Product2 existing = new Product2(Name = 'Existing Part',ProductCode = 'E-123',IsActive = true );
            insert existing;

            SQX_Part__c p1 = new SQX_Part__c(Name = 'Test1', SQX_Part_Number__c = 'T-001',SQX_Active__c = true );
            
            SQX_Part__c p2 = new SQX_Part__c(Name = 'Test2', SQX_Part_Number__c = null, SQX_Active__c = true);
            
            SQX_Part__c p3 = new SQX_Part__c(Name = 'Existing Part',SQX_Part_Number__c = 'E-123', SQX_Active__c = true );
            
            SQX_Part__c p4 = new SQX_Part__c(Name = 'Inactive Part',SQX_Part_Number__c = 'I-001',SQX_Active__c = false);
            insert new List<SQX_Part__c>{ p1, p2, p3, p4 };

            Integer preProductsCount = [SELECT COUNT() FROM Product2];

            Test.startTest();
            Database.executeBatch(new PartProductSyncBatch(), 200);
            Test.stopTest();

            Integer postProductsCount = [SELECT COUNT() FROM Product2];
            System.assertEquals(preProductsCount + 2, postProductsCount,'two new Products should be created.');

            Map<Id, SQX_Part__c> parts = new Map<Id, SQX_Part__c>([SELECT Id, SQX_Product__c, SQX_Active__c, Name, SQX_Part_Number__c
                                                                    FROM SQX_Part__c WHERE Id IN :new List<Id>{p1.Id, p2.Id, p3.Id, p4.Id}
            ]);

            System.assertNotEquals(null, parts.get(p1.Id).SQX_Product__c, 'Test1 should be linked.');
            System.assertNotEquals(null, parts.get(p2.Id).SQX_Product__c, 'Test2 should be linked.');
            System.assertNotEquals(null, parts.get(p3.Id).SQX_Product__c, 'Existing Part should be linked to the existing Product.');
            System.assertEquals(null, parts.get(p4.Id).SQX_Product__c, 'Inactive Part must be ignored.');
        }
    }
   
    @IsTest
    static void partProductSyncSchedulertestmethod2() {
        User admin = makeUser('admusr2', 'admtest2@user.com', 'System Administrator', 'User2');

        System.runAs(admin) {
            insert new SQX_Part__c(Name='Admin Part',SQX_Part_Number__c='A-001',SQX_Active__c=true);

            Test.startTest();
            new PartProductSyncScheduler().execute(null);
            Test.stopTest();
        }
    }

    @IsTest
    static void partProductSyncSchedulertestmethod3() {
        User std = makeUser('stdusr1', 'stdtest2@user.com', 'Standard User', 'User3');

        System.runAs(std) {
            insert new SQX_Part__c(Name='Std Part',SQX_Part_Number__c='S-001', SQX_Active__c=true );

            Test.startTest();
            new PartProductSyncScheduler().execute(null);
            Test.stopTest();

            SQX_Part__c part = [SELECT SQX_Product__c FROM SQX_Part__c WHERE Name='Std Part' LIMIT 1 ];
            System.assertEquals(null, part.SQX_Product__c, 'Standard user should NOT trigger the batch via scheduler.');
        }
    }
}